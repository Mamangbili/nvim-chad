local M = {}
local function is_normal_buffer(buf)
	return vim.api.nvim_buf_is_valid(buf)
		and vim.bo[buf].buftype == "" -- must be normal buffer
		and vim.bo[buf].buflisted -- must be listed
		and vim.api.nvim_buf_get_name(buf) ~= "" -- must have a file name
end
local function Close_window()
	vim.cmd("q!")
end
local function telescope_vsplit()
	require("telescope.builtin").find_files({
		attach_mappings = function(prompt_bufnr)
			local actions = require("telescope.actions")
			actions.select_default:replace(function()
				actions.file_vsplit(prompt_bufnr)
			end)
			return true
		end,
	})
end
local function telescope_hsplit()
	require("telescope.builtin").find_files({
		attach_mappings = function(prompt_bufnr)
			local actions = require("telescope.actions")
			actions.select_default:replace(function()
				actions.file_split(prompt_bufnr)
			end)
			return true
		end,
	})
end

local function paste_without_newline()
	local content = vim.fn.getreg("+")
	-- Remove trailing CR/LF (handles \n, \r\n, \r)
	content = content:gsub("[\r\n]+$", "")
	vim.fn.setreg("z", content) -- use 'z' as temp register (safe, non-default)
	return "<C-r>z"
end

local function Close_buffer()
	local tree = require("nvim-tree.api").tree
	if vim.bo.filetype == "copilot-chat" then
		vim.cmd("CopilotChatClose")
		return
	end
	if vim.bo.filetype == "NvimTree" then
		tree.close()
		return
	end
	require("bufdelete").bufdelete(0, true)
end
-- toggle between terminal mode and normal terminal mode
local function toggle_betwee()
	local mode = vim.fn.mode()
	if mode == "t" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
		-- else
		--     vim.api.nvim_feedkeys("i", "n", false)
	end
end

local function subtitute_old_word()
	local old_word = nil
	vim.ui.input({ prompt = "Substitute old word: " }, function(input)
		old_word = input
	end)
	if old_word == nil then
		return
	end
	local prompt = "Substitute " .. old_word .. " with new word: "
	vim.ui.input({ prompt = prompt }, function(new_word)
		if old_word ~= "" and new_word ~= nil then
			-- Escape inputs
			local esc_old = vim.fn.escape(old_word, "/\\.*$^~[]")
			local esc_new = vim.fn.escape(new_word, "/\\&~")
			local start_pos = vim.fn.getpos("'<")
			local end_pos = vim.fn.getpos("'>")

			-- Build command safely
			-- local cmd = string.format("'<,'>s/%s/%s/g", esc_old, esc_new)
			local cmd = start_pos[2] .. "," .. end_pos[2] .. "s/" .. esc_old .. "/" .. esc_new .. "/gI"
			vim.cmd(cmd)
			vim.cmd(":nohl")
		end
	end)
end

-- Detect 'q' then '/' in Normal mode
local last_key = nil

local function on_key(key)
	local mode = vim.fn.mode(1)

	if mode ~= "n" then
		last_key = nil -- reset on mode change
		return
	end

	if (last_key == "q" and key == "/") or (last_key == "q" and key == ":") or (last_key == "q" and key == "?") then
		vim.schedule(function()
			vim.cmd("q!")
		end)
	end

	last_key = key
end

local function get_first_diagnostic(bufnr)
	local diags = vim.diagnostic.get(bufnr)
	if #diags == 0 then
		return nil
	end

	table.sort(diags, function(a, b)
		if a.lnum == b.lnum then
			return a.col < b.col
		end
		return a.lnum < b.lnum
	end)
	return diags[1]
end

local function cpp_move_to_file()
	local old_buf = vim.api.nvim_get_current_buf()
	local current_dir = vim.fn.expand("%:p:h")
	local window_view = vim.fn.winrestcmd()

	-- 1. Scan for insertion point
	local lines = vim.api.nvim_buf_get_lines(old_buf, 0, -1, false)
	local original_includes = {}
	local last_include_idx = 0
	for i, line in ipairs(lines) do
		if line:match("^#include") then
			table.insert(original_includes, line)
			last_include_idx = i
		end
	end

	-- 2. Grab selection
	vim.cmd('normal! "zy')
	local cut_text = vim.fn.getreg("z", 1, 1)
	vim.cmd("normal! gvd")

	-- 3. Input filename
	vim.ui.input({ prompt = "New file name: ", default = "new_file.h" }, function(filename)
		if not filename or filename == "" then
			return
		end

		local actual_path = current_dir .. "/" .. filename
		local temp_cpp_path = actual_path .. ".cpp"

		-- 4. Content with wrapper
		local final_lines = {}
		if filename:match("%.h$") or filename:match("%.hpp$") then
			table.insert(final_lines, "#pragma once")
			table.insert(final_lines, "")
		end
		for _, inc in ipairs(original_includes) do
			table.insert(final_lines, inc)
		end
		table.insert(final_lines, "")
		table.insert(final_lines, "void __cleanup_context() {")
		for _, line in ipairs(cut_text) do
			table.insert(final_lines, "    " .. line)
		end
		table.insert(final_lines, "}")

		-- 5. Write and Open
		vim.fn.writefile(final_lines, temp_cpp_path)
		vim.cmd("edit " .. vim.fn.fnameescape(temp_cpp_path))
		pcall(vim.cmd, "only!")
		local target_buf = vim.api.nvim_get_current_buf()

		-- Move cursor to top so code_action has a starting point
		vim.api.nvim_win_set_cursor(0, { 1, 0 })
		vim.cmd("silent write")

		-- 6. Setup listener
		local group_id = vim.api.nvim_create_augroup("LspCleanup_" .. target_buf, { clear = true })
		vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufWinEnter" }, {
			group = group_id,
			buffer = target_buf,
			callback = function()
				local diag = get_first_diagnostic(target_buf)

				-- If we found a diagnostic, jump to it.
				-- If not, stay at the top and try the action anyway.
				if diag then
					vim.api.nvim_win_set_cursor(0, { diag.lnum + 1, 0 })
				end

				-- Attempt the code action
				vim.lsp.buf.code_action({
					context = { only = { "quickfix" } },
					filter = function(action)
						return action.title:lower():match("unused")
					end,
					apply = true,
				})

				-- 7. Wait and Finalize
				vim.defer_fn(function()
					vim.schedule(function()
						if not vim.api.nvim_buf_is_valid(target_buf) then
							return
						end

						vim.cmd("silent! write")

						local raw_lines = vim.api.nvim_buf_get_lines(target_buf, 0, -1, false)
						local cleaned_lines = {}

						for _, line in ipairs(raw_lines) do
							if not line:match("__cleanup_context") and not line:match("^}") then
								table.insert(cleaned_lines, (line:gsub("^    ", "")))
							end
						end

						vim.fn.writefile(cleaned_lines, actual_path)
						pcall(vim.api.nvim_del_augroup_by_id, group_id)
						vim.api.nvim_buf_delete(target_buf, { force = true })
						os.remove(temp_cpp_path)

						vim.cmd(window_view)
						vim.cmd("vsplit " .. vim.fn.fnameescape(actual_path))
						vim.api.nvim_buf_set_lines(
							old_buf,
							last_include_idx,
							last_include_idx,
							false,
							{ '#include "' .. filename .. '"' }
						)
						vim.cmd("silent write")
					end)
				end, 600)
				return true
			end,
		})
	end)
end

M.get_first_diagnostic = get_first_diagnostic
M.cpp_move_to_file = cpp_move_to_file
M.telescope_vsplit = telescope_vsplit
M.telescope_hsplit = telescope_hsplit
M.paste_without_newline = paste_without_newline
M.on_key = on_key
M.subtitute_old_word = subtitute_old_word
M.Close_window = Close_window
M.Close_buffer = Close_buffer
M.toggle_betwee = toggle_betwee
M.is_normal_buffer = is_normal_buffer
return M
