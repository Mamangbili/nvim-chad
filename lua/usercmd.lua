local M = {}
M.setup = function()
    vim.api.nvim_create_user_command("BDeleteOthers", function()
        local cur_buf = vim.api.nvim_get_current_buf()
        -- Get all *listed* buffers (i.e., appear in :ls)
        local bufs = vim.fn.getbufinfo { buflisted = 1 }
        for _, b in ipairs(bufs) do
            if b.bufnr ~= cur_buf and vim.api.nvim_buf_is_valid(b.bufnr) then
                -- Skip current & invalid buffers
                local name = vim.api.nvim_buf_get_name(b.bufnr)
                if name ~= "" or vim.bo[b.bufnr].buftype == "" then
                    -- Optional: skip special buffers (e.g., help, terminal, etc.)
                    -- But we’ll delete regular ones
                    pcall(vim.cmd.bdelete, b.bufnr)
                end
            end
        end
    end, {})
end
return M
