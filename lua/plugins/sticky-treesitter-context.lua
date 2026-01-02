return {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
        mode = "cursor",
    },
    init = function()
        vim.cmd "hi TreesitterContextBottom gui=underline guisp=Grey"
    end,
}
