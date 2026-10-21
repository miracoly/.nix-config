-- SonarQube for IDE (formerly SonarLint) via sonarlint.nvim, a thin wrapper
-- around SonarSource's sonarlint-language-server. It does not go through
-- lspconfig -- it calls vim.lsp.start() itself and attaches on FileType.
--
-- The server binary is provided by Nix as `sonarlint-ls` on PATH, see
-- modules/home-manager/lazyvim/default.nix. That wrapper already passes `-jar`
-- and `-analyzers <every bundled analyzer jar>`, so the only argument left to
-- add here is `-stdio`.
--
-- Adding another language:
--
--   1. Add its filetype to BOTH `ft` and `filetypes` below, e.g. "python".
--      `ft` is what makes lazy.nvim load the plugin, `filetypes` is what makes
--      sonarlint.nvim attach the server.
--   2. Nothing to change on the Nix side for python, java, javascript,
--      typescript, go, php, cs, xml, html, yaml/terraform/docker (IaC) or the
--      secrets analyzer -- those jars all ship with the package already.
--
-- C and C++ need a compile_commands.json (CMAKE_EXPORT_COMPILE_COMMANDS=ON, or
-- bear/compiledb). sonarlint.nvim searches upward from the current file for it
-- and reports an error in :messages when it finds none.
--
-- This runs in standalone mode with SonarSource's default rules. Connected mode
-- against a SonarQube Server/Cloud instance, and per-rule configuration, are
-- documented in the plugin's doc/config.md (`:h sonarlint.nvim`).

-- How long a Full-sync server may sit on pending changes. Deliberately far
-- longer than any pause in typing: the timer is never meant to fire on its own,
-- the autocmd in `init` is what actually sends the changes.
local FULL_SYNC_DEBOUNCE_MS = 30000

return {
  {
    url = "https://gitlab.com/schrieveslaach/sonarlint.nvim",
    name = "sonarlint.nvim",
    -- The server asks the editor about source control state; sonarlint.nvim
    -- answers via gitsigns, which LazyVim already installs.
    dependencies = { "lewis6991/gitsigns.nvim" },
    ft = { "c", "cpp" },

    -- This has to run at startup rather than in `config`, which is gated behind
    -- `ft`: a client's debounce is read once, when it first attaches to a
    -- buffer, and can never be raised afterwards. By the time a C++ file is
    -- opened, marksman may already have attached to a README and set the group
    -- value for the rest of the session.
    init = function()
      -- Neovim keeps ONE change-tracking group per text-sync kind, and that
      -- group uses the SMALLEST debounce of every client in it:
      --
      --   state.debounce = math.min(state.debounce, client.flags.debounce_text_changes or 150)
      --       -- vim/lsp/_changetracking.lua
      --
      -- For Full sync the group key is the sync kind alone, so every Full-sync
      -- server in the process shares one timer, and the value only ever
      -- ratchets down. sonarlint-ls uses Full sync, so a single other Full-sync
      -- server attaching anywhere in the session - marksman on a README,
      -- bashls on a shell script - silently discards sonarlint's debounce and
      -- puts it back to re-analysing on every keystroke. Measured: 15 edits in
      -- a C++ buffer alone produced 0 analyses; opening one markdown buffer in
      -- the same session took that to 15.
      --
      -- So the debounce has to be raised for the whole group. Keyed off the
      -- advertised sync kind rather than a list of server names, so that adding
      -- another Full-sync server later cannot quietly undo it.
      vim.lsp.config("*", {
        on_init = function(client)
          local sync = client.server_capabilities and client.server_capabilities.textDocumentSync
          -- textDocumentSync is a table in practice, but the LSP spec still
          -- permits the bare enum.
          local change = type(sync) == "table" and sync.change or sync
          if change == vim.lsp.protocol.TextDocumentSyncKind.Full then
            client.flags.debounce_text_changes = FULL_SYNC_DEBOUNCE_MS
          end
        end,
      })

      -- Raising the debounce alone would just starve those servers, so drive
      -- them explicitly: send pending changes when leaving insert mode, and
      -- after a normal-mode edit (TextChanged does not fire in insert mode).
      --
      -- Incremental servers - clangd, lua_ls, pyright, ruff, nil_ls, yamlls -
      -- sit in their own groups, keep the 150ms default and are untouched by
      -- any of this; flushing them here is a no-op when nothing is pending.
      --
      -- Client:request() and Client:notify() flush on their own too, so
      -- anything that talks to a server - a completion or code action - can
      -- still push changes through earlier than this.
      vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
        group = vim.api.nvim_create_augroup("lsp_flush_on_normal_mode", { clear = true }),
        callback = function(ev)
          -- _changetracking is private: degrade to the debounce above rather
          -- than erroring if a Neovim upgrade moves it.
          local ok, ct = pcall(function()
            return vim.lsp._changetracking
          end)
          if not (ok and ct and ct.flush) then
            return
          end
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
            pcall(ct.flush, client, ev.buf)
          end
        end,
      })
    end,

    config = function()
      require("sonarlint").setup({
        server = {
          cmd = { "sonarlint-ls", "-stdio" },

          -- The server re-analyses on every textDocument/didChange, and
          -- Neovim's default debounce is 150ms, so ordinary typing means a full
          -- CFamily run per keystroke.
          --
          -- Set here as well as in the `vim.lsp.config("*")` hook above, because
          -- sonarlint.nvim calls vim.lsp.start() directly and so never passes
          -- through vim.lsp.config at all. Note that sonarlint.automaticAnalysis,
          -- the setting VS Code exposes for this, does reach the server and is
          -- then ignored by it - the throttling has to happen on Neovim's side.
          flags = { debounce_text_changes = FULL_SYNC_DEBOUNCE_MS },

          -- CFamily registers its rules under one repository per language, so a
          -- `cpp:` key has no effect on a .c file and vice versa. Check the
          -- analyzer's own metadata before adding a key -- S1135 declares
          -- compatibleLanguages [C, CPP, OBJC] and so needs both spellings,
          -- while S6004 ("if"/"switch" initializer) is [CPP] only and has no
          -- `c:` counterpart. An unknown or misspelled key is accepted
          -- silently, so a typo here just quietly does nothing.
          settings = {
            sonarlint = {
              rules = {
                -- Track uses of "TODO" tags
                ["c:S1135"] = { level = "off" },
                ["cpp:S1135"] = { level = "off" },
                -- "if"/"switch" initializer should be used to reduce scope
                ["cpp:S6004"] = { level = "off" },
              },
            },
          },
        },
        filetypes = { "c", "cpp" },
      })
    end,
  },
}
