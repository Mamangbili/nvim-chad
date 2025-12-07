return function()
    local opts = {
        cmdline = {
            enable = true,
        },
    }
    require("noice").setup(opts)
    vim.api.nvim_set_hl(0, "NotifyBackground", {
        bg = "#1E1E2E", -- Your preferred background color
        fg = "#CDD6F4", -- Optional: foreground color
    })
    require("notify").setup {
        fps = 30,
        top_down = false,
        stages = "static",
    }
end
