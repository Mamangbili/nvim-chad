return {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "DapViewToggle", "DapContinue" },
    config = function()
        require("nvim-dap-virtual-text").setup {
            commented = true,
            virt_text_pos = "inline",
            display_callback = function(variable, _, _, _, options)
                if options.virt_text_pos == "inline" then
                    return " = " .. variable.value:gsub("%s+", " ")
                else
                    return variable.name .. " = " .. variable.value:gsub("%s+", " ")
                end
            end,
        }
    end,
    -- event = "VeryLazy",
}
