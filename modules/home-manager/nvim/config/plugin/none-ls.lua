local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettier,
  },

  vim.keymap.set("n", "<C-A-l>", function()
    vim.lsp.buf.format({ async = true })
  end, {}),
})
