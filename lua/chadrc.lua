-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "vscode_dark",
    transparency = true,
    hl_add = {
        ["@constructor.cpp"] = { underline = true },
        ["SnacksPickerDir"] = { fg = "#2239e9" },
    },
    hl_override = {
        ["snack.pciker.list"] = { fg = "red" },
        ["LspSignatureActiveParameter"] = { underline = true, fg = "NONE", italic = true, bold = true, standout = true },
        ["@function"] = { underline = false, nocombine = true },
        ["@comment"] = { italic = true },
        Type = { fg = "#26d988", bold = false },
        ["@type.builtin"] = { fg = "#26d988", bold = false },
        ["@variable.builtin"] = { fg = "base08" },
        ["@variable.parameter"] = { fg = "base08" },
        ["@variable.member"] = { fg = "#0885c4" },
        ["@property"] = { fg = "#0885c4" },
        ["@constructor"] = { fg = "base0D" },
        ["@module"] = { fg = "#09a530" },
        ["@type.cpp"] = { fg = "#ff0000" },
        ["@keyword.repeat"] = { fg = "purple" },
        ["@keyword"] = { fg = "#5252e0" },
        ["@constant"] = { fg = "#2239e9", bold = true },
        ["@constant.macro"] = { fg = "#2239e9" },
        ["@character"] = { fg = "base0B" },
    },
    --
    changed_themes = {
        vscode_dark = {
            base_16 = {
                base08 = "#6dcbf9",
                base0B = "#c27246",
                base09 = "#73ad9e",
                -- base0D = "#dcdcaa",
            },
        },
    },
}

local recordingStartSeparator = "%#RecSeparatorStartStyle#" .. "< "
local recordingEndSeparator = "%#RecSeparatorEndStyle#" .. " >"

M.ui = {
    telescope = {
        style = "borderless",
    },
    tabufline = {
        lazyload = false,
    },
    statusline = {
        theme = "default",
        separator_style = "default",
        order = {
            "mode",
            "file",
            "git",
            "recording",
            "%=",
            "lsp_msg",
            "%=",
            "lsp",
            "diagnostics",
            "cwd",
            "cursor",
        },
        modules = {
            recording = function()
                local rec = vim.fn.reg_recording()
                return rec ~= ""
                        and " " .. recordingStartSeparator .. "%#RecIndicatorStyle#" .. "Recording @" .. rec .. recordingEndSeparator
                    or ""
            end,
        },
    },
}

M.colorify = {
    enabled = false,
    mode = "fg", -- fg, bg, virtual
    highlight = { hex = true, lspvars = true },
}

M.term = {
    float = {
        col = 0.05,
        row = 0.02,
        width = 0.9,
        height = 0.9,
    },
}

M.plugin = {}

return M
