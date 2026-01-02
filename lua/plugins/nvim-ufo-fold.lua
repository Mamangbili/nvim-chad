local keys = {}

for level = 0, 9 do
    table.insert(keys, {
        "z" .. level .. "c",
        function()
            require("ufo").closeFoldsWith(level)
        end,
        mode = "n",
        desc = "Close folds at level " .. level,
    })
    table.insert(keys, {
        "z" .. level .. "o",
        function()
            fold_exact_level_open(level)
        end,
        mode = "n",
        desc = "Open folds at level " .. level,
    })
    table.insert(keys, {
        "z" .. level .. level .. "c",
        function()
            fold_level_in_root(level)
        end,
        mode = "n",
        desc = "Close all folds at level " .. level .. " in root",
    })
    table.insert(keys, {
        "z" .. level .. level .. "o",
        function()
            open_level_in_root(level)
        end,
        mode = "n",
        desc = "Open all folds at level " .. level .. " in root",
    })
end

table.insert(keys, {
    "K",
    function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
            vim.lsp.buf.hover()
        end
    end,
    mode = "n",
    desc = "Peek fold or LSP hover",
})

return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async", "OXY2DEV/foldtext.nvim" },
    config = function(_, opts)
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
    end,
    init = function()
        vim.o.foldenable = true
        vim.o.foldlevel = 99
        vim.o.foldcolumn = "1"
        vim.o.foldlevelstart = 99
    end,
    keys = keys,
}
