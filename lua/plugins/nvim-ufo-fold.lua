return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "VeryLazy",
    config = require "configs.ufo",
    init = function()
        vim.o.foldenable = true
        vim.o.foldlevel = 99
        vim.o.foldcolumn = "1"
        vim.o.foldlevelstart = 99
    end,
}
