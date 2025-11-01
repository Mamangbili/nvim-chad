return function(_)
  require("nvim-tree").setup {
    diagnostics = {
      enable = true,
      show_on_dirs = true,
    },
    view = {
      side = "right",
    },
    on_attach = function(bufnr)
      local api = require "nvim-tree.api"
      local map = vim.keymap.set

      api.config.mappings.default_on_attach(bufnr)
      map("n", "D", api.marks.bulk.delete, { desc = "hapus bulk di tree buffer", noremap = true, buffer = bufnr })
    end,
  }
end
