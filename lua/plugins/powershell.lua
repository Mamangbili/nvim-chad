return {
    "TheLeoP/powershell.nvim",
    ---@type powershell.user_config
    ft = { "ps1", "psm1", "psd1" },
    opts = {
        bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services",
    },
}
