return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- opts.snippets = { preset = "default" }

      -- Prevent blink from automatically writing the preselected completion into
      -- the buffer. Without this, InsertEnter fires when a snippet activates and
      -- blink immediately auto-inserts over the first tab-stop placeholder.
      opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
        list = { selection = { auto_insert = false } },
      })

      -- Snippet navigation takes priority over completion selection so Tab
      -- always jumps between fields even when the blink popup is open.
      opts.keymap = {
        preset = "enter",
        ["<Tab>"] = {
          function()
            if vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
              return true -- jump() returns nil; explicit true prevents blink from
            end -- falling through to "fallback" (LazyVim's native snippet
          end, -- jump binding), which would double-jump every field.
          "select_next",
          "fallback",
        },
        ["<S-Tab>"] = {
          function()
            if vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
              return true
            end
          end,
          "select_prev",
          "fallback",
        },
      }
    end,
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
      styles = {
        notification = {
          width = { min = 60, max = 0.5 },
          height = { min = 3, max = 0.6 },
          wo = { wrap = true },
        },
      },
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
          files = {
            hidden = true,
            --   ignored = false,
            --   args = {
            --     "--glob",
            --     "!{node_modules,build,dist,.git}",
            --   },
          },
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
        diagnostics = { virtual_text = false },
        inlay_hints = {
          enabled = false,
        },
        servers = {
          gopls = {
            settings = {
              gopls = {
                usePlaceholders = true,
                completionOptions = {
                  postfix = true,
                  completeUnimported = true,
                },
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
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        prettier = {
          prepend_args = { "--ignore-path", "" },
        },
      },
    },
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
        "markdown",
        "markdown_inline",
        "yaml",
        "html",
        "lua",
        "json",
        "javascript",
        "bash",
        "regex",
        "sql",
        "c",
        "cpp",
        "zsh",
        "zig",
        "groovy",
        "helm",
        "glsl",
        "gitignore",
        "dockerfile",
        "csv",
        "css",
        "cmake",
        "c_sharp",
        "asm",
        "make",
      })
    end,
  },
}
