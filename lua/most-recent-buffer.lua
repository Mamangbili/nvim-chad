local utils = require("utils")

local function clamp(val, min, max)
	return math.max(min, math.min(max, val))
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
---@field current_position_state PositionStates
---@field current_buf_pos number
local Win = {
	id = 0,
	buffer_list = {},
	curret_position = 0,
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

local function setup()
	---@class WinList
	---@field [integer] Win
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

	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function(e)
			local new_win_id = vim.api.nvim_get_current_win()
			local new_win = Win.new(new_win_id)
			new_win:add(e.buf)
			win_list:add(new_win)
		end,
	})

	vim.api.nvim_create_autocmd("WinNew", {
		callback = function(e)
			vim.schedule(function()
				local new_win_id = vim.api.nvim_get_current_win()
				local new_win = Win.new(new_win_id)
				if utils.is_normal_buffer(e.buf) then
					new_win:add(e.buf)
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

	vim.keymap.set("n", "<leader>q", function()
		local curr_win = win_list:get_current_win()
		local curr_buf_id = curr_win:get_current_buf_id()
		vim.api.nvim_command("DeleteBuf")

		if not win_list:buf_exist_in_atleast_one_win(curr_buf_id) then
			vim.api.nvim_buf_delete(curr_buf_id, { force = true })
		end
	end, { noremap = true })

	vim.keymap.set("n", "<S-l>", function()
		local curr_win = win_list:get_current_win()
		local nextBufPos = clamp(curr_win.current_buf_pos + 1, 1, #curr_win.buffer_list)
		local nextBufId = curr_win.buffer_list[nextBufPos]
		curr_win.current_buf_pos = nextBufPos
		vim.api.nvim_win_set_buf(0, nextBufId)
	end, { noremap = true })

	vim.keymap.set("n", "<S-h>", function()
		local curr_win = win_list:get_current_win()
		local prevBufPos = clamp(curr_win.current_buf_pos - 1, 1, #curr_win.buffer_list)
		local prevBufId = curr_win.buffer_list[prevBufPos]
		curr_win.current_buf_pos = prevBufPos
		vim.api.nvim_win_set_buf(0, prevBufId)
	end, { noremap = true })

	vim.api.nvim_create_user_command("DeleteBuf", function()
		local curr_win = win_list:get_current_win()

		if is_empty_buf(curr_win.buffer_list[curr_win.curret_position]) and #curr_win.buffer_list == 1 then
			return
		elseif #curr_win.buffer_list > 1 then
			local newBufId = curr_win:remove(curr_win:get_current_buf_id())
			vim.api.nvim_set_current_buf(curr_win.buffer_list[newBufId])
		else
			curr_win:remove(curr_win:get_current_buf_id())
			local emptyBufid = vim.api.nvim_create_buf(true, true)
			vim.api.nvim_set_current_buf(emptyBufid)
			curr_win:add(emptyBufid)
		end
	end, {})

	vim.api.nvim_create_user_command("Buflist", function()
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
end

return { setup = setup }
