local go = require("util.go")

local function register_keymaps(buf)
  vim.keymap.set("n", "<leader>cv", go.fill_struct_snippet, { buffer = buf, desc = "Fill struct with snippet tab-stops" })
  vim.keymap.set("n", "<leader>cgt", go.add_tags, { buffer = buf, desc = "Go Add JSON Tags" })
  vim.keymap.set("n", "<leader>cgi", go.impl, { buffer = buf, desc = "Go Implement Interface" })
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("go_keymaps", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or client.name ~= "gopls" then return end
          register_keymaps(ev.buf)
        end,
      })

      for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
        for buf in pairs(client.attached_buffers) do
          register_keymaps(buf)
        end
      end
    end,
  },
}
