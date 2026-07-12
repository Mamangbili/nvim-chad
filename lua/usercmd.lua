local M = {}

M.setup = function()
	vim.api.nvim_create_user_command("BDeleteOthers", function()
		local cur_buf = vim.api.nvim_get_current_buf()
		local bufs = vim.fn.getbufinfo({ buflisted = 1 })

		for _, b in ipairs(bufs) do
			if b.bufnr ~= cur_buf and vim.api.nvim_buf_is_valid(b.bufnr) then
				local bt = vim.bo[b.bufnr].buftype

				-- Skip ALL special buffers.
				if bt == "" then
					pcall(vim.cmd.bdelete, b.bufnr)
				end
			end
		end

		vim.cmd("BufDeleteOthers")
	end, {})
end

return M
