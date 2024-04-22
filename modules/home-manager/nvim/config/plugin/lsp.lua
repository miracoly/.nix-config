-- [[ --------------------------------------------------------------------------
-- LSP
-- ]] --------------------------------------------------------------------------

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

require('neodev').setup({
  override = function(root_dir, library)
    if root_dir:find("/etc/nixos", 1, true) == 1 or
        root_dir:find("/home/mira/.nix-config", 1, true) == 1 then
      library.enabled = true
      library.plugins = true
    end
  end,
})

local lspconfig = require('lspconfig')

lspconfig.lua_ls.setup {
  -- on_attach = on_attach,
  -- capabilities = capabilities,
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false
      },
      telemetry = {
        enable = false
      }
    }
  }
}

-- Nix
-- lspconfig.rnix.setup {
-- }

-- Standard ML
lspconfig.millet.setup {}

-- Typescript
lspconfig.tsserver.setup {
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "ANY_VALUE",
        languages = { "javascript", "typescript", "vue" },
      },
    },
  },
  filetypes = {
    "javascript",
    "typescript",
    "vue",
  },
}

lspconfig.volar.setup {}

lspconfig.eslint.setup({
  on_attach = function(_, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

-- Global config
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local telescope = require('telescope.builtin')
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<C-b>', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<C-A-B>', telescope.lsp_references, opts)
    vim.keymap.set('n', '<C-q>', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<A-7>', telescope.lsp_document_symbols, opts)
    -- vim.keymap.set('n', '<C-A-B>', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-p>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<C-S-B>', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<F18>', vim.lsp.buf.rename, opts) -- S-F6
    vim.keymap.set({ 'n', 'v' }, '<A-CR>', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})
