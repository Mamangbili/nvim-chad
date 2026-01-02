return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
        "Refactor",
    },
    -- event = "VeryLazy",
    opts = {
        prompt_func_return_type = {
            go = false,
            java = false,

            cpp = true,
            c = false,
            h = false,
            hpp = false,
            cxx = false,
        },
        prompt_func_param_type = {
            go = false,
            java = false,

            cpp = true,
            c = false,
            h = false,
            hpp = false,
            cxx = false,
        },
        printf_statements = {},
        print_var_statements = {},
        show_success_message = false,
    },
}
