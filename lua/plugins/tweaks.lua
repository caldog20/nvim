return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<Shift><Tab>"] = { "select_prev", "fallback" },
      },
    },
  },

  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>/", false },
      {
        "<leader>e",
        function()
          local explorer_win = nil

          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            if ft == "snacks_picker_list" then
              explorer_win = win
              break
            end
          end

          if vim.api.nvim_get_current_win() ~= explorer_win and explorer_win then
            vim.api.nvim_set_current_win(explorer_win)
          else
            Snacks.explorer()
          end
        end,
        desc = "Snacks File Explorer",
      },
    },
    opts = {
      picker = {
        -- win = {
        --   input = {
        --     keys = {
        --       ["<C-h>"] = { "<C-w>h", expr = true, mode = { "n" } },
        --       ["<C-l>"] = { "<C-w>l", expr = true, mode = { "n" } },
        --     },
        --   },
        -- },
        sources = {
          -- files = {
          --   hidden = true,
          --   ignored = false,
          --   args = {
          --     "--glob",
          --     "!{node_modules,build,dist,.git}",
          --   },
          -- },
          grep = {
            hidden = true,
            ignored = true,
          },
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        inlay_hints = {
          enabled = false,
        },
        servers = {
          gopls = {
            settings = {
              gopls = {
                analyses = {
                  ST1000 = false,
                  ST1021 = false,
                },
              },
            },
          },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
        "go",
        "python",
      })
    end,
  },
}
