return {
    "igorlfs/nvim-dap-view",
    dependencies = { "mfussenegger/nvim-dap" },
    config = require "configs.dap-view",
    cmd = { "DapToggleBreakpoint", "DapContinue" },
    -- event = "VeryLazy",
}
