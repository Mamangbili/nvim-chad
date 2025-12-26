return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
        "Refactor",
    },
    -- event = "VeryLazy",
    opts = require "configs.refactor",
}
