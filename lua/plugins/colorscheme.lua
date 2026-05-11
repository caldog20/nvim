return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  { "projekt0n/github-nvim-theme", name = "github-theme" },
  -- Configure LazyVim to load gruvbox
  --
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("monokai-pro").setup()
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false, -- Load immediately
    priority = 1000, -- Load before other plugins
    opts = {
      -- style = "night",
      styles = {
        keywords = { italic = false },
        comments = { italic = false },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
