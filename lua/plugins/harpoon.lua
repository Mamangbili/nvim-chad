return {
    "ThePrimeagen/harpoon",
    -- enabled = false,
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", "kevinhwang91/nvim-ufo" },
    config = require "configs.harpoon",

    keys = {
        {
            "<leader>a",
            function()
                require("harpoon"):list():add()
                print "File added to Harpoon list"
            end,
            desc = "Add file to Harpoon list",
        },
        {
            "<leader>e",
            function()
                require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
            end,
            desc = "Toggle Harpoon quick menu",
        },
        {
            "<leader>1",
            function()
                require("harpoon"):list():select(1)
            end,
            desc = "Harpoon file 1",
        },
        {
            "<leader>2",
            function()
                require("harpoon"):list():select(2)
            end,
            desc = "Harpoon file 2",
        },
        {
            "<leader>3",
            function()
                require("harpoon"):list():select(3)
            end,
            desc = "Harpoon file 3",
        },
        {
            "<leader>4",
            function()
                require("harpoon"):list():select(4)
            end,
            desc = "Harpoon file 4",
        },
        {
            "<C-p>",
            function()
                require("harpoon"):list():prev()
            end,
            desc = "Harpoon previous file",
        },
        {
            "<C-n>",
            function()
                require("harpoon"):list():next()
            end,
            desc = "Harpoon next file",
        },
    },
}
