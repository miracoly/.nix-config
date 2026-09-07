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
-- hits the network.
--
-- When a name matches several pages, cppman prints a numbered menu and blocks
-- on a bare Python input() prompt. That prompt is not a pager, so a long list
-- just scrolls off the top with no way to page back other than the terminal's
-- own scrollback (<C-\><C-n>). It is routinely unusable: `size` matches 4341
-- entries. So the menu is skipped entirely - the candidates are pulled from
-- cppman up front with `-f` and handed to vim.ui.select, which LazyVim routes
-- through its picker, giving fuzzy filtering instead of scrolling.

-- Opens `cppman <query>` in a centered floating terminal. `selection`, when
-- given, is the number to answer cppman's menu with.
local function cppman_float(query, selection, title)
  -- Sized for legibility, not for the screen: groff reflows cppman's output to
  -- the window width at launch, so a cramped window mangles the synopsis tables.
  -- 100 columns is comfortable for man output; the proportions clamp down on a
  -- small terminal rather than overflowing it.
  local width = math.min(100, math.floor(vim.o.columns * 0.9))
  local height = math.floor(vim.o.lines * 0.85)

  -- A plain unlisted buffer, not a scratch one - the terminal needs to set its
  -- own buftype, and it must start empty and unmodified.
  local buf = vim.api.nvim_create_buf(false, false)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = vim.o.winborder ~= "" and vim.o.winborder or "rounded",
    title = " cppman: " .. (title or query) .. " ",
    title_pos = "center",
  })

  local chan = vim.fn.jobstart({ "cppman", query }, {
    term = true,
    -- Quitting the pager tears down the float rather than leaving a dead
    -- "[Process exited]" window behind.
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })

  -- The pty buffers this until cppman's input() gets around to reading it, so
  -- there is no race against process startup.
  if selection then
    vim.fn.chansend(chan, selection .. "\n")
  end

  vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("Cppman", function(opts)
  local query = opts.args

  -- `cppman -f X` and the menu of `cppman X` are rendered from the same query
  -- in the same order, so a line's position here is exactly the number the
  -- menu wants. The ordering is a total order - the sort key ends in the
  -- keyword, and keywords are unique - so it is stable across processes.
  -- vim.system rather than systemlist: cppman reports a miss on stderr and
  -- still exits 0, and systemlist folds stderr into its result, which would
  -- turn "nothing appropriate" into a plausible-looking single match.
  local res = vim.system({ "cppman", "-f", query }, { text = true }):wait()

  local matches = {}
  for line in (res.stdout or ""):gmatch("[^\n]+") do
    matches[#matches + 1] = line
  end

  if #matches == 0 then
    vim.notify("cppman: nothing appropriate for " .. query, vim.log.levels.WARN)
    return
  end

  -- A lone match means cppman skips the menu and opens the page directly, so
  -- there is nothing to answer and nothing worth asking about.
  if #matches == 1 then
    cppman_float(query)
    return
  end

  -- Snacks' picker, which is what LazyVim routes vim.ui.select through, reads a
  -- leading `word:` as a field filter (see `^([%w_][%w_]+):(.*)$` in its
  -- matcher). Typing `std::` therefore searches a field named "std", finds no
  -- such field, and silently shows nothing - which is exactly the query anyone
  -- reaches for here. Its regex mode skips that parsing altogether.
  --
  -- The trade is that patterns become Lua patterns instead of fuzzy
  -- subsequences: `basicstring` no longer finds `basic_string`, and a bracket
  -- query like `operator[]` is an invalid character class that quietly matches
  -- nothing - search `operator` instead. Literal matching suits a list of C++
  -- symbol names better than fuzzy does, and no other query form silently
  -- lies. Providers other than Snacks ignore the unknown key.
  local select_opts = {
    prompt = "cppman: " .. query,
    snacks = { matcher = { regex = true } },
  }

  vim.ui.select(matches, select_opts, function(choice, idx)
    if not idx then
      return
    end

    -- Each line is "keyword - page title".
    local keyword = choice:match("^(.-) %- ")
    if not keyword then
      cppman_float(query, idx)
      return
    end

    -- Re-run the lookup against the exact keyword rather than answering the
    -- original menu by number. A keyword is usually specific enough to match a
    -- single page, and then cppman skips the menu outright - worth the second
    -- lookup (~0.2s), because otherwise cppman has to print every candidate
    -- into the terminal before it will read the answer, and for a word like
    -- `size` that is 4341 lines and several seconds of rendering.
    local exact = vim.system({ "cppman", "-f", keyword }, { text = true }):wait()
    local _, n = (exact.stdout or ""):gsub("[^\n]+", "")

    if n == 0 then
      -- Nothing came back for the keyword itself; answer the original menu.
      cppman_float(query, idx, keyword)
    else
      -- cppman ranks an exact keyword match first, so when the keyword is
      -- still ambiguous the answer to its menu is always 1.
      cppman_float(keyword, n > 1 and 1 or nil, keyword)
    end
  end)
end, { nargs = 1, desc = "cppreference.com page for a C++ symbol" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp" },
  callback = function()
    vim.bo.keywordprg = ":Cppman"
  end,
})
