-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "vscode_dark",
  transparency = true,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.ui = {
  telescope = {
    style = "borderless",
  },
  tabufline = {
    lazyload = false,
  },
}
M.colorify = {
  enabled = false,
}

M.term = {
  float = {
    col = 0.2,
    row = 0.2,
    width = 0.6,
    height = 0.6,
  },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--   theme="gruvbox",
--       tabufline = {
--          lazyload = false
--      }
-- }
--
--

return M
