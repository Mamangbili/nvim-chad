return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    opts = {
        link = {
            wiki = {
                icon = " ",
                body = function()
                    return nil
                end,
                highlight = "RenderMarkdownWikiLink",
                scope_highlight = nil,
            },
        },
    },
    cmd = { "DevdocsOpen", "DevdocsOpenCurrent", "DevdocsKeywordprgs" },
    ft = "markdown",
    -- event = "VeryLazy",
}
