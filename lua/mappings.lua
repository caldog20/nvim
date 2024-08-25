require "nvchad.mappings"

local M = {}

M.dap = {
    --   plugin = true,
    n = {
        ["<leader>db"] = {
            "<cmd> DapToggleBreakpoint <CR>", "Dap Add breakpoint at line"
        },
        ["<leader>dus"] = {
            function()
                local widgets = require('dap.ui.widgets');
                local sidebar = widgets.sidebar(widgets.scopes);
                sidebar.open();
            end, "Dap Open debugging sidebar"
        }
    }
}

M.dap_go = {
    --   plugin = true,
    n = {
        ["<leader>dgt"] = {
            function() require('dap-go').debug_test() end, "Dap Debug go test"
        },
        ["<leader>dgl"] = {
            function() require('dap-go').debug_last() end,
            "Dap Debug last go test"
        }
    }
}

M.gopher = {
    --   plugin = true,
    n = {
        ["<leader>gsj"] = {
            "<cmd> GoTagAdd json <CR>", "Gopher Add json struct tags"
        },
        ["<leader>gsy"] = {
            "<cmd> GoTagAdd yaml <CR>", "Gopher Add yaml struct tags"
        }
    }
}

M.caleb = {
    v = {
        ["J"] = {":m '>+1<CR>gv=gv", "Caleb Move selected line down"},
        ["K"] = {":m '<-2<CR>gv=gv", "Caleb Move selected line down"},
        ["<leader>y"] = {'"+y', "Caleb Yank to System"},
        ["<leader>p"] = {'\"_dP', "Caleb Paste overwrite register"},
        ["<leader>Y"] = {'"+Y', "Caleb Yank to System"},
        ["<leader>P"] = {'"+P', "Caleb Paste to System"}
    },

    n = {
        ["<leader>s"] = {
            ":%s/<C-r><C-w>//g<Left><Left>", "Caleb Search and replace"
        },
        -- ["<leader>s"] = { '[[:%s/<<C-r><C-w>>/<C-r><C-w>/gI<Left><Left><Left>]]' },
        ["{"] = {"<C-d>zz", "Caleb Scroll and Center"},
        ["}"] = {"<C-u>zz", "Caleb Scroll and Center"},
        ["<C-d"] = {"<C-d>zz", "Caleb Scroll down and center cursor"},
        ["<C-u"] = {"<C-u>zz", "Caleb Scroll up and center cursor"},
        ["Q"] = {"<nop>"},
        ["<leader>y"] = {'"+y', "Caleb Yank to System"},
        ["<leader>p"] = {'"+p', "Caleb Paste from System"},
        ["<leader>Y"] = {'"+Y', "Caleb Yank to System"},
        ["<leader>P"] = {'"+P', "Caleb Paste from System"},
        ["<leader>w"] = {"<C-w>w", "Caleb Next Window"}
    }
}

M.navi = {
    n = {
        ["<C-h>"] = {"<cmd> TmuxNavigateLeft<CR>", "Navigation window left"},
        ["<C-l>"] = {"<cmd> TmuxNavigateRight<CR>", "Navigation window right"},
        ["<C-j>"] = {"<cmd> TmuxNavigateDown<CR>", "Navigation window down"},
        ["<C-k>"] = {"<cmd> TmuxNavigateUp<CR>", "Navigation window up"}
    }
}

local harpoon = require("harpoon")
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local make_finder = function()
        local paths = {}
        for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
        end

        return require("telescope.finders").new_table({results = paths})
    end
    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = make_finder(),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_buffer_number, map)
            -- The keymap you need
            map("n", "dd", function()
                local state = require("telescope.actions.state")
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(
                                           prompt_buffer_number)

                -- This is the line you need to remove the entry
                harpoon:list():remove(selected_entry)
                current_picker:refresh(make_finder())
            end)

            return true
        end
    }):find()
end

M.harpoon = {
    -- plugin = true,
    n = {
        ["<leader>m"] = {
            function() harpoon:list():add() end, "Harpoon Mark file"
        },
        ["<leader>'"] = {
            function()
                toggle_telescope(harpoon:list())
                -- harpoon.ui:toggle_quick_menu(harpoon:list())
            end, "Harpoon Toggle list"
        },
        ["<leader>1"] = {
            function() harpoon:list():select(1) end,
            "Harpoon Navigate to file 1"
        },
        ["<leader>2"] = {
            function() harpoon:list():select(2) end,
            "Harpoon Navigate to file 2"
        }
    }
}

M.todo = {
    n = {
        ["<leader>ft"] = {"<cmd> TodoTelescope<CR>", "Telescope Find all TODOs"}
    }
}

M.git = {
    n = {
        ["<leader>gp"] = {
            "<cmd> Git push<CR>", "Git Push git changes to remote"
        },
        ["<leader>ga"] = {
            "<cmd> Gwrite<CR>", "Git Add current file to stage list"
        },
        ["<leader>gg"] = {"<cmd> Git<CR>", "Git Open vim-fugitive buffer"},
        ["<leader>gc"] = {
            "<cmd> Git commit<CR>", "Git Commit currently staged changes"
        }
    }
}

local map = vim.keymap.set

-- Loop through old mapping table above
for name, maps in pairs(M) do
    for mode, data in pairs(maps) do
        for key, val in pairs(data) do
            map(mode, key, val[1], {desc = val[2]})
        end
    end
end

map("n", ";", ":", {desc = "CMD enter command mode"})
map("i", "jk", "<ESC>")
map("n", "<leader>y", "<cmd>YankBank<CR>",
    {noremap = true, desc = "YankBank Open"})

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
