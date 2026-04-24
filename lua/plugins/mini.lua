return {
    "nvim-mini/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function(_, opts)
        vim.keymap.set({ "n", "v" }, "S", "<Nop>", { noremap = true })

        require("mini.surround").setup {
            mappings = {
                add = "Sa", -- Add surrounding in Normal and Visual modes
                delete = "Sd", -- Delete surrounding
                replace = "Sr", -- Replace surrounding

                find = "", -- Find surrounding (to the right)
                find_left = "", -- Find surrounding (to the left)
                highlight = "", -- Highlight surrounding
                suffix_last = "", -- Suffix to search with "prev" method
                suffix_next = "",
            },
        }
    end,
    keys = {
        { "Sa", desc = "Add surrounding", mode = { "n", "v" } },
        { "Sd", desc = "Delete surrounding", mode = { "n" } },
        { "Sr", desc = "Replace surrounding", mode = { "n" } },
    },
}
