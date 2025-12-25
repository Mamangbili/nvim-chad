return {
    filesystem_watchers = {
        enable = false, -- enable = nvim tree leaks when cmake generate script
    },
    diagnostics = {
        enable = false,
        show_on_dirs = false,
    },
    view = {
        side = "right",
        float = {
            enable = true,
            open_win_config = {
                relative = "editor",
                border = "rounded",
                width = 40,
                height = 50,
                row = 1,
                col = vim.o.columns,
            },
        },
    },
    on_attach = function(bufnr)
        local api = require "nvim-tree.api"
        local map = vim.keymap.set

        api.config.mappings.default_on_attach(bufnr)
        map("n", "D", api.marks.bulk.delete, { desc = "hapus bulk di tree buffer", noremap = true, buffer = bufnr })
    end,
}
