-- [[ --------------------------------------------------------------------------
-- KEYMAPS
-- ]] --------------------------------------------------------------------------
local silent = { silent = true }
local remap = { remap = true }

-- General
vim.keymap.set("n", "<C-s>", ":w! <CR>", {})
vim.keymap.set("n", "<leader>w", ":w! <CR>", {})
vim.keymap.set("n", "<C-A-Left>", "<C-o>", remap)  -- previous position
vim.keymap.set("n", "<C-A-Right>", "<C-i>", remap) -- next position

-- Window & Tabs
vim.keymap.set("n", "<A-Left>", ":tabprevious <CR>", silent)
vim.keymap.set("n", "<A-Right>", ":tabnext <CR>", silent)

vim.keymap.set("n", "<A-S-Up>", ":wincmd k <CR>", silent)
vim.keymap.set("n", "<A-S-Down>", ":wincmd j <CR>", silent)
vim.keymap.set("n", "<A-S-Left>", ":wincmd h <CR>", silent)
vim.keymap.set("n", "<A-S-Right>", ":wincmd l <CR>", silent)

vim.keymap.set("n", "<F28>", ":q <CR>", silent) -- Ctrl + F4

-- Telescope
local telescope = require("telescope.builtin")

vim.keymap.set("n", "<C-S-N>", telescope.find_files, {})
vim.keymap.set("i", "<C-S-N>", telescope.find_files, {})
vim.keymap.set("v", "<C-S-N>", telescope.find_files, {})

vim.keymap.set("n", "<C-S-F>", telescope.live_grep, {})
vim.keymap.set("i", "<C-S-F>", telescope.live_grep, {})
vim.keymap.set("v", "<C-S-F>", telescope.grep_string, {})

vim.keymap.set("n", "<C-e>", telescope.oldfiles, {})
vim.keymap.set("n", "<C-f>", telescope.current_buffer_fuzzy_find, {})
vim.keymap.set("v", "<C-f>", telescope.current_buffer_fuzzy_find, {})

-- vs-tasks
local telescopeAll = require("telescope")
vim.keymap.set("n", "<F22>", telescopeAll.extensions.vstask.tasks, {}) -- S-F10
vim.keymap.set("n", "<F23>", telescopeAll.extensions.vstask.inputs, {}) -- S-F11

-- Comment
vim.keymap.set("n", "<C-/>", "gcc", remap)
vim.keymap.set("i", "<C-/>", "<Esc> gcc", remap)
vim.keymap.set("v", "<C-/>", "gc", remap)

-- Neotree
local toggle = ":Neotree source=filesystem reveal=true position=left toggle=true <CR>"
vim.keymap.set("n", "<A-1>", toggle, silent)

local current = ":Neotree source=filesystem reveal=true position=left <CR>"
vim.keymap.set("n", "<F49>", current, silent) -- Alt + F1

-- Haskell
local ht = require("haskell-tools")
local bufnr = vim.api.nvim_get_current_buf()
local opts = { noremap = true, silent = true, buffer = bufnr }
-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, {})
-- Hoogle search for the type signature of the definition under the cursor
vim.keymap.set("n", "<leader>hs", ht.hoogle.hoogle_signature, {})
-- Evaluate all code snippets
vim.keymap.set("n", "<leader>ea", ht.lsp.buf_eval_all, opts)
-- Toggle a GHCi repl for the current package
vim.keymap.set("n", "<leader>rr", ht.repl.toggle, opts)
-- Toggle a GHCi repl for the current buffer
vim.keymap.set("n", "<leader>rf", function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, opts)
vim.keymap.set("n", "<leader>rq", ht.repl.quit, opts)
