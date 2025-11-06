local M = {}

M.setup = function()
  local automcd = vim.api.nvim_create_autocmd

  automcd("FileType", {
    pattern = { "cpp", "c", "h", "hpp", "cc" },
    callback = function()
      vim.keymap.set("n", "gf", vim.lsp.buf.code_action, { desc = "quick fix" })
    end,
  })

  automcd("VimEnter", {
    pattern = "*",
    callback = function(args)
      local api = require "nvim-tree.api"
      print "sebelum"
      if not api.tree.is_visible() then
        print "ea"
        api.tree.close()
        api.tree.open()
      end
    end,
  })

  automcd({ "VimLeave" }, {
    pattern = "*",
    callback = function(args)
      vim.cmd "AutoSession save"
    end,
  })
end

return M
