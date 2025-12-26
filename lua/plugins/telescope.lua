return {
    "nvim-telescope/telescope.nvim",
    -- event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    cmd = { "Telescope" },
    keys = {
        {
            "<leader>fx",
            function()
                vim.cmd "Telescope lsp_workspace_symbols"
            end,
            desc = "Find symbols in workspace",
            mode = "n",
        },
        {
            "<leader>fs",
            function()
                vim.cmd "Telescope lsp_document_symbols"
            end,
            desc = "Find document symbols",
            mode = "n",
        },
        {
            "<leader>fr",
            function()
                vim.cmd "Telescope lsp_references"
            end,
            desc = "Find document references",
            mode = "n",
        },
        {
            "<leader>fi",
            "<Cmd>Telescope hierarchy incoming_calls<Cr>",
            desc = "Hierarchy incoming_calls",
            mode = "n",
        },
        {
            "<leader>fo",
            "<Cmd>Telescope hierarchy outgoing_calls<Cr>",
            desc = "Hierarchy outgoing calls",
            mode = "n",
        },
    },
}
