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
        },
        filetypes = { "c", "cpp" },
      })
    end,
  },
}
