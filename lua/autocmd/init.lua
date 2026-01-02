local M = {}

M.setup = function()
    local autocmd = vim.api.nvim_create_autocmd
    local cwd = vim.fn.getcwd()

    autocmd("FileType", {
        pattern = { "cpp", "c", "h", "hpp", "cc" },
        callback = function()
            vim.keymap.set("n", "gf", vim.lsp.buf.code_action, { desc = "quick fix" })
        end,
    })

    -- Refresh nvim-tree when entering its buffer/reopen
    autocmd({ "BufWinLeave", "BufEnter" }, {
        pattern = "NvimTree_*",
        callback = function()
            vim.cmd "NvimTreeRefresh"
        end,
    })

    autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { ".env*", "NvTerm_float" },
        callback = function()
            vim.b.copilot_enabled = false
        end,
    })

    local u = require "utils"
    autocmd("FileType", {
        pattern = "NvTerm_float",
        callback = function()
            vim.opt_local.timeoutlen = 100
            vim.keymap.set(
                { "t", "n" },
                "<Esc>",
                u.toggle_betwee,
                { desc = "toggle terminal mode", noremap = true, buffer = true }
            )
            vim.keymap.set("t", "<C-v>", function()
                local text = vim.fn.getreg "+"

                text = text:gsub("^%s*", ""):gsub("%s*$", "")

                text = text:gsub("%s+", " ")

                text = text:gsub("^%s*(.-)%s*$", "%1")

                vim.api.nvim_paste(text, false, -1)
            end, { desc = "Paste trimmed", noremap = true, buffer = true })
        end,
    })

    -- for CMake lsp
    autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "CMakeLists.txt", "*.cmake", "CmakeLists.txt", "cmakelists.txt" },
        command = "set filetype=cmake",
    })

    autocmd("FileType", {
        pattern = "NvimTree",
        callback = function()
            vim.keymap.set("n", "<leader>ct", "<cmd>NvimTreeCollapse<cr>", { desc = "Collapse Tree", noremap = true })
        end,
    })

    local start = os.time()
    autocmd({ "TextChanged", "InsertLeave" }, {
        pattern = "*",
        callback = function(args)
            local deltaTime = os.time() - start
            deltaTime = deltaTime
            local sec = 10
            if deltaTime > sec then
                vim.cmd "silent! write"
                local ok, notify = pcall(require, "notify")

                if not ok then
                    print("Auto-saved at " .. os.date "%H:%M:%S")
                else
                    notify("💾 Auto-saved at " .. os.date "%H:%M:%S", "info", {
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
        pattern = "qf",
        callback = function()
            vim.cmd [[nnoremap <buffer> <CR> <CR>:cclose<CR>]]
            vim.cmd [[nnoremap <buffer> o o:cclose<CR>]]
            vim.cmd [[nnoremap <buffer> <2-LeftMouse> <2-LeftMouse>:cclose<CR>]]
        end,
    })

    autocmd("BufWritePost", {
        pattern = "*",
        callback = function(args)
            require("conform").format { async = true, bufnr = args.buf }
        end,
    })

    autocmd("FileType", {
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
        callback = function()
            if trigger_key == "i" then
                vim.cmd "normal! l"
            end
        end,
    })

    autocmd("BufEnter", {
        pattern = "*.md",
        callback = function(args)
            local bufnr = args.buf
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local bufdir = vim.fn.fnamemodify(bufname, ":p:h")

            if bufdir:match "vaults" then
                local plugins = pcall(function()
                    return require("lazy.core.config").plugins["obsidian.nvim"]._.loaded or false
                end)
                if plugins then
                    vim.cmd "RenderMarkdown disable"
                end
            end
        end,
    })
    autocmd("BufLeave", {
        pattern = "*.md",
        callback = function(args)
            local bufnr = args.buf
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local bufdir = vim.fn.fnamemodify(bufname, ":p:h")

            if bufdir:match "vaults" then
                vim.cmd "RenderMarkdown enable"
            end
        end,
    })

    -- autocmd("FileType", {
    --     pattern = "vim",
    --     callback = function()
    --         vim.schedule(function()
    --             -- Optional: double-check we’re still in a vim filetype buffer
    --             if vim.bo.filetype == "vim" then
    --                 vim.cmd "silent! q!"
    --             end
    --         end)
    --     end,
    -- })
end

return M
