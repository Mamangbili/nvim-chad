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
