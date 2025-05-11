local function find_vitest_root()
  local root = vim.fn.expand("%:p:h")
  while root ~= "/" do
    if
      vim.fn.filereadable(root .. "/vitest.config.ts") == 1
      or vim.fn.filereadable(root .. "/vitest.config.js") == 1
      or vim.fn.filereadable(root .. "/package.json") == 1
    then
      return root
    end
    root = vim.fn.fnamemodify(root, ":h")
  end
  return vim.fn.getcwd() -- fallback
end

return {
  { "williamboman/mason.nvim", enabled = false },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        nix = { "alejandra" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {
          cwd = find_vitest_root,
        },
      },
    },
  },
  { "nvim-neotest/neotest-jest" },
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(
        opts.adapters,
        require("neotest-jest")({
          jestCommand = "pnpm test --",
          jestConfigFile = "custom.jest.config.ts",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        })
      )
    end,
  },
}
