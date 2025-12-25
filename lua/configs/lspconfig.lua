-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local servers = {
    "html",
    "cssls",
    "yamlls",
    "glsl_analyzer",
    "rust_analyzer",
    "gopls",
    "elixirls",
    "ty",
    "cmake",
    "ts_ls",
    "clangd",
    "powershell_es",
}
local nvlsp = require "nvchad.configs.lspconfig"

nvlsp.capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

local capabilities = nvlsp.capabilities
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

-- use this syntax for newer lspconfig
vim.lsp.enable(servers)
vim.lsp.config("*", {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
})

vim.lsp.config.clangd = {
    init_options = {
        fallbackFlags = { "-std=c++23" },
    },
}

vim.lsp.config("powershell_es", {
    settings = {
        powershell = {
            codeFormatting = {
                autoCorrectAliases = true,
                openBraceOnSameLine = true,
                spacesBeforeOpenBrace = 1,
                spacesAroundOperator = true,
            },
        },
    },
})

vim.lsp.enable "omnisharp"
vim.lsp.config("omnisharp", {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = capabilities,
    root_dir = require("lspconfig.util").root_pattern(".sln", ".csproj", ".git"),
})

-- vim.lsp.enable "pyright"
-- vim.lsp.config("pyright", {
--     on_attach = nvlsp.on_attach,
--     on_init = nvlsp.on_init,
--     capabilities = capabilities,
--     settings = {
--         python = {
--             analysis = {
--                 useLibraryCodeForTypes = true,
--                 diagnosticSeverityOverrides = {
--                     reportUnusedVariable = "warning",
--                 },
--                 typeCheckingMode = "standard", -- Set type-checking mode to off
--                 diagnosticMode = "workspace", -- Disable diagnostics entirely
--             },
--         },
--     },
-- })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "CMakeLists.txt", "*.cmake", "CmakeLists.txt", "cmakelists.txt" },
    command = "set filetype=cmake",
})
