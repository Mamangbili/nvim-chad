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
		NeogitDiffDeleteInline = { bg = "" },
		NeogitDiffAddInline = { bg = "" },
		["OdinProcLine"] = { bg = "#2b303c" },
	},
	hl_override = {
		DiffAdd = { bg = "#006614" },
		DiffRemoved = { bg = "#491204" },
		DiffDelete = { bg = "#491204" },
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

local ns_id = vim.api.nvim_create_namespace("odin_proc_lines")

local function highlight_odin_procedures(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "odin")
	if not ok or not parser then
		return
	end

	local tree = parser:parse()[1]
	local root = tree:root()

	-- Target the actual 'procedure' token inside the declaration block
	local query = vim.treesitter.query.parse(
		"odin",
		[[
    (procedure_declaration (procedure) @proc_token)
  ]]
	)

	for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
		if query.captures[id] == "proc_token" then
			-- This will get the row where 'proc "contextless"' is written
			local start_row, _, _, _ = node:range()

			-- Highlight that specific line all the way across the screen
			vim.api.nvim_buf_set_extmark(bufnr, ns_id, start_row, 0, {
				line_hl_group = "OdinProcLine",
				priority = 10,
			})
		end
	end
end

-- Re-trigger whenever the file is loaded or changed
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged" }, {
	pattern = "*.odin",
	callback = function(ev)
		highlight_odin_procedures(ev.buf)
	end,
})
return M
