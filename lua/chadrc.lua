-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua
---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "monochrome",
  -- transparency = true,
  hl_override = {
    -- GitSignsCurrentLineBlame = {fg = "white"},
    NonText = { fg = "#8a7e62" },
    Comment = { fg = "#8a7e62" },
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
        base00 = "#1e1f21",
      },
    },
  },
}

M.ui = {
  statusline = { theme = "default" },
}

M.nvdash = {
  load_on_startup = true,

  header = {
    "███╗░░██╗██╗░░░██╗██╗███╗░░░███╗",
    "████╗░██║██║░░░██║██║████╗░████║",
    "██╔██╗██║╚██╗░██╔╝██║██╔████╔██║",
    "██║╚████║░╚████╔╝░██║██║╚██╔╝██║",
    "██║░╚███║░░╚██╔╝░░██║██║░╚═╝░██║",
    "╚═╝░░╚══╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝",
    "                                ",
  },
  buttons = {
    { txt="  Find File", keys="Spc f f", cmd="Telescope find_files" },
    { txt="󰈚  Recent Files", keys="Spc f o", cmd="Telescope oldfiles" },
    { txt="󰈭  Live Grep", keys="Spc f w", cmd="Telescope live_grep" },
    { txt="  Bookmarks", keys="Spc m a", cmd="Telescope marks" },
    { txt="  Themes", keys="Spc t h", cmd="Telescope themes" },
    { txt="  Mappings", keys="Spc c h", cmd="NvCheatsheet" },
  },
}

-- M.cheatsheet = { theme = "simple" }

return M
