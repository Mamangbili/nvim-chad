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
    config = require "configs.ufo",
    init = function()
        vim.o.foldenable = true
        vim.o.foldlevel = 99
        vim.o.foldcolumn = "1"
        vim.o.foldlevelstart = 99
    end,
    keys = keys,
}
