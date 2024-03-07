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
lspconfig.rnix.setup {
  -- on_attach = on_attach,
  -- capabilities = capabilities,
}

-- Haskell
lspconfig['hls'].setup {
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
}

lspconfig.tsserver.setup {}

-- Global config
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<C-q>', vim.lsp.buf.hover, opts)
    -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wl', function()
    -- print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, opts)
    -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    -- vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<A-CR>', vim.lsp.buf.code_action, opts)
    -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<C-A-l>', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
