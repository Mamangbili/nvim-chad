return {
    "folke/noice.nvim",
    -- enabled = false,
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    opts = {
        popupmenu = {
            enabled = false,
            backend = "cmp",
        },
        cmdline = {
            enable = true,
            format = {

                filter = {},
                lua = {
                    icon = "", -- ← no icon (was "tolua")
                    name = "lua", -- keep name for filtering (optional)
                    pattern = "^lua%s", -- matches ":lua " (case-insensitive by default)
                },
            },
        },
        lsp = {
            signature = {
                enabled = false,
            },
            hover = {
                enabled = false,
            },
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = false,
            },
        },
        presets = {
            lsp_doc_border = true, -- Preserve borders
        },
        views = {
            cmdline_popup = {
                border = {
                    style = "rounded",
                    padding = { 1, 2 },
                },
            },
        },
    },
    init = function(_, opts)
        -- require("noice").setup(opts)
        require("notify").setup {
            fps = 10,
            top_down = false,
            stages = "static",
        }
    end,
}
