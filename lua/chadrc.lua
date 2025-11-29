-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "vscode_dark",
  transparency = true,

  hl_override = {
    --   Comment = { italic = true },
    ["@comment"] = { italic = true },
    Type = { fg = "#26d988", bold = false },
    ["@type.builtin"] = { fg = "#26d988", bold = false },
    ["@variable.builtin"] = { fg = "base08" },
    ["@variable.parameter"] = { fg = "base08" },
    ["@constructor"] = { fg = "base0D" },
    ["@module"] = { fg = "#26d988" },
    ["@keyword.repeat"] = { fg = "purple" },
    ["@keyword"] = { fg = "#5252e0" },
    ["@constant"] = { fg = "#2239e9", bold = true },
  },
  --
  changed_themes = {
    vscode_dark = {
      base_16 = {
        base08 = "#6dcbf9",
        base0B = "#c27246",
        base09 = "#73ad9e",
        base0D = "#dcdcaa",
      },
    },
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
---- Place in init.lua
-- This ensures your "Namespace" rules beat the default "Uppercase = Type" rule

return M
