return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
        "williamboman/mason.nvim",
    },
    -- event = "VeryLazy",
    opts = {
        ensure_installed = {
            "debugpy",
            "stylua",
            "clangd",
            "clang-format",
            "codelldb",
            "ast-grep",
            "fixjson",
            "ty",
            {
                "gersemi",
                condition = function()
                    return vim.fn.executable "python3" == 1
                end,
            },
            "html-lsp",
            "pyright",
            "yaml-language-server",
            "typescript-language-server",
            "rust-analyzer",
            {
                "gopls",
                condition = function()
                    return vim.fn.executable "go" == 1
                end,
            },
            "css-lsp",
            "elixir-ls",
        },
    },
}
