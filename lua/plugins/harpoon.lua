return {
    "ThePrimeagen/harpoon",
    -- enabled = false,
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", "kevinhwang91/nvim-ufo" },
    config = function()
        local harpoon = require "harpoon"
        local extensions = require "harpoon.extensions"

        -- REQUIRED
        harpoon:setup {
            settings = {
                save_on_toggle = true,
            },
            global_settings = {
                tabline = false,
                tabline_prefix = "   ",
                tabline_suffix = "   ",
            },
        }
        harpoon:extend(extensions.builtins.command_on_nav "UfoEnableFold")
    end,

    keys = {
        {
            "<leader>a",
            function()
                vim.notify "File added to Harpoon list"
                require("harpoon"):list():add()
            end,
            desc = "Add file to Harpoon list",
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
            "<leader>5",
            function()
                require("harpoon"):list():select(5)
            end,
            desc = "Harpoon file 5",
        },
        {
            "<leader>6",
            function()
                require("harpoon"):list():select(6)
            end,
            desc = "Harpoon file 6",
        },
        {
            "<leader>7",
            function()
                require("harpoon"):list():select(7)
            end,
            desc = "Harpoon file 7",
        },
        {
            "<leader>8",
            function()
                require("harpoon"):list():select(8)
            end,
            desc = "Harpoon file 8",
        },
        {
            "<leader>9",
            function()
                require("harpoon"):list():select(9)
            end,
            desc = "Harpoon file 9",
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
