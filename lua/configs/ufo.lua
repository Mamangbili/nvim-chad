return function(_, opts)
    -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
    vim.keymap.set("n", "zR", require("ufo").openAllFolds)
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
    local more_msg_highlight = vim.api.nvim_get_hl_id_by_name "MoreMsg"
    local non_text_highlight = vim.api.nvim_get_hl_id_by_name "NonText"

    local fold_virt_text_handler = function(
        -- The start_line's text.
        virtual_text_chunks,
        -- Start and end lines of fold.
        start_line,
        end_line,
        -- Total text width.
        text_width,
        -- fun(str: string, width: number): string Trunctation function.
        truncate,
        -- Context for the fold.
        ctx
    )
        local line_delta = (" 󰁂 %d "):format(end_line - start_line)
        local remaining_width = text_width - vim.fn.strdisplaywidth(ctx.text) - vim.fn.strdisplaywidth(line_delta)
        table.insert(virtual_text_chunks, { line_delta, more_msg_highlight })
        local line = start_line
        while remaining_width > 0 and line < end_line do
            line = line + 1
            local line_text = vim.api.nvim_buf_get_lines(ctx.bufnr, line, line + 1, true)[1]
            line_text = " " .. vim.trim(line_text)
            local line_text_width = vim.fn.strdisplaywidth(line_text)
            if line_text_width <= remaining_width - 2 then
                remaining_width = remaining_width - line_text_width
            else
                line_text = truncate(line_text, remaining_width - 2) .. "…"
                remaining_width = remaining_width - vim.fn.strdisplaywidth(line_text)
            end
            table.insert(virtual_text_chunks, { line_text, non_text_highlight })
        end
        return virtual_text_chunks
    end

    require("ufo").setup {
        fold_virt_text_handler = fold_virt_text_handler,
        provider_selector = function(bufnr, filetype, buftype)
            return { "treesitter", "indent" }
        end,
    }
    --
    vim.opt.foldopen:remove { "search", "hor" }

    --
    -- Function to open exact level
    local function fold_exact_level_open(level)
        local last = vim.api.nvim_buf_line_count(0)
        local lnum = 1
        while lnum <= last do
            local flevel = vim.fn.foldlevel(lnum)
            local fclosed = vim.fn.foldclosed(lnum)

            if flevel == level then
                vim.cmd(lnum .. "foldopen")
                -- safely skip folded region if it's closed
                if fclosed ~= -1 then
                    lnum = vim.fn.foldclosedend(lnum) + 1
                else
                    lnum = lnum + 1
                end
            else
                lnum = lnum + 1
            end
        end
    end

    local function fold_level_in_root(level)
        local cursor = vim.fn.line "."
        local buf_last = vim.api.nvim_buf_line_count(0)

        -- Find root fold start
        local root_start = cursor
        while root_start > 1 and vim.fn.foldlevel(root_start) > 1 do
            root_start = root_start - 1
        end

        -- Find root fold end
        local root_end = root_start
        while root_end <= buf_last and vim.fn.foldlevel(root_end) >= 1 do
            root_end = root_end + 1
        end
        root_end = root_end - 1

        -- Save view to restore cursor/window position
        local view = vim.fn.winsaveview()

        -- Open entire root fold to make all children visible
        vim.cmd(root_start .. "," .. root_end .. "foldopen!")

        -- Go to start of root fold
        vim.api.nvim_win_set_cursor(0, { root_start, 0 })

        -- Temporarily fold level recursively inside root
        for l = 1, level - 1 do
            -- Fold all higher levels first to expose exact-level folds
            vim.cmd(root_start .. "," .. root_end .. "foldopen!")
        end

        -- Fold all folds at the exact target level
        for lnum = root_start, root_end do
            if vim.fn.foldlevel(lnum) == level and vim.fn.foldclosed(lnum) == -1 then
                vim.cmd(lnum .. "foldclose")
            end
        end

        -- Restore view
        vim.fn.winrestview(view)
    end
    --
    -- -- Open all folds of a specific level inside the root-level fold under cursor
    local function open_level_in_root(level)
        local cursor = vim.fn.line "."
        local buf_last = vim.api.nvim_buf_line_count(0)

        -- Find root fold start
        local root_start = cursor
        while root_start > 1 and vim.fn.foldlevel(root_start) > 1 do
            root_start = root_start - 1
        end

        -- Find root fold end
        local root_end = root_start
        while root_end <= buf_last and vim.fn.foldlevel(root_end) >= 1 do
            root_end = root_end + 1
        end
        root_end = root_end - 1

        -- Ensure root fold is open so children are visible
        vim.cmd(root_start .. "," .. root_end .. "foldopen!")

        -- Helper: check if a line is the start of a fold
        local function is_fold_start(lnum)
            local curr = vim.fn.foldlevel(lnum)
            local prev = (lnum == 1) and 0 or vim.fn.foldlevel(lnum - 1)
            return curr > prev
        end

        -- Open all folds at the target level inside root
        for lnum = root_start, root_end do
            if vim.fn.foldlevel(lnum) == level and vim.fn.foldclosed(lnum) ~= -1 and is_fold_start(lnum) then
                vim.cmd(lnum .. "foldopen")
            end
        end
    end
    --
    -- Keymaps for levels 1–9
    for level = 0, 9 do
        vim.keymap.set("n", "z" .. level .. "c", function()
            -- fold_exact_level_close(level)
            require("ufo").closeFoldsWith(level)
        end, { noremap = true, silent = true })

        vim.keymap.set("n", "z" .. level .. "o", function()
            fold_exact_level_open(level)
        end, { noremap = true, silent = true })

        vim.keymap.set("n", "z" .. level .. level .. "c", function()
            fold_level_in_root(level)
        end, {
            noremap = true,
            silent = true,
            desc = "fold all level " .. level .. " on next lines but still within scope ",
        })

        vim.keymap.set("n", "z" .. level .. level .. "o", function()
            open_level_in_root(level)
        end, { noremap = true, silent = true })
    end

    vim.keymap.set("n", "K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
            vim.lsp.buf.hover()
        end
    end)
end
