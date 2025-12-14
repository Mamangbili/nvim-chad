return function()
    local opts = {
        cmdline = {
            enable = true,
            format = {
                lua = {
                    icon = "", -- ← no icon (was "tolua")
                    name = "lua", -- keep name for filtering (optional)
                    pattern = "^lua%s", -- matches ":lua " (case-insensitive by default)
                },
            },
        },
        lsp = {
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
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
    }
    require("noice").setup(opts)
    require("notify").setup {
        fps = 10,
        top_down = false,
        stages = "static",
    }
end
