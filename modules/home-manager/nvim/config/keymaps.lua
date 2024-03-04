-- [[ --------------------------------------------------------------------------
-- KEYMAPS
-- ]] --------------------------------------------------------------------------
local silent = { silent = true }
local remap = { remap = true }

-- General
vim.keymap.set("n", "<C-A-l>", ":Format <CR>", {})
vim.keymap.set("n", "<C-s>", ":w! <CR>", {})
vim.keymap.set("n", "<leader>w", ":w! <CR>", {})

-- Window & Tabs
vim.keymap.set("n", "<A-S-Left>", ":tabprevious <CR>", silent)
vim.keymap.set("n", "<A-S-Right>", ":tabnext <CR>", silent)

vim.keymap.set("n", "<A-Up>", ":wincmd k <CR>", silent)
vim.keymap.set("n", "<A-Down>", ":wincmd j <CR>", silent)
vim.keymap.set("n", "<A-Left>", ":wincmd h <CR>", silent)
vim.keymap.set("n", "<A-Right>", ":wincmd l <CR>", silent)

vim.keymap.set("n", "<F28>", ":q <CR>", silent) -- Ctrl + F4

-- Telescope
local telescope = require('telescope.builtin')

vim.keymap.set('n', '<C-S-N>', telescope.find_files, {})
vim.keymap.set('i', '<C-S-N>', telescope.find_files, {})
vim.keymap.set('v', '<C-S-N>', telescope.find_files, {})

vim.keymap.set('n', '<C-S-F>', telescope.live_grep, {})
vim.keymap.set('i', '<C-S-F>', telescope.live_grep, {})
vim.keymap.set('v', '<C-S-F>', telescope.grep_string, {})

vim.keymap.set('n', '<C-e>', telescope.oldfiles, {})
vim.keymap.set('n', '<C-f>', telescope.current_buffer_fuzzy_find, {})
vim.keymap.set('v', '<C-f>', telescope.current_buffer_fuzzy_find, {})

-- Comment
vim.keymap.set('n', '<C-/>', 'gcc', remap)
vim.keymap.set('i', '<C-/>', '<Esc> gcc', remap)
vim.keymap.set('v', '<C-/>', 'gc', remap)

-- Neotree
local toggle = ':Neotree source=filesystem reveal=true position=left toggle=true <CR>'
vim.keymap.set('n', '<A-1>', toggle, silent)

local current = ':Neotree source=filesystem reveal=true position=left <CR>'
vim.keymap.set('n', '<F49>', current, silent) -- Alt + F1
