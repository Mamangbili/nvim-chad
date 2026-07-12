local utils = require("utils")

local function clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

local function slice(arr, start_i, end_i)
	local new = {}
	start_i = start_i or 1
	end_i = end_i or #arr
	local j = 1
	for i = start_i, end_i do
		if arr[i] ~= nil then
			new[j] = arr[i]
			j = j + 1
		end
	end
	return new
end

local function reverse_inplace(arr)
	local n = #arr
	for i = 1, n / 2 do
		local j = n - i + 1
		arr[i], arr[j] = arr[j], arr[i]
	end
	return arr
end
--- @param bufnr number|table|nil
local function is_empty_buf(bufnr)
	if bufnr == nil or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	elseif type(bufnr) == "table" then
		bufnr = bufnr.id or 0
	end

	local name = vim.api.nvim_buf_get_name(bufnr)
	local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })

	return name == "" and (buftype == "" or buftype == "nofile")
end

local function map(tbl, fn)
	local result = {}
	for i, v in ipairs(tbl) do
		result[i] = fn(v, i)
	end
	return result
end

local function find_index(t, value)
	for i, v in ipairs(t) do
		if v == value then
			return i
		end
	end
	return 0
end

local function contains(t, value)
	for _, v in ipairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

---@enum PositionStates
local PositionStates = {
	Empty = 0,
	First = 1,
	Middle = 2,
	Last = 3,
}

---@class Win
---@field id number
---@field buffer number[]
---@field current_position number
---@field current_position_state PositionStates
---@field current_buf_pos number
local Win = {
	id = 0,
	buffer_list = {},
	curret_position = 0,
	current_position_state = PositionStates.Empty,
	current_buf_pos = 0,
}
Win.__index = Win

function Win.new(id)
	return setmetatable(
		{ id = id, buffer_list = {}, current_position_state = PositionStates.Empty, current_buf_pos = 0 },
		Win
	)
end

function Win:contain(bufferid)
	return contains(self.buffer_list, bufferid)
end

function Win:get_current_buf_id()
	if #self.buffer_list == 0 then
		return nil
	end
	return self.buffer_list[self.current_buf_pos]
end

function Win:sync_state()
	if self.current_buf_pos == 0 then
		self.current_position_state = PositionStates.Empty
	end
	if self.current_buf_pos == 1 then
		self.current_position_state = PositionStates.First
	elseif self.current_buf_pos == #self.buffer_list then
		self.current_position_state = PositionStates.Last
	else
		self.current_position_state = PositionStates.Middle
	end
end

function Win:add(bufferid)
	--  Prevent duplicates
	for i, id in ipairs(self.buffer_list) do
		if id == bufferid then
			return i
		end
	end

	local count = #self.buffer_list

	if self.current_buf_pos == count or count == 0 then
		table.insert(self.buffer_list, bufferid)
		self.current_buf_pos = #self.buffer_list
	else
		local new_list = {}

		for i = 1, self.current_buf_pos - 1 do
			table.insert(new_list, self.buffer_list[i])
		end

		for i = count, self.current_buf_pos + 1, -1 do
			table.insert(new_list, self.buffer_list[i])
		end

		table.insert(new_list, self.buffer_list[self.current_buf_pos])

		table.insert(new_list, bufferid)

		self.buffer_list = new_list
		self.current_buf_pos = #self.buffer_list
	end

	self:sync_state()
	return self.current_buf_pos
end

function Win:remove(bufid)
	local idx = find_index(self.buffer_list, bufid)
	if not idx then
		return self.current_buf_pos
	end

	table.remove(self.buffer_list, idx)

	local count = #self.buffer_list

	if count == 0 then
		self.current_buf_pos = 0
	elseif idx < self.current_buf_pos then
		self.current_buf_pos = self.current_buf_pos - 1
	elseif self.current_buf_pos > count then
		self.current_buf_pos = count
	end

	self:sync_state()
	return self.current_buf_pos
end

---@class WinList
---@field [integer] Win
---@field active_win number
local win_list = {}

function win_list:buf_exist_in_atleast_one_win(bufid)
	for _, win in ipairs(self) do
		if win:contain(bufid) then
			return true
		end
	end
	return false
end

function win_list:get_current_win()
	local current_win_id = vim.api.nvim_get_current_win()
	local winids = self:get_ids()
	local win_i = find_index(winids, current_win_id)
	return self[win_i]
end

function win_list:get_ids()
	return map(self, function(e)
		return e.id
	end)
end

function win_list:add(win)
	local winids = self:get_ids()
	if contains(winids, win.id) then
		return
	end
	table.insert(self, win)
end

function win_list:remove(winid)
	local winids = self:get_ids()
	local win_i = find_index(winids, winid)
	table.remove(self, win_i)
end

function win_list:set_active_win(winid)
	if vim.api.nvim_win_is_valid(winid) then
		win_list.active_win = winid
	end
	print("win is not valid")
end

local function jump_prev(winid, bufid)
	local jump_data = vim.fn.getjumplist(winid)
	local entries = jump_data[1]
	local curr_idx = jump_data[2] -- This is a 0-based index

	for i = curr_idx, 1, -1 do
		local entry = entries[i]

		if entry and entry.bufnr == bufid then
			-- Calculate the jump distance (relative steps backward)
			local steps = curr_idx - (i - 1)

			if steps > 0 and vim.api.nvim_win_is_valid(winid) then
				-- Ensure the window is focused or use win_execute
				vim.api.nvim_set_current_win(winid)
				vim.cmd("normal! " .. steps .. "\x0f")
				return
			end
		end
	end
	vim.notify("No previous jump found in this buffer", vim.log.levels.WARN, { timeout = 800 })
end

local function jump_next(winid, bufid)
	local jump_data = vim.fn.getjumplist(winid)
	local entries = jump_data[1]
	local curr_idx = jump_data[2] -- 0-based index pointing to current position
	local list_size = #entries

	for i = curr_idx + 2, list_size do
		local entry = entries[i]

		if entry and entry.bufnr == bufid then
			-- Calculate steps forward
			-- (i - 1) converts Lua index back to 0-based to compare with curr_idx
			local steps = (i - 1) - curr_idx

			if steps > 0 and vim.api.nvim_win_is_valid(winid) then
				vim.api.nvim_set_current_win(winid)
				-- \x09 is the code for <C-i> (Forward)
				vim.cmd("normal! " .. steps .. "\x09")
				return
			end
		end
	end
	vim.notify("No newer jump found in this buffer", vim.log.levels.WARN, { timeout = 800 })
end

--- comment
--- @param winlist WinList
--- @param curr_bufid number
--- @param target_bufid number
--- @param target_winid number
local function rearrage_buffer(winlist, curr_bufid, target_bufid, target_winid)
	local curr_win = winlist:get_current_win()
	if curr_win:contain(target_bufid) and winlist:get_current_win() == target_winid then
		return
	end

	local curr_bufid_idx = find_index(winlist:get_current_win().buffer_list, curr_bufid)
	if curr_bufid_idx == #winlist:get_current_win().buffer_list then
		return
	end

	if #winlist:get_current_win().buffer_list <= 2 then
		return
	end

	-- swap
	local bufid_list = curr_win:buffer_list()
	local last_bufids = { curr_bufid, target_bufid }
	local target_idx = find_index(bufid_list, target_bufid)

	local ids_right_side_of_target = slice(bufid_list, target_idx)
	reverse_inplace(ids_right_side_of_target)
	local ids_left_side_of_target = slice(bufid_list, 0, target_bufid)

	-- remove any duplicate target id and current id
	table.remove(ids_left_side_of_target, target_bufid)
	table.remove(ids_left_side_of_target, curr_bufid)
	table.remove(ids_right_side_of_target, target_bufid)
	table.remove(ids_right_side_of_target, curr_bufid)

	-- final form = left + right + last
	local result = ids_left_side_of_target + ids_right_side_of_target + last_bufids

	curr_win.buffer_list = result
	curr_win.current_buf_pos = #result
	curr_win.sync_state(curr_win)
end

local function setup()
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function(e)
			local new_win_id = vim.api.nvim_get_current_win()
			local new_win = Win.new(new_win_id)
			new_win:add(e.buf)
			win_list:add(new_win)
		end,
	})

	vim.api.nvim_create_autocmd("WinNew", {
		callback = function()
			vim.schedule(function()
				local new_win_id = vim.api.nvim_get_current_win()
				local new_win = Win.new(new_win_id)
				local current_buf = vim.api.nvim_win_get_buf(new_win_id)
				if utils.is_normal_buffer(current_buf) then
					new_win:add(current_buf)
					win_list:add(new_win)
				end
			end)
		end,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function(args)
			local current_win_id = tonumber(args.match)
			local winids = win_list:get_ids()

			if contains(winids, current_win_id) then
				win_list:remove(current_win_id)

				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if
						vim.api.nvim_buf_is_valid(buf)
						and utils.is_normal_buffer(buf)
						and not win_list:buf_exist_in_atleast_one_win(buf)
					then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufWinEnter", {
		callback = function(args)
			if not vim.api.nvim_buf_is_valid(args.buf) then
				return
			end

			local curr_win = win_list:get_current_win()

			if curr_win and require("utils").is_normal_buffer(args.buf) then
				curr_win:add(args.buf)
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function(args)
			if not utils.is_normal_buffer(args.buf) then
				return
			end

			local win = win_list:get_current_win()
			if win == nil then
				return
			end

			if not win:contain(args.buf) then
				win:add(args.buf)
			end

			local idx = find_index(win.buffer_list, args.buf)
			win.current_buf_pos = idx
			win.current_position = idx
			win:sync_state()
		end,
	})

	vim.api.nvim_create_user_command("BufNextCycle", function()
		local curr_win = win_list:get_current_win()
		local nextBufPos = clamp(curr_win.current_buf_pos + 1, 1, #curr_win.buffer_list)
		local nextBufId = curr_win.buffer_list[nextBufPos]
		curr_win.current_buf_pos = nextBufPos
		vim.api.nvim_win_set_buf(0, nextBufId)
	end, {})

	vim.api.nvim_create_user_command("BufPrevCycle", function()
		local curr_win = win_list:get_current_win()
		local prevBufPos = clamp(curr_win.current_buf_pos - 1, 1, #curr_win.buffer_list)
		local prevBufId = curr_win.buffer_list[prevBufPos]
		curr_win.current_buf_pos = prevBufPos
		vim.api.nvim_win_set_buf(0, prevBufId)
	end, {})

	vim.api.nvim_create_user_command("BufDelete", function()
		local curr_win = win_list:get_current_win()
		if curr_win == nil then
			vim.cmd("q")
			return
		end
		local curr_buf_id = curr_win:get_current_buf_id()

		if is_empty_buf(curr_win.buffer_list[curr_win.current_position]) and #curr_win.buffer_list == 1 then
			-- Already empty, nothing to do
			return
		elseif #curr_win.buffer_list > 1 then
			local newBufIndex = curr_win:remove(curr_buf_id)
			vim.api.nvim_set_current_buf(curr_win.buffer_list[newBufIndex])
		else
			-- Last buffer: Create a replacement BEFORE deleting
			curr_win:remove(curr_buf_id)
			local emptyBufid = vim.api.nvim_create_buf(true, true)
			vim.api.nvim_set_current_buf(emptyBufid)
			curr_win:add(emptyBufid)
		end

		if vim.api.nvim_buf_is_valid(curr_buf_id) then
			if not win_list:buf_exist_in_atleast_one_win(curr_buf_id) then
				vim.api.nvim_buf_delete(curr_buf_id, { force = true })
			end
		end
		-- Defer execution slightly to allow the buffer list to update accurately
		vim.schedule(function()
			-- Get all active LSP clients
			local active_clients = vim.lsp.get_clients()

			for _, client in ipairs(active_clients) do
				-- Check if the client is attached to any remaining buffers
				local has_attached_buffers = false
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) and vim.lsp.buf_is_attached(buf, client.id) then
						has_attached_buffers = true
						break
					end
				end

				-- If the client has no buffers left, stop it
				if not has_attached_buffers then
					vim.notify("Stopping orphan LSP client: " .. client.name, vim.log.levels.INFO)
					client.stop()
				end
			end
		end)
	end, {})

	vim.api.nvim_create_user_command("BufJumpNext", function()
		local win = win_list:get_current_win()
		local curr_buf_id = win:get_current_buf_id()
		local curr_win_id = win.id
		jump_next(curr_win_id, curr_buf_id)
	end, {})

	vim.api.nvim_create_user_command("BufJumpPrev", function()
		local win = win_list:get_current_win()
		local curr_buf_id = win:get_current_buf_id()
		local curr_win_id = win.id
		jump_prev(curr_win_id, curr_buf_id)
	end, {})

	-- For Debugging
	vim.api.nvim_create_user_command("BufDebug", function()
		local curr_win = win_list:get_current_win()
		print("current buff pos : ", curr_win.current_buf_pos)
		local winids = "id : "
		for _, win in ipairs(win_list) do
			winids = winids .. " " .. win.id
		end
		print(winids)
		print("current win id :" .. curr_win.id)

		local buffids = "buf ids : "
		for _, buff in ipairs(curr_win.buffer_list) do
			buffids = buffids .. " " .. buff
		end
		print(buffids)
		print("current buf id :" .. curr_win:get_current_buf_id())
	end, {})

	-- vim.api.nvim_create_autocmd("BufEnter", {
	-- 	callback = function(args)
	-- 		if utils.is_normal_buffer(args.buf) then
	-- 			local win = win_list:get_current_win()
	-- 			local curr_buf_id = win:get_current_buf_id()
	-- 			local target_bufid = args.buf
	-- 			local target_winid = vim.api.nvim_get_current_win()
	-- 			already_open(win_list, curr_buf_id, target_bufid, target_winid)
	-- 		end
	-- 	end,
	-- })

	vim.api.nvim_create_user_command("BufDeleteOthers", function()
		local win = win_list:get_current_win()
		local curr_buf = win:get_current_buf_id()
		if curr_buf == nil then
			return
		end

		if #win.buffer_list > 1 then
			win.buffer_list = { curr_buf }
			win.current_buf_pos = 1
			win.current_position = 1
			win:sync_state()
		end
	end, {})

	vim.api.nvim_create_user_command("BufDebugJumpList", function()
		local win = win_list:get_current_win()
		local curr_buf_id = win:get_current_buf_id()
		local curr_win_id = win.id
		local entries = buf_jumplist:get_entries(curr_win_id, curr_buf_id)

		for i, val in ipairs(entries) do
			print("No. " .. i .. " Row: " .. val.row .. " Col: " .. val.col)
		end
	end, {})
end

return { setup = setup }
