-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "eslint", "yamlls", "glsl_analyzer" }
local nvlsp = require "nvchad.configs.lspconfig"

nvlsp.capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

local capabilities = nvlsp.capabilities

local function custom_on_attach(client, bufnr)
  nvlsp.on_attach(client, bufnr)

  if client.server_capabilities.semanticTokensProvider then
    vim.lsp.semantic_tokens.start(bufnr, client.id)
  end
end

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = capabilities,
  }
end

lspconfig["pyright"].setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = {
          reportUnusedVariable = "warning",
        },
        typeCheckingMode = "standard", -- Set type-checking mode to off
        diagnosticMode = "workspace", -- Disable diagnostics entirely
      },
    },
  },
}

lspconfig["ts_ls"].setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = capabilities,
  cmd = { "typescript-language-server", "--stdio" },
  settings = {
    tsserver = {
      filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
      format = {
        enable = true,
        insertSpaces = true,
        tabSize = 2,
      },
    },
  },
}

lspconfig.clangd.setup {
  on_attach = custom_on_attach,
  on_init = nvlsp.on_init,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--log=verbose",
    "--compile-commands-dir=build",
  },
  init_options = {
    fallbackFlags = { "-std=c++23" },
  },
  root_dir = require("lspconfig.util").root_pattern(".clangd", ".git"),
}

lspconfig.cmake.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = capabilities,
  cmd = { "cmake-language-server" },
  settings = {
    cmake = {
      filetypes = { "cmake" },
      format = {
        enable = true,
      },
    },
  },
}

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "CMakeLists.txt", "*.cmake", "CmakeLists.txt", "cmakelists.txt" },
  command = "set filetype=cmake",
})

lspconfig.omnisharp.setup {

  on_attach = nvlsp.on_attach,
  capabilities = capabilities,

  cmd = { vim.fn.stdpath "data" .. "/mason/bin/omnisharp.cmd" },

  -- enable_ms_build_load_projects_on_demand = false,
  --
  -- enable_editorconfig_support = true,
  --
  -- enable_roslyn_analysers = true,
  --
  -- enable_import_completion = true,
  --
  -- organize_imports_on_format = true,
  --
  -- enable_decompilation_support = true,
  --
  -- analyze_open_documents_only = false,
  --
  -- filetypes = { "cs", "vb", "csproj", "sln", "slnx", "props", "csx", "targets" },
}

-- local ccls_config = {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
--   cmd = {
--     "C:/Users/MSiGAMING/AppData/Local/nvim/ccls/Release/ccls.exe",
--     "--log-file=C:/Users/MSiGAMING/AppData/Local/Temp/ccls_nvchad.log",
--     "-v=1",
--   },
--   filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "cc", "cxx", "h", "hpp", "hxx" },
--   root_dir = require("lspconfig.util").root_pattern(".ccls", "compile_commands.json", ".git", ".hg"),
--   init_options = {
--     cache = {
--       directory = ".ccls-cache",
--     },
--     clang = {
--       resourceDir = "C:/msys64/mingw64/lib/clang/20/include",
--       extraArgs = {
--         "-isystemC:/msys64/mingw64/lib/clang/20/include",
--         "-std=c++20",
--       },
--     },
--     compilationDatabaseDirectory = "lsp",
--     index = {
--       threads = 0,
--       trackDependency = 2,
--     },
--     client = {
--       snippetSupport = true,
--     },
--   },
-- }

-- lspconfig.ccls.setup(ccls_config)

-- require("ccls").setup { lsp = { lspconfig = ccls_config } }
