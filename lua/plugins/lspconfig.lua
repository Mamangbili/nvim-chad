return {
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "SmiteshP/nvim-navbuddy",
            dependencies = {
                "SmiteshP/nvim-navic",
                "MunifTanjim/nui.nvim",
            },
            config = require "configs.navbuddy",
        },
    },
    event = "VimEnter",
    config = function()
        require "configs.lspconfig"
    end,
    -- your lsp config or other stuff
}
