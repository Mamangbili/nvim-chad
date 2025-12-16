return {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    opts = {
        mode = "cursor",
    },
    init = function()
        vim.cmd "hi TreesitterContextBottom gui=underline guisp=Grey"
    end,
}
