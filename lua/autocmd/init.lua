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

  automcd({ "BufWinLeave" }, {
    pattern = "*",
    callback = function(args)
      local api = require "nvim-tree.api"
      api.tree.change_root(cwd)
      vim.cmd "AutoSession save"
    end,
  })
end

return M
