return {
    "jmacadie/telescope-hierarchy.nvim",
    dependencies = {
        {
            "nvim-telescope/telescope.nvim",
            dependencies = { "nvim-lua/plenary.nvim" },
        },
    },
    keys = {
        { -- lazy style key map
            -- Choose your own keys, this works for me
            "<leader>fh",
            "<cmd>Telesope hierarchy incoming_calls<cr>",
            desc = "LSP: [S]earch [I]ncoming Calls",
        },
        {
            "<leader>fo",
            "<cmd>Telescope hierarchy outgoing_calls<cr>",
            desc = "LSP: [S]earch [O]utgoing Calls",
        },
    },
    opts = {
        -- don't use `defaults = { }` here, do this in the main telescope spec
        extensions = {
            hierarchy = {},
            -- no other extensions here, they can have their own spec too
        },
    },
    config = function(_, opts)
        require("telescope").setup(opts)
        require("telescope").load_extension "hierarchy"
    end,
}
