return function(_, _)
    local dap = require "dap"
    local opts = {
        winbar = {
            show = true,
            sections = {
                "watches",
                "scopes",
                "exceptions",
                "breakpoints",
                "threads",
                "repl",
                "console",
                "disassembly",
            },
            controls = {
                enabled = true,
            },
        },
    }
    local dapview = require "dap-view"
    dapview.setup(opts)

    dap.listeners.after.event_initialized["dapview_config"] = function()
        dapview.open()
    end
    dap.listeners.after.event_terminated["dapview_config"] = function()
        dapview.close()
    end
    dap.listeners.after.event_exited["dapview_config"] = function()
        dapview.close()
    end
end
