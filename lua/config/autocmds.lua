-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local go = require("util.go")
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

local function register_fill_struct(buf)
  vim.keymap.set("n", "<leader>cv", go.fill_struct_snippet, {
    buffer = buf,
    desc = "Fill struct with snippet tab-stops",
  })
end

-- LspAttach fires after gopls connects, well after VeryLazy loads this file.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("go_fill_struct", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "gopls" then
      register_fill_struct(ev.buf)
    end
  end,
})

-- Cover any Go buffers that already had gopls attached before this file loaded.
for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
  for buf in pairs(client.attached_buffers) do
    register_fill_struct(buf)
  end
end

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "go", "lua", "python" },
--   callback = function()
--     vim.opt_local.formatoptions:append("tc")
--   end,
-- })
