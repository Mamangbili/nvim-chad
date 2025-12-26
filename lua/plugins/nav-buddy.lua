return {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim",
    },
    config = require "configs.navbuddy",
    keys = {
        {
            mode = { "n", "v" },
            "<leader>nb",
            function()
                require("nvim-navbuddy").open()
            end,
            desc = "navbuddy toggle",
            noremap = true,
        },
    },
}
