return {
    "folke/noice.nvim",
    -- enabled = false,
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    opts = {
        routes = {
            {
                filter = { event = "msg_show", kind = { "shell_out", "shell_err" } },
                view = "split",
                opts = {
                    level = "info",
                    skip = false,
                    replace = false,
                },
            },
        },
        cmdline = {
            enable = true,
            format = {

                filter = { pattern = "" },
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
            filter_options = {},
            cmdline_popup = {
                position = {
                    row = "50%",
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
            },
            popupmenu = {
                relative = "editor",
                position = {
                    row = "63%",
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = 10,
                },
                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },
                win_options = {
                    winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
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
