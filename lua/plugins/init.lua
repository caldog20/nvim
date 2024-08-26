local plugins = {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform"
  },                       -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end
  }, { "nvim-treesitter/nvim-treesitter", opts = require "configs.treesitter" },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = function() return require "configs.mason-lspconfig" end,
    config = function(_, opts) require("mason-lspconfig").setup(opts) end
  }, {
  "lewis6991/gitsigns.nvim",
  opts = function()
    local conf = require "nvchad.configs.gitsigns"
    conf.signs = {
      add = { text = "+" },
      change = { text = "│" },
      delete = { text = "-" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "u" }
    }
    conf.current_line_blame = true
    conf.current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
      virt_text_priority = 100
    }
    conf.current_line_blame_formatter =
    '<author>, <author_time:%Y-%m-%d> - <summary>'
    return conf
  end
}, {
  "windwp/nvim-ts-autotag",
  config = function() require('nvim-ts-autotag').setup() end,
  lazy = false
}, { "tpope/vim-fugitive",           lazy = false }, { "mfussenegger/nvim-dap" }, {
  "dreamsofcode-io/nvim-dap-go",
  ft = "go",
  dependencies = "mfussenegger/nvim-dap",
  config = function(_, opts) require("dap-go").setup(opts) end
}, {
  "olexsmir/gopher.nvim",
  ft = "go",
  config = function(_, opts)
    require("gopher").setup(opts)
    -- require("core.utils").load_mappings("gopher")
  end,
  build = function() vim.cmd [[silent! GoInstallDeps]] end
}, {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  event = "VeryLazy",
  opts = {},
  config = function() require("harpoon").setup(opts) end
}, { "christoomey/vim-tmux-navigator", lazy = false }, {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuration here, or leave empty to use defaults
    })
  end
}, {
  "ggandor/leap.nvim",
  config = function() require("leap").add_default_mappings() end,
  lazy = false
}, {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  lazy = false
}, {
  "folke/trouble.nvim",
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = "Trouble",
  keys = {
    {
      "<leader>qQ",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)"
    }, {
    "<leader>qq",
    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    desc = "Buffer Diagnostics (Trouble)"
  }, {
    "<leader>cs",
    "<cmd>Trouble symbols toggle focus=false<cr>",
    desc = "Symbols (Trouble)"
  }, {
    "<leader>cl",
    "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
    desc = "LSP Definitions / references / ... (Trouble)"
  }, {
    "<leader>q",
    "<cmd>Trouble loclist toggle<cr>",
    desc = "Location List (Trouble)"
  }, {
    "<leader>qf",
    "<cmd>Trouble qflist toggle<cr>",
    desc = "Quickfix List (Trouble)"
  }
  }
}, {
  "kevinhwang91/nvim-ufo",
  event = "BufRead",
  dependencies = {
    { "kevinhwang91/promise-async" }, {
    "luukvbaal/statuscol.nvim",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        -- foldfunc = "builtin",
        -- setopt = true,
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { text = { "%s" },             click = "v:lua.ScSa" },
          {
            text = { builtin.lnumfunc, " " },
            click = "v:lua.ScLa"
          }
        }
      })
    end
  }
  },
  config = function()
    -- Fold options
    vim.o.fillchars =
    [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    vim.o.foldcolumn = "1" -- '0' is not bad
    vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    require("ufo").setup()
    vim.keymap.set("n", "q", "za", { desc = "Fold toggle" })
  end
}, {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter"
  },
  config = function()
    require("refactoring").setup({
      prompt_func_return_type = { go = true },
      prompt_func_param_type = { go = true }
    })
    require("telescope").load_extension("refactoring")
    vim.keymap.set({ "n", "x" }, "<leader>rr", function()
      require('telescope').extensions.refactoring.refactors()
    end)
  end,
  lazy = false
}, {
  "nvim-tree/nvim-tree.lua",
  opts = function()
    local conf = require "nvchad.configs.nvimtree"
    conf.filters = { dotfiles = false }
    conf.git = { enable = true, ignore = false }
    conf.view = {
      width = 30,
      adaptive_size = true,
      preserve_window_proportions = true
    }
    conf.actions = { open_file = { resize_window = false } }
    conf.renderer.icons.show = { git = true }
    conf.renderer.icons.glyphs.git.untracked = ""
    return conf
  end
}, {
  "ptdewey/yankbank-nvim",
  lazy = false,
  dependencies = "kkharji/sqlite.lua",
  opts = function() return require "configs.yankbank" end,
  config = function(_, opts) require('yankbank').setup(opts) end
},
  {
    "jay-babu/mason-null-ls.nvim",
    event = {},
    dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
    opts = function() return require "configs.mason-nullls" end,
    config = function(_, opts) require("mason-null-ls").setup(opts) end,
    lazy = false,
  }
}

return plugins
