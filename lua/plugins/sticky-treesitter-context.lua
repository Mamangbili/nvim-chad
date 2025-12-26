return {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = "FileType",
    opts = {
        mode = "cursor",
    },
    init = function()
        vim.cmd "hi TreesitterContextBottom gui=underline guisp=Grey"
    end,
}
