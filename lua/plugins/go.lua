local function interactive_go_impl()
  -- 1. Grab the word under the cursor to use as the struct/receiver name
  local struct_name = vim.fn.expand("<cword>")
  if struct_name == "" then
    vim.notify("Cursor must be on a struct name", vim.log.levels.WARN)
    return
  end

  -- 2. Derive a lowercase single-letter receiver variable name (Go idiomatic style)
  local receiver_var = string.lower(string.sub(struct_name, 1, 1))

  -- 3. Open a native UI input prompt for the interface target
  vim.ui.input({
    prompt = string.format("Implement interface for %s *%s: ", receiver_var, struct_name),
    default = "io.", -- Pre-fills 'io.' as a helpful starting context
  }, function(input)
    -- Exit quietly if the prompt is cancelled or left blank
    if not input or input == "" then
      return
    end

    -- 4. Execute the command: GoImpl <receiver> *<Struct> <Interface>
    vim.cmd(string.format("GoImpl %s *%s %s", receiver_var, struct_name, input))
  end)
end

return {
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>cgf", "<cmd>GoFillStruct<cr>", ft = "go", desc = "Go Fill Struct (go.nvim)" },
      { "<leader>cge", "<cmd>GoIfErr<cr>", desc = "Go If Err" },
      { "<leader>cgt", "<cmd>GoAddTag json<cr>", desc = "Go Add JSON Tags" },
      { "<leader>cgi", interactive_go_impl, ft = "go", desc = "Go Implement Interface" },
    },
    -- Lazy will automatically pass this table directly into require("go").setup(opts)
    opts = {
      -- 1. LSP & Diagnostics (Prevents colliding with your gopls config)
      lsp_cfg = false,
      lsp_on_attach = false,
      lsp_diag = false,
      lsp_document_formatting = false,
      lsp_inlay_hints = {
        enable = false, -- this is the only field apply to neovim > 0.10
      },

      -- 2. Formatting & Imports (Stops go.nvim from altering code on save)
      lsp_gofmt = false, -- Disables go.nvim default formatting engine
      goimport = "", -- Explicitly disables go.nvim's import engine completely

      -- 3. Keymaps (Stops the plugin from overriding any LazyVim shortcuts)
      gofmt = false, -- Disables the default format map
      textobjects = false, -- Disables taking over structural selection keys

      -- 4. Safe UI Defaults
      floating = true,
    },
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },
}
