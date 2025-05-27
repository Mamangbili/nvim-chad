local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    py = { "ast-grep" },
    javascript = { "ast-grep" },
    rust = { "ast-grep" },
    typescript = { "ast-grep" },
    go = { "ast-grep" },
    cpp = { "clangd" },
    c = { "clangd" },
    jsx = { "ast-grep" },
    elixir = { "mix" },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  -- Set up format-on-save
  format_on_save = { timeout_ms = 500 },
}

return options
