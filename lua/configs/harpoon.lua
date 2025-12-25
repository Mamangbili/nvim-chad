return function()
    local harpoon = require "harpoon"
    local extensions = require "harpoon.extensions"

    -- REQUIRED
    harpoon:setup {
        settings = {
            save_on_toggle = true,
        },
    }
    harpoon:extend(extensions.builtins.command_on_nav "UfoEnableFold")
    -- REQUIRED
    vim.keymap.set("n", "<leader>a", function()
        harpoon:list():add()
        print "File added to Harpoon list"
    end, { desc = "Add file to Harpoon list" })
    vim.keymap.set("n", "<leader>e", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Toggle Harpoon quick menu" })

    vim.keymap.set("n", "<leader>1", function()
        harpoon:list():select(1)
    end, { desc = "Harpoon file 1" })
    vim.keymap.set("n", "<leader>2", function()
        harpoon:list():select(2)
    end, { desc = "Harpoon file 2" })
    vim.keymap.set("n", "<leader>3", function()
        harpoon:list():select(3)
    end, { desc = "Harpoon file 3" })
    vim.keymap.set("n", "<leader>4", function()
        harpoon:list():select(4)
    end, { desc = "Harpoon file 4" })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<C-p>", function()
        harpoon:list():prev()
    end, { desc = "Harpoon previous file" })
    vim.keymap.set("n", "<C-n>", function()
        harpoon:list():next()
    end, { desc = "Harpoon next file" })
end
