local M = {}

M.setup = function()
  local autocmd = vim.api.nvim_create_autocmd
  local cwd = vim.fn.getcwd()

  autocmd("FileType", {
    pattern = { "cpp", "c", "h", "hpp", "cc" },
    callback = function()
      vim.keymap.set("n", "gf", vim.lsp.buf.code_action, { desc = "quick fix" })
    end,
  })

  -- Refresh nvim-tree when entering its buffer/reopen
  autocmd("BufWinLeave", {
    pattern = "NvimTree_*",
    callback = function()
      vim.cmd "NvimTreeRefresh"
    end,
  })

  autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { ".env*", "NvTerm_float" },
    callback = function()
      vim.b.copilot_enabled = false
    end,
  })

  -- for CMake lsp
  autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "CMakeLists.txt", "*.cmake", "CmakeLists.txt", "cmakelists.txt" },
    command = "set filetype=cmake",
  })

  autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
      vim.keymap.set("n", "<leader>ct", "<cmd>NvimTreeCollapse<cr>", { desc = "Collapse Tree", noremap = true })
    end,
  })

  autocmd("FileType", {
    pattern = "aerial-nav",
    callback = function()
      vim.keymap.set("n", "q", "<cmd>AerialNavClose<cr>", { desc = "Aerial nav close", noremap = true })
    end,
  })
end

return M
