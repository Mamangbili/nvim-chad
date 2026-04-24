return {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    config = function()
        vim.g.VM_maps["Undo"] = "u"
        vim.g.VM_maps["Redo"] = "<C-r>"
    end,
}
