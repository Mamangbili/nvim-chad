return {
    "kdheepak/lazygit.nvim",
    -- event = "VeryLazy",
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
    },
    opts = {
        config = {},
    },
    keys = {
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
    config = function()
        require("telescope").load_extension "lazygit"
    end,
    init = function()
        vim.g.lazygit_floating_window_use_plenary = 0
        vim.g.lazygit_floating_window_scaling_factor = 0.96
    end,
}
