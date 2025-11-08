-- check if .clangd-format exist
local function clangd_format_exists_in_root()
  local cwd = vim.fn.getcwd()
  local clangd_format_path = cwd .. "\\.clang-format"
  local file = io.open(clangd_format_path, "r")
  print("Checking for .clangd-format at: " .. clangd_format_path .. " - Found: " .. tostring(file ~= nil))

  if file then
    io.close(file)
    return {}
  else
    return {
      "--style={BasedOnStyle: Chromium, IndentWidth: 4, AlignConsecutiveDeclarations: true}",
      "--fallback-style=Google",
    }
  end
end

local options = {
  formatters = {
    clang_format = {
      prepend_args = clangd_format_exists_in_root(),
    },
  },

  formatters_by_ft = {
    lua = { "stylua" },
    py = { "ast-grep" },
    javascript = { "ast-grep" },
    rust = { "ast-grep" },
    typescript = { "ast-grep" },
    go = { "ast-grep" },
    -- cpp = { "clang-format" },
    cpp = { "clang_format" },
    c = { "clangd" },
    jsx = { "ast-grep" },
    elixir = { "mix" },
  },
  default_format_opts = {},
  -- Set up format-on-save
  format_on_save = { timeout_ms = 500 },
}

return options
