return {
    "nvim-mini/mini.nvim",
    version = false,
    event = "FileType",
    config = function(_, opts)
        require("mini.surround").setup {
            mappings = {
                add = "Sa", -- Add surrounding in Normal and Visual modes
                delete = "Sd", -- Delete surrounding
                replace = "Sr", -- Replace surrounding

                suffix_last = "l", -- Suffix to search with "prev" method
                suffix_next = "n", -- Suffix to search with "next" method
            },
        }
    end,
    keys = {
        { "Sa", desc = "Add surrounding", mode = { "n", "v" } },
        { "Sd", desc = "Delete surrounding" },
        { "Sr", desc = "Replace surrounding" },
    },
}
