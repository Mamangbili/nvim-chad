local M = {}

M.setup = function()
  local automcd = vim.api.nvim_create_autocmd
  local cwd = vim.fn.getcwd()

  automcd("FileType", {
    pattern = { "cpp", "c", "h", "hpp", "cc" },
    callback = function()
      vim.keymap.set("n", "gf", vim.lsp.buf.code_action, { desc = "quick fix" })
    end,
  })

  -- Refresh nvim-tree when entering its buffer/reopen
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "NvimTree_*",
    callback = function()
      vim.cmd "NvimTreeRefresh"
    end,
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { ".env*", "NvTerm_float" },
    callback = function()
      vim.b.copilot_enabled = false
    end,
  })

  -- for CMake lsp
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "CMakeLists.txt", "*.cmake", "CmakeLists.txt", "cmakelists.txt" },
    command = "set filetype=cmake",
  })

  -- automcd({ "BufWinLeave" }, {
  --   pattern = "*",
  --   callback = function(args)
  --     local api = require "nvim-tree.api"
  --     api.tree.change_root(cwd)
  --     vim.cmd "AutoSession save"
  --   end,
  -- })
end

return M
