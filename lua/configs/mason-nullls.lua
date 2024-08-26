-- mason-null-ls is only used to automatically install formatters
-- null-ls has been replaced by conform.nvim for formatting configuration
-- <leader>fm calls confirm:format() for proper formatting
-- see config/conform.lua for formatting options
return {
  ensure_installed = {
    "clang-format",
    "black",
    "goimports",
    "golines",
    "gofumpt",
    "stylua",
    "yamlfix",
    "prettier",
    "prettierd",
  },
  automatic_installation = false,
  handlers = {
    function() end,
  },
}
