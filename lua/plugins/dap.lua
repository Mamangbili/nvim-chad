return {
    "mfussenegger/nvim-dap",
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    config = require "configs.dap-debugger",
    init = function()
        vim.keymap.set("n", "<leader>db", ":DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint" })
        vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>", { desc = "dap Continue" })
    end,
}
