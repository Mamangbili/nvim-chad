require("nvchad.mappings")
local u = require("utils")
local whichkey = require("which-key")
local unmap = vim.keymap.del
local autocmd = vim.api.nvim_create_autocmd

-- Options and settings
vim.opt.timeoutlen = 10000
vim.g.copilot_no_tab_map = true
vim.on_key(u.on_key)

-- Copilot expression map (kept as-is because it bypasses remap intentionally)
vim.api.nvim_set_keymap("i", "<C-K>", "copilot#Accept('<CR>')", { silent = true, expr = true })

-- Handle your delayed unmaps first
vim.defer_fn(function()
	unmap("n", "<leader>n")
end, 1000)
unmap("n", "<leader>th")
unmap("n", "<leader>fo")
unmap("n", "<Tab>")

-- Custom definition window helper function
local function open_definition_on_new_vsp_window()
	local cursor_row, cursor_column = unpack(vim.api.nvim_win_get_cursor(0))
	vim.cmd("vsplit")
	vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_column })
	vim.lsp.buf.definition()
end
local function open_definition_on_new_sp_window()
	local cursor_row, cursor_column = unpack(vim.api.nvim_win_get_cursor(0))
	vim.cmd("split")
	vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_column })
	vim.lsp.buf.definition()
end
local terms = vim.g.nvchad_terms or {}

for key, term in pairs(terms) do
	if term.id == "floatTerm" then
		if not (term.buf and vim.api.nvim_buf_is_valid(term.buf)) then
			terms[key] = nil
		end
		break
	end
end

local function bnext()
	local current = vim.fn.bufnr()
	local buffers = vim.fn.getbufinfo({ buflisted = 1 })

	for i, buf in ipairs(buffers) do
		if buf.bufnr == current then
			if buffers[i + 1] then
				vim.cmd("buffer " .. buffers[i + 1].bufnr)
			end
			return
		end
	end
end

local function bprev()
	local current = vim.fn.bufnr()
	local buffers = vim.fn.getbufinfo({ buflisted = 1 })

	for i, buf in ipairs(buffers) do
		if buf.bufnr == current then
			if buffers[i - 1] then
				vim.cmd("buffer " .. buffers[i - 1].bufnr)
			end
			return
		end
	end
end

-- do not put in which key
vim.keymap.set({ "n", "x" }, "d", '"_d')
vim.keymap.set("n", "D", "dd")
vim.keymap.set("x", "D", "d")

vim.g.VM_Maps = {
	["Transpose"] = "leader-T",
}

-- =============================================================================
-- WHICH-KEY MAPPINGS CONFIGURATION
-- =============================================================================
whichkey.add({
	-- Prefix / Group Definitions
	{ "gv", group = "Definition Actions" },
	{ "<leader>d", group = "Diff Actions" },
	{ "<leader>f", group = "Find / Telescope" },
	{ "<leader>r", group = "Refactor / Rename / Replace" },
	{ "<leader>w", group = "Window / Buffer Management" },

	-- Leader General
	{ "<leader>9", "<cmd>Lazy<Cr>" },
	{ "<leader>ng", "<cmd>Neogit<cr>", desc = "neogit", mode = "n" },
	{
		"<leader>t",
		function()
			local Snacks = require("snacks")
			local explorer_win = nil
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].filetype == "snacks_picker_list" then
					explorer_win = win
					break
				end
			end

			if explorer_win and vim.api.nvim_get_current_win() == explorer_win then
				vim.api.nvim_win_close(explorer_win, true)
			elseif explorer_win then
				vim.api.nvim_set_current_win(explorer_win)
			else
				Snacks.explorer({ focus = "list" })
			end
		end,
		desc = "nvimtree toggle window",
		mode = "n",
	},

	-- { "<leader>q", ":bdelete<Cr>", desc = "Delete/quit", mode = "n" },
	{ "<leader>y", ":setf cpp<Cr>", desc = "setfile to cpp", mode = "n" },

	-- Leader d (Diff)
	{ "<leader>dq", "<cmd>DiffviewClose<cr>", desc = "close diff", mode = "n" },

	-- Leader f (Find / Telescope)
	{ "<leader>fd", "<cmd>Glance definitions<cr>", desc = "glance definitions", mode = "n" },
	{ "<leader>fo", "<Cmd>Telescope hierarchy outgoing_calls<Cr>", desc = "outgoing call ", mode = "n" },
	{ "<leader>ft", "<Cmd>Telescope treesitter<Cr>", desc = "outgoing call ", mode = "n" },

	-- Leader w (Window / Buffer)
	{
		"<leader>ww",
		function()
			u.Close_window()
		end,
		desc = "close window",
		mode = "n",
	},
	{ "<leader>h", u.telescope_hsplit, desc = "new horizontal window", mode = "n" },
	{ "<leader>v", u.telescope_vsplit, desc = "new vertical window", mode = "n" },
	{ "<leader>wb", ":BDeleteOthers<CR>", desc = "delete all buffer except current", mode = "n" },

	-- Leader r (Refactor / Rename / Replace)
	{ "<leader>ra", vim.lsp.buf.rename, desc = "lsp rename", mode = "n" },
	{
		"<leader>rr",
		function()
			vim.fn.feedkeys(":.,$s/\\v", "n")
		end,
		desc = "substitute until end",
		mode = { "n" },
	},
	{
		"<leader>rr",
		function()
			vim.fn.feedkeys(":s/\\v", "n")
		end,
		desc = "substitute block",
		mode = { "x" },
	},
	{
		"<leader>rf",
		function()
			vim.lsp.buf.code_action({})
		end,
		desc = "code action",
		mode = { "n", "v", "x" },
	},

	-- Utilities / Clipboard
	{
		"<leader>cp",
		function()
			local path = vim.fn.expand("%:p")
			vim.fn.setreg("+", path)
			vim.notify("Copied: " .. path)
		end,
		desc = "Copy current buffer path",
		mode = "n",
	},

	-- Insert Mode Maps
	{
		"<C-i>",
		function()
			require("cmp").complete()
		end,
		desc = "show autocompletion",
		mode = "i",
	},
	{ "<C-h>", "<C-w>", mode = "i" },
	{ "jk", "<Esc>`^", mode = "i" },

	-- Visual Mode Maps
	{ "r", "<nop>", mode = "v" },
	{ "rb", ":s/", desc = "substitute in block", mode = "v" },

	-- Terminal Mode Maps
	{ "<F9>", require("nvchad.tabufline").close_buffer, desc = "terminal toggle floating term", mode = "t" },

	-- Hybrid Modes (Alt/Ctrl binds across multiple modes)
	{ "<A-t>", "<cmd>terminal<CR>", desc = "enter terminal mode", mode = { "n", "i" } },
	{
		"<A-/>",
		function()
			require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
		end,
		desc = "terminal toggleable horizontal term",
		mode = { "n", "t" },
	},
	{
		"<A-i>",
		function()
			require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
		end,
		desc = "terminal toggle floating term",
		mode = { "n", "t" },
	},

	{ "<C-u>", "15<C-y>", desc = "scroll up", mode = { "n", "v", "t" } },
	{ "<C-d>", "15<C-e>", desc = "scroll down", mode = { "n", "v", "t" } },

	-- Global 'g' Shortcuts
	{ "gvd", open_definition_on_new_vsp_window, desc = "open definition on new vsp window", mode = "n" },
	{ "ghd", open_definition_on_new_sp_window, desc = "open definition on new sp window", mode = "n" },
	{ "gi", vim.lsp.buf.implementation, desc = "lsp implementation", mode = "n" },
	{ "gd", vim.lsp.buf.definition, desc = "lsp definition", mode = "n" },
	{ "gD", vim.lsp.buf.declaration, desc = "lsp declaration", mode = "n" },

	-- Navigation & Editing Adjustments

	{
		"t",
		function()
			require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
		end,
		desc = "Harpoon Menu",
		mode = "n",
	},
	{ "O", "O<Space><BS>", mode = "n" },
	{ "o", "o<Space><BS>", mode = "n" },
	{
		"U",
		function()
			vim.cmd("redo")
		end,
		desc = "redo",
		mode = "n",
	},
	{
		"zO",
		function()
			vim.cmd("normal! zC")
			vim.cmd("normal! zO")
		end,
		mode = "n",
	},

	{ "<S-h>", bprev, silent = true, mode = "n" },
	{ "<S-h>", bprev, silent = true, mode = "n" },
	{ "<S-l>", bnext, silent = true, mode = "n" },

	-- Window Resizing Maps
	{ "<C-S-Up>", ":resize +5<CR>", desc = "increase height", silent = true, mode = { "n", "i", "x" } },
	{ "<C-S-Down>", ":resize -5<CR>", desc = "decrease height", silent = true, mode = { "n", "i", "x" } },
	{ "<C-Left>", ":vertical resize -5<CR>", desc = "decrease width", silent = true, mode = { "n", "i", "x" } },
	{ "<C-Right>", ":vertical resize +5<CR>", desc = "increase width", silent = true, mode = { "n", "i", "x" } },
})

-- Filetype Autocommands (Buffer maps are cleaner added contextually here)
autocmd("FileType", {
	pattern = "cpp",
	callback = function(ev)
		whichkey.add({
			{ "<leader>rm", u.cpp_move_to_file, desc = "Cpp move to files", buffer = ev.buf, mode = "x" },
		})
	end,
})
