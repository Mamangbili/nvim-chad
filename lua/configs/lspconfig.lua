-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local servers = {
	"html",
	"cssls",
	"yamlls",
	-- "glsl_analyzer",
	"rust_analyzer",
	"gopls",
	"elixirls",
	"ty",
	"cmake",
	"ts_ls",
	"clangd",
	"powershell_es",
	"tailwindcss",
	"ols",
	"glsl_analyzer",
}
local nvlsp = require("nvchad.configs.lspconfig")

nvlsp.capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

local capabilities = nvlsp.capabilities
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

local orig = vim.lsp.handlers["textDocument/publishDiagnostics"]

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
	if result and result.diagnostics then
		for _, d in ipairs(result.diagnostics) do
			if d.severity == vim.diagnostic.severity.WARN then
				d.severity = vim.diagnostic.severity.ERROR
			end
		end
	end

	return orig(err, result, ctx, config)
end

vim.diagnostic.config({ update_in_insert = true })

-- use this syntax for newer lspconfig
vim.lsp.enable(servers)
vim.lsp.config("*", {
	on_attach = nvlsp.on_attach,
	on_init = nvlsp.on_init,
	capabilities = nvlsp.capabilities,
})

vim.lsp.config.clangd = {
	root_dir = require("lspconfig.util").root_pattern(".git", "main.odin"),
	init_options = {
		fallbackFlags = { "-std=c++23" },
	},
}

vim.lsp.config.ols = {
	init_options = {
		enable_checker_only_saved = true,
		struct_fields_underscore_visibility = "package",
		enable_snippets = true,
		enable_procedure_snippet = true,
		enable_auto_import = true,
		verbose = true,
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

vim.lsp.enable("omnisharp")
vim.lsp.config("omnisharp", {
	on_attach = nvlsp.on_attach,
	on_init = nvlsp.on_init,
	capabilities = capabilities,
	-- root_dir = require("lspconfig.util").root_pattern(".sln", ".csproj", ".git"),
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
vim.diagnostic.config({ virtual_text = false }) -- disable neovim's default virtual text diagnostics
