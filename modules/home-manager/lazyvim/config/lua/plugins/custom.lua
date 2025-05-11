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
      "nvim-neotest/neotest-jest",
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
      }
    end,
  },
}
