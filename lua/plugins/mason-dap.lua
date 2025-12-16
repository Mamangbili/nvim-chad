return {
    "jay-babu/mason-nvim-dap.nvim",
    -- event = "VeryLazy",
    depedencies = {
        "mfussenegger/nvim-dap",
        "williamboman/mason.nvim",
    },
    opts = require "configs.dap-debugger",
}
