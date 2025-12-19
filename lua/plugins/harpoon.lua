return {
    "ThePrimeagen/harpoon",
    -- enabled = false,
    event = "VeryLazy",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = require "configs.harpoon",
}
