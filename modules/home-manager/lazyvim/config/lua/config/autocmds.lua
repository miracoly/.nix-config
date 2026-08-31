-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- clangd's hover (`K`) shows the declaration plus whatever comment libstdc++
-- happens to carry in the header, which is often a single terse line. clangd has
-- no knowledge of cppreference and no setting adds one, so the prose reference
-- has to come from somewhere else: cppman renders cppreference.com pages.
--
-- Rather than bind a new key, this sets 'keywordprg', which is exactly the
-- option LazyVim's existing <leader>K ("Keywordprg") already invokes. The
-- default is ":Man", which is worth keeping everywhere else - it covers C
-- library functions properly, memcpy(3) and friends. What it has nothing to say
-- about is std:: symbols, which is the gap cppman fills.
--
-- C is deliberately excluded: for a .c file man(3) is the authoritative
-- reference, while cppman would answer with cppreference's std::memcpy, the C++
-- view of it. Plain .h headers are unaffected by that exclusion - Neovim
-- resolves an ambiguous .h to "cpp" rather than "c" (M.header in
-- filetype/detect.lua; g:c_syntax_for_h flips it), so they still get cppman,
-- which is what a C++ project wants.
--
-- The ":" prefix is load-bearing. Neovim runs a 'keywordprg' starting with ":"
-- as an Ex command with the keyword appended; anything else is run through the
-- shell, which would blank the editor until the pager exits.
--
-- Run `cppman -c` once to populate the offline cache; without it every lookup
-- hits the network. Bare words are passed through as-is - cppman offers a
-- numbered menu when a name like `formatter` matches several pages.
vim.api.nvim_create_user_command("Cppman", function(opts)
  vim.cmd("botright 20new")
  local buf = vim.api.nvim_get_current_buf()
  vim.fn.jobstart({ "cppman", opts.args }, {
    term = true,
    -- Quitting the pager closes the split rather than leaving a dead
    -- "[Process exited]" buffer behind.
    on_exit = function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
  vim.cmd("startinsert")
end, { nargs = 1, desc = "cppreference.com page for a C++ symbol" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp" },
  callback = function()
    vim.bo.keywordprg = ":Cppman"
  end,
})
