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

return {
  {
    url = "https://gitlab.com/schrieveslaach/sonarlint.nvim",
    name = "sonarlint.nvim",
    -- The server asks the editor about source control state; sonarlint.nvim
    -- answers via gitsigns, which LazyVim already installs.
    dependencies = { "lewis6991/gitsigns.nvim" },
    ft = { "c", "cpp" },
    config = function()
      require("sonarlint").setup({
        server = {
          cmd = { "sonarlint-ls", "-stdio" },

          -- The server re-analyses on every textDocument/didChange, and
          -- Neovim's default debounce is 150ms, so ordinary typing means a full
          -- CFamily run per keystroke.
          --
          -- This is set high enough that the timer never fires on its own;
          -- analysis is instead driven explicitly by the autocmd below. Note
          -- that sonarlint.automaticAnalysis, the setting VS Code exposes for
          -- this, does reach the server and is then ignored by it - the
          -- throttling has to happen on Neovim's side.
          flags = { debounce_text_changes = 30000 },

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

      -- Analyse when leaving insert mode, and after a normal-mode edit
      -- (TextChanged does not fire in insert mode), but never mid-keystroke.
      --
      -- Client:request() and Client:notify() both flush pending changes on
      -- their own, so anything that talks to the server - a code action, for
      -- instance - can still trigger an analysis earlier than this.
      vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
        group = vim.api.nvim_create_augroup("sonarlint_analyse", { clear = true }),
        callback = function(ev)
          -- _changetracking is private: degrade to the debounce above rather
          -- than erroring if a Neovim upgrade moves it.
          local ok, ct = pcall(function()
            return vim.lsp._changetracking
          end)
          if not (ok and ct and ct.flush) then
            return
          end
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf, name = "sonarlint.nvim" })) do
            pcall(ct.flush, client, ev.buf)
          end
        end,
      })
    end,
  },
}
