-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.opt.relativenumber = false
vim.g.omni_sql_no_default_maps = 1

vim.opt.wrap = true
vim.opt.linebreak = true -- break at word boundaries, not mid-token
vim.opt.breakindent = true -- wrapped lines maintain indentation
vim.opt.showbreak = "↪ " -- visual indicator for wrapped lines
vim.opt.colorcolumn = "120"
-- LspInfo -> checkhealth vim.lsp
vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd("silent checkhealth vim.lsp")
end, {})
