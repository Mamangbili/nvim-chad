-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "vscode_dark",
	transparency = true,
	hl_add = {
		["@constructor.cpp"] = { underline = false },
		["SnacksPickerDir"] = { fg = "#2239e9" },
		["@lsp.type.operator.cpp"] = { fg = "purple" },
		["@tag.builtin.tsx"] = { fg = "#0885c4" },
		["@lsp.type.macro.cpp"] = { fg = "NONE" },
		["@lsp.typemod.class.constructorOrDestructor.cpp"] = { fg = "#9e9e41", bold = true },
	},
	hl_override = {
		DiffAdd = { bg = "#457341" },
		DiffRemoved = { bg = "#c23232" },
		DiffDelete = { bg = "#c23232" },
		LineNr = { fg = "#6d7d72" },
		TelescopeSelection = {
			bg = "#424141",
		},
		CursorLine = {
			bg = "#424141",
		},
		Visual = {
			bg = "#424141",
		},
		["snack.pciker.list"] = { fg = "red" },
		["LspSignatureActiveParameter"] = {
			underline = true,
			fg = "NONE",
			italic = true,
			bold = true,
			standout = true,
			bg = "NONE",
		},
		["@function"] = { underline = false, nocombine = true },
		["@comment"] = { italic = true, fg = "#6d7d72" },
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
		-- ["@constant.macro"] = { fg = "None" },
		["@character"] = { fg = "base0B" },
		["@markup.link.label"] = { fg = "purple" },
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
		enabled = false,
		lazyload = true,
		order = { "buffers" },
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
			"clock",
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
			clock = function()
				return " " .. os.date("%H:%M")
			end,
		},
	},
}

M.colorify = {
	enabled = false,
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
