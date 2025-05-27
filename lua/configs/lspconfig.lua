-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "eslint" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

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

lspconfig.clangd.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  root_dir = require("lspconfig.util").root_pattern("CMakeLists.txt", "compile_commands.json", ".git", ".hg"),
  cmd = {
    "clangd",
    "--compile-commands-dir=lsp/",
  },
}
