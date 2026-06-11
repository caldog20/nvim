-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" }) -- vim: ts=2 sts=2 sw=2 et
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u", "<C-u>zz")
vim.keymap.set("n", "Q", "<nop>", { remap = true })
vim.keymap.set("n", "q", "<NOP>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dd", [["_dd]], { desc = "Delete noreg" })
vim.keymap.set("v", "<leader>dd", [["_d]], { desc = "Delete visual noreg" })

-- substitute
vim.keymap.set("n", "s", require("substitute").operator, { desc = "substitute", noremap = true })
vim.keymap.set("n", "ss", require("substitute").line, { desc = "substitute line", noremap = true })
vim.keymap.set("n", "S", require("substitute").eol, { desc = "substitute eol", noremap = true })
vim.keymap.set("x", "s", require("substitute").visual, { desc = "substitute visual", noremap = true })
vim.keymap.set("n", "sx", require("substitute.exchange").operator, { desc = "substitute exchange", noremap = true })
vim.keymap.set("n", "sxx", require("substitute.exchange").line, { desc = "substitute exchange line", noremap = true })
vim.keymap.set("x", "X", require("substitute.exchange").visual, { desc = "substitute exchange visual", noremap = true })
vim.keymap.set(
  "n",
  "sxc",
  require("substitute.exchange").cancel,
  { desc = "substitute exchange cancel", noremap = true }
)

local go = require("util.go")
vim.keymap.set("n", "<leader>ct", go.mod_tidy, { desc = "Run go mod tidy", silent = true })
