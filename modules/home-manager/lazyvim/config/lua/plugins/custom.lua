local function find_root(files)
  return function()
    local root = vim.fn.expand("%:p:h")
    while root ~= "/" do
      for _, file in ipairs(files) do
        if vim.fn.filereadable(root .. "/" .. file) == 1 then
          return root
        end
      end
      root = vim.fn.fnamemodify(root, ":h")
    end
    return vim.fn.getcwd()
  end
end

return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
  { "mfussenegger/nvim-dap-python", enabled = false },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {
          filetypes = { "sh", "bash", "zsh", "bats" },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = false, -- ← wipes the chain built so far
  },
  {
    "3rd/image.nvim",
    build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
    commit = "4206c48",
    opts = {
      processor = "magick_cli",
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        nix = { "alejandra" },
        sql = { "sqlfluff" },
      },
      formatters = {
        sqlfluff = {
          command = "sqlfluff",
          args = { "format", "--dialect=ansi", "-" },
          stdin = true,
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },
        bats = { "shellcheck" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
      "fredrikaverpil/neotest-golang",
    },
    opts = function(_, opts)
      opts.adapters = {
        require("neotest-vitest")({
          cwd = find_root({
            "vitest.config.ts",
            "vitest.config.js",
            "package.json",
          }),
        }),
        require("neotest-jest")({
          cwd = find_root({
            "jest.config.ts",
            "jest.config.js",
            "package.json",
          }),
          env = { CI = true },
        }),
        ["neotest-golang"] = {
          dap_go_enabled = true,
        },
      }
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = nil,
    opts = function()
      local dap = require("dap")

      dap.adapters["pwa-node"] = nil
      dap.adapters["node"] = nil
      dap.adapters["codelldb"] = nil
      dap.adapters["debugpy"] = nil

      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = {
          "--interpreter=dap",
          "--eval-command",
          "set print pretty on",
        },
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

      dap.configurations.cpp = dap.configurations.c
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        config = function()
          -- Load the extension only after telescope is available
          LazyVim.on_load("telescope.nvim", function()
            require("telescope").load_extension("live_grep_args")
          end)
        end,
      },
    },
    keys = {
      {
        "<leader>sG",
        function()
          require("telescope").extensions.live_grep_args.live_grep_args({ cwd = vim.uv.cwd() })
        end,
        desc = "Grep with Args (cwd)",
      },
    },
  },
}
