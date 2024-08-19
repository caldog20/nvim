-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua
---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "bearded-arc",
    -- transparency = true,
    hl_override = {
        -- GitSignsCurrentLineBlame = {fg = "white"},
        NonText = {fg = "#8a7e62"},
        Comment = {fg = "#8a7e62"}
        -- ["@parameter"] = {fg = "white"},
        -- ["@property"] = {fg = "white"},
        -- ["@variable.go"] = {fg = "white"},
        -- Identifier = {fg = "white"}
        -- ["@comment"] = {fg = "white"},
    },
    changed_themes = {
        gruvbox = {
            base_16 = {
                -- base00 = "#1B1C1A",
                base00 = "#1e1f21"
            }
        }
    }
}

M.ui = {
    statusline = {theme = "default"},

    nvdash = {
        load_on_startup = true,

        header = {
            "███╗░░██╗██╗░░░██╗██╗███╗░░░███╗",
            "████╗░██║██║░░░██║██║████╗░████║",
            "██╔██╗██║╚██╗░██╔╝██║██╔████╔██║",
            "██║╚████║░╚████╔╝░██║██║╚██╔╝██║",
            "██║░╚███║░░╚██╔╝░░██║██║░╚═╝░██║",
            "╚═╝░░╚══╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝"
        },
        buttons = {
            {"  Find File", "Spc f f", "Telescope find_files"},
            {"󰈚  Recent Files", "Spc f o", "Telescope oldfiles"},
            {"󰈭  Live Grep", "Spc f w", "Telescope live_grep"},
            {"  Bookmarks", "Spc m a", "Telescope marks"},
            {"  Themes", "Spc t h", "Telescope themes"},
            {"  Mappings", "Spc c h", "NvCheatsheet"}
        }
    }

}

M.cheatsheet = {theme = "simple"}

return M
