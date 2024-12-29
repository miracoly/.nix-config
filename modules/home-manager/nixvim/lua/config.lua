(function(vim)
  -- Overseer
  local overseer = require("overseer")

  overseer.setup({
    task_list = {
      -- Define default direction for the task list window
      direction = "bottom", -- Opens the task list in a horizontal split
      min_height = 10,   -- Minimum height for the task list window
      max_height = 10,   -- Maximum height for the task list window
      default_detail = 1,
    },
  })

  vim.api.nvim_create_user_command("OverseerRestartLastAndOpen", function()
    local tasks = overseer.list_tasks({ recent_first = true })
    if vim.tbl_isempty(tasks) then
      vim.notify("No tasks found", vim.log.levels.WARN)
    else
      overseer.run_action(tasks[1], "restart")
      overseer.open({ enter = false })
    end
  end, {})

  local cmp = require("cmp")

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ "/", "?" }, {
    sources = {
      { name = "buffer" },
    },
  })
  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(":", {
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })

  -- Outline
  require("outline").setup({})

  -- Telescope Haskell
  local telescope = require("telescope")
  telescope.setup({})
  telescope.load_extension("hoogle")

  -- dap
  local dap, dapui = require("dap"), require("dapui")
  dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "8123",
    executable = {
      command = "js-debug",
    },
  }

  dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
  }

  dap.configurations.c = {
    {
      name = "Launch",
      type = "gdb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopAtBeginningOfMainSubprogram = false,
    },
    {
      name = "Select and attach to process",
      type = "gdb",
      request = "attach",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      pid = function()
        local name = vim.fn.input("Executable name (filter): ")
        return require("dap.utils").pick_process({ filter = name })
      end,
      cwd = "${workspaceFolder}",
    },
    {
      name = "Attach to gdbserver :1234",
      type = "gdb",
      request = "attach",
      target = "localhost:1234",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
    },
  }

  for _, language in ipairs({ "typescript", "javascript" }) do
    dap.configurations[language] = {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    }
  end

  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end
  ---@diagnostic disable-next-line: undefined-global 
end)(vim)
