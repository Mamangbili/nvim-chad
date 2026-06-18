-- harpoon lazy load optmiziation
local function harpoon_map(i, ev)
	vim.keymap.set("n", tostring(i), function()
		require("harpoon"):list():select(i)
	end, {
		buffer = ev.buf,
		desc = "pick harpoon no." .. i,
	})
end

local M = {}

M.setup = function()
	local autocmd = vim.api.nvim_create_autocmd
	local cwd = vim.fn.getcwd()
	local utils = require("utils")
	local mySetting = vim.api.nvim_create_augroup("MySetting", { clear = true })

	autocmd("FileType", {
		group = mySetting,
		pattern = { "cpp", "c", "h", "hpp", "cc" },
		callback = function()
			vim.keymap.set("n", "gf", vim.lsp.buf.code_action, { desc = "quick fix" })
		end,
	})

	-- Refresh nvim-tree when entering its buffer/reopen
	autocmd({ "BufWinLeave", "BufEnter" }, {
		group = mySetting,
		pattern = "NvimTree_*",
		callback = function()
			vim.cmd("NvimTreeRefresh")
		end,
	})

	autocmd({ "BufRead", "BufNewFile" }, {
		group = mySetting,
		pattern = { ".env*", "NvTerm_float" },
		callback = function()
			vim.b.copilot_enabled = false
		end,
	})

	local u = require("utils")
	autocmd("BufEnter", {
		group = mySetting,
		pattern = "NvTerm_float",
		callback = function(ev)
			vim.keymap.set("i", "<C-v>", u.paste_without_newline, {
				expr = true,
				noremap = true,
				silent = true,
				desc = "Paste from clipboard (no trailing newline)",
				buffer = ev.buf,
			})
			vim.opt_local.timeoutlen = 100

			vim.keymap.set("t", "<C-v>", function()
				local text = vim.fn.getreg("+")

				text = text:gsub("^%s*", ""):gsub("%s*$", "")

				text = text:gsub("%s+", " ")

				text = text:gsub("^%s*(.-)%s*$", "%1")

				vim.api.nvim_paste(text, false, -1)
			end, { desc = "Paste trimmed", noremap = true, buffer = true })

			vim.keymap.del("t", "<tab>", { buffer = true })
		end,
	})

	-- for CMake lsp
	autocmd({ "BufRead", "BufNewFile" }, {
		group = mySetting,
		pattern = { "CMakeLists.txt", "*.cmake", "CmakeLists.txt", "cmakelists.txt" },
		command = "set filetype=cmake",
	})

	autocmd("FileType", {
		group = mySetting,
		pattern = "NvimTree",
		callback = function()
			vim.keymap.set("n", "<leader>ct", "<cmd>NvimTreeCollapse<cr>", { desc = "Collapse Tree", noremap = true })
		end,
	})

	local start = os.time()
	autocmd({ "TextChanged", "InsertLeave" }, {
		group = mySetting,
		pattern = "*",
		callback = function(args)
			local deltaTime = os.time() - start
			deltaTime = deltaTime
			local sec = 7
			if deltaTime > sec then
				vim.cmd("silent! write")
				local ok, notify = pcall(require, "notify")

				if not ok then
					print("Auto-saved at " .. os.date("%H:%M:%S"))
				else
					notify("💾 Auto-saved at " .. os.date("%H:%M:%S"), "info", {
						title = "Auto-save",
						timeout = 1000, -- 1 second
					})
				end
				start = os.time()
			end
		end,
	})

	-- Close quickfix window after jumping to location
	autocmd("FileType", {
		group = mySetting,
		pattern = "qf",
		callback = function()
			vim.cmd([[nnoremap <buffer> <CR> <CR>:cclose<CR>]])
			vim.cmd([[nnoremap <buffer> o o:cclose<CR>]])
			vim.cmd([[nnoremap <buffer> <2-LeftMouse> <2-LeftMouse>:cclose<CR>]])
		end,
	})

	autocmd({ "FileType", "BufEnter" }, {
		group = mySetting,
		pattern = "harpoon",
		callback = function(ev)
			vim.keymap.set("n", "w", ":close<CR>", {
				buffer = ev.buf,
				desc = "close",
			})

			vim.keymap.set("n", "e", "<CR>", {
				buffer = ev.buf,
				desc = "close",
				remap = true,
			})
			-- harpoon_map(4, ev)
			-- harpoon_map(5, ev)
			-- harpoon_map(6, ev)
			-- harpoon_map(7, ev)
			-- harpoon_map(8, ev)
			-- harpoon_map(9, ev)
		end,
	})

	local function clear_cmdarea()
		vim.defer_fn(function()
			vim.api.nvim_echo({}, false, {})
		end, 800)
	end

	autocmd("BufWritePost", {
		group = mySetting,
		pattern = "*",
		callback = function(args)
			require("conform").format({ async = true, bufnr = args.buf })
		end,
	})

	autocmd("FileType", {
		group = mySetting,
		pattern = "cpp",
		callback = function()
			vim.bo.commentstring = "// %s"
			vim.opt_local.tabstop = 4
			vim.opt_local.shiftwidth = 4
			vim.opt_local.expandtab = true
			vim.opt_local.autoindent = true
			vim.opt_local.smarttab = true
		end,
	})

	-- better leave insert mode
	local trigger_key = nil
	vim.keymap.set("n", "i", function()
		trigger_key = "i"
		return "i"
	end, { expr = true, noremap = true })

	vim.keymap.set("n", "a", function()
		trigger_key = "a"
		return "a"
	end, { expr = true, noremap = true })

	autocmd("InsertLeave", {
		group = mySetting,
		callback = function()
			if trigger_key == "i" then
				vim.cmd("normal! l")
			end
		end,
	})

	autocmd("VimEnter", {
		group = mySetting,
		callback = function()
			vim.cmd("clearjumps")
		end,
	})

	autocmd({ "VimLeavePre" }, {
		group = mySetting,
		group = vim.api.nvim_create_augroup("fuck_shada_temp", { clear = true }),
		pattern = { "*" },
		callback = function(ev)
			if vim.api.nvim_buf_get_name(ev.buf) ~= "" then
				vim.cmd("silent! write")
			end

			local status = 0
			for _, f in ipairs(vim.fn.globpath(vim.fn.stdpath("data") .. "/shada", "*tmp*", false, true)) do
				if vim.tbl_isempty(vim.fn.readfile(f)) then
					status = status + vim.fn.delete(f)
				end
			end
			if status ~= 0 then
				vim.notify("Could not delete empty temporary ShaDa files.", vim.log.levels.ERROR)
				vim.fn.getchar()
			end
		end,
		desc = "Delete empty temp ShaDa files",
	})

	autocmd("BufNew", {
		group = mySetting,
		pattern = "*",
		callback = function()
			vim.schedule(function()
				vim.cmd("filetype detect")
			end)
		end,
	})

	autocmd("FileType", {
		group = mySetting,
		pattern = "NeogitStatus",
		callback = function(e)
			vim.keymap.set("n", "<leader>q", "<cmd>close<Cr>", { buf = e.buf, noremap = true })
		end,
	})
	autocmd("FileType", {
		group = mySetting,
		pattern = "DiffviewFiles",
		callback = function(e)
			vim.keymap.set(
				"n",
				"<leader>q",
				"<cmd>close<Cr><cmd>close<Cr><cmd>close<Cr>",
				{ buf = e.buf, noremap = true, desc = "Exit diff view" }
			)

			vim.keymap.set(
				"n",
				"<leader>ww",
				"<cmd>close<Cr><cmd>close<Cr><cmd>close<Cr>",
				{ buf = e.buf, noremap = true, desc = "Exit diff view" }
			)
		end,
	})

	local ignore_filetypes = { "neo-tree", "NeogitStatus", "DiffviewFiles" }
	local ignore_buftypes = { "nofile", "prompt", "popup" }

	local augroup = vim.api.nvim_create_augroup("FocusDisable", { clear = true })

	vim.api.nvim_create_autocmd("WinEnter", {
		group = augroup,
		callback = function(_)
			if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
				vim.w.focus_disable = true
			else
				vim.w.focus_disable = false
			end
		end,
		desc = "Disable focus autoresize for BufType",
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		callback = function(_)
			if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
				vim.b.focus_disable = true
			else
				vim.b.focus_disable = false
			end
		end,
		desc = "Disable focus autoresize for FileType",
	})

	-- warning : very hacky
	-- autocmd("BufAdd", {
	-- group=mySetting,
	-- 	callback = function(e)
	-- 		-- local pcall = pcall(function()
	-- 		-- end)
	--
	-- 		if utils.is_normal_buffer(e.buf) then
	-- 			vim.defer_fn(function()
	-- 				require("ufo").closeFoldsWith(1)
	-- 			end, 1000)
	-- 		end
	-- 	end,
	-- })

	-- autocmd({ "UIEnter" }, {
	-- 	pattern = "*",
	-- 	callback = function()
	-- 		require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
	-- 	end,
	-- })
end

return M
