-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

map({ "n" }, "<Enter>", "<cmd>w<cr><esc>", { desc = "Save File" })
map({ "n" }, "<leader>uP", function()
  local copilot = require("copilot.client")
  if copilot.is_disabled() then
    vim.cmd("Copilot enable")
    vim.notify("Copilot enabled", vim.log.levels.INFO)
  else
    vim.cmd("Copilot disable")
    vim.notify("Copilot disabled", vim.log.levels.INFO)
  end
end, { desc = "Enable/Disable Copilot" })
