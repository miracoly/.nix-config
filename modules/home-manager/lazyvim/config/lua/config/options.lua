-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_ruby_lsp = "solargraph"

vim.filetype.add({ extension = { bats = "sh" } })

-- Filetypes
vim.filetype.add({
  extension = {
    env = "dotenv",
  },
  filename = {
    [".env"] = "dotenv",
    [".env.local"] = "dotenv",
    [".env.dev"] = "dotenv",
    [".env.prod"] = "dotenv",
    [".env.test"] = "dotenv",
  },
  pattern = {
    ["%.env%..*"] = "dotenv",
  },
})
