return {
    "nvim-tree/nvim-tree.lua",
    -- event = "VeryLazy",
    config = require "configs.nvim-tree",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen", "NvimTreeClose" },
    enable = false,
    keys = {
        {
            "<leader>z",
            function()
                vim.cmd "NvimTreeClose"
                vim.cmd "CopilotChatToggle"
            end,
            mode = { "n", "v" },
            desc = "copilot chat toggle",
            noremap = true,
        },
        {
            "<leader>q",
            function()
                if vim.bo.filetype == "copilot-chat" then
                    vim.cmd "CopilotChatClose"
                    return
                end
                if vim.bo.filetype == "NvimTree" then
                    require("nvim-tree.api").tree.close()
                    return
                end
                require("bufdelete").bufdelete(0, true)
            end,
            desc = "Smart Close Buffer",
        },
    },
}
