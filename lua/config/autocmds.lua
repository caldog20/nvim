-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local scratch_root = vim.fn.stdpath("data") .. "/scratch"

-- Prevent linters (golangci-lint etc.) from running on scratch buffers.
-- nvim-lint has no per-buffer disable, so we wrap try_lint after everything loads.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local ok, lint = pcall(require, "lint")
    if not ok then
      return
    end
    local orig = lint.try_lint
    lint.try_lint = function(...)
      if vim.api.nvim_buf_get_name(0):find(scratch_root, 1, true) then
        return
      end
      return orig(...)
    end
  end,
})

