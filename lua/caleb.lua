local harpoon = require "harpoon"
local tabufline = require "nvchad.tabufline"
local M = {}
local NVIM_TREE_IGNORE = "NvimTree_1"

local function split(pString, pPattern)
  local Table = {} -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pPattern
  local last_end = 1
  local s, e, cap = pString:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(Table, cap)
    end
    last_end = e + 1
    s, e, cap = pString:find(fpat, last_end)
  end
  if last_end <= #pString then
    cap = pString:sub(last_end)
    table.insert(Table, cap)
  end
  return Table
end

local function get_harpoon_files()
  local paths = {}
  local harpoon_files = harpoon:list()

  for _, item in ipairs(harpoon_files.items) do
    table.insert(paths, item.value)
  end

  return paths
end

local function get_buffer_base_filename(bufnum)
  local filepath = vim.api.nvim_buf_get_name(bufnum)
  local splitpath = split(filepath, "/")
  return splitpath[#splitpath]
end

function M.close_buffers_except_harpoon_list()
  local harpoon_files = get_harpoon_files()
  local buffers = vim.api.nvim_list_bufs()

  -- Loop through buffers, get buffer base filename
  -- Compare buffer filename to current harpoon list
  -- If buffer filename isn't in harpoon list, close the buffer
  -- NvimTree buffer is ignored so it doesn't inadvertenly get closed
  for _, bufnum in ipairs(buffers) do
    -- Ensure buffer is actually loaded before trying to operate on it
    if vim.api.nvim_buf_is_loaded(bufnum) then
      local found = false
      -- Get base filename of buffer from full file path
      local filename = get_buffer_base_filename(bufnum)
      -- Check if buffer filename is in harppon list
      for _, file in ipairs(harpoon_files) do
        if file == filename then
          found = true
          break
        end
      end
      -- If not, then lets close the buffer, excluding NvimTree_1 buffer
      -- This will not close buffers with unsaved changes, an error will occur to warn you
      if not found and filename ~= NVIM_TREE_IGNORE then
        -- or if not using nvchad/tabufline then -> vim.api.nvim_buf_delete(bufnum, {})
        tabufline.close_buffer(bufnum)
      end
    end
  end
end

return M
