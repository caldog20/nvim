local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofumpt", "golines", "goimports" },
    python = { "black" },
    cpp = { "clang-format" },
    c = { "clang-format" },
    yaml = { "yamlfix" },
    typescript = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
    javascript = { "prettierd", "prettier" },
    javascriptreact = { "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    html = { "prettierd", "prettier" },
    css = { "prettierd", "prettier" },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  -- formatters = {
  --   black = {
  --     command = "black",
  --     args = {"--line-length", "80"},
  --   },
  -- },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
