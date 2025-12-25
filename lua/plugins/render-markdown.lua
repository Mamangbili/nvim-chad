return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    opts = {},
    cmd = { "DevdocsOpen", "DevdocsOpenCurrent", "DevdocsKeywordprgs" },
    ft = "markdown",
    -- event = "VeryLazy",
}
