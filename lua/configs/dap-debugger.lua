return function(_, opts)
    local adapter_path = vim.fn.stdpath "data"
    local debugger_path = {
        debugpy = vim.fs.joinpath(adapter_path, "mason", "packages", "debugpy", "venv", "Scripts", "python.exe"),
        codelldb = vim.fs.joinpath(
            adapter_path,
            "mason",
            "packages",
            "codelldb",
            "extension",
            "adapter",
            "codelldb.exe"
        ),
        cpptools = vim.fs.joinpath(
            adapter_path,
            "mason",
            "packages",
            "cpptools",
            "extension",
            "debugAdapters",
            "bin",
            "OpenDebugAD7.exe"
        ),
    }

    -- if os is linux, use mason path in linux
    if vim.loop.os_uname().sysname ~= "Windows_NT" then
        debugger_path = {
            codelldb = vim.fs.joinpath(
                vim.fn.stdpath "data",
                "mason",
                "packages",
                "codelldb",
                "extension",
                "adapter",
                "codelldb"
            ),
            cpptools = vim.fs.joinpath(
                vim.fn.stdpath "data",
                "mason",
                "packages",
                "cpptools",
                "extension",
                "debugAdapters",
                "bin",
                "OpenDebugAD7"
            ),
            debugpy = vim.fs.joinpath(vim.fn.stdpath "data", "mason", "packages", "debugpy", "venv", "bin", "python"),
        }
    end

    local dap = require "dap"
    dap.adapters.codelldb = {
        id = "codelldb",
        type = "executable",
        command = debugger_path.codelldb,
        options = {
            detached = false,
        },
    }
    dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = debugger_path.cpptools,
        options = {
            detached = false,
        },
    }
    dap.configurations.cpp = {
        {
            name = "Launch file (codelldb)",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "\\", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            sourceLanguages = { "cpp" },
        },
    }

    dap.adapters.debugpy = {
        type = "executable",
        command = debugger_path.debugpy,
        args = { "-m", "debugpy.adapter" },
    }
    dap.configurations.python = {
        {
            type = "debugpy",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            pythonPath = function()
                return debugger_path.debugpy
            end,
        },
    }

    vim.fn.sign_define(
        "DapBreakpoint",
        { text = "•", texthl = "blue", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
    )
    vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "•", texthl = "blue", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
    )
    vim.fn.sign_define(
        "DapBreakpointRejected",
        { text = "•", texthl = "orange", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
    )
    vim.fn.sign_define(
        "DapStopped",
        { text = "•", texthl = "green", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
    )
    vim.fn.sign_define(
        "DapLogPoint",
        { text = "•", texthl = "yellow", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
    )

    vim.keymap.set("n", "<F1>", dap.step_over)
    vim.keymap.set("n", "<F2>", dap.step_into)
    vim.keymap.set("n", "<F3>", dap.step_out)
    vim.keymap.set("n", "<F4>", dap.terminate)

    vim.api.nvim_set_hl(0, "blue", { fg = "#ff0000" })
    vim.api.nvim_set_hl(0, "green", { fg = "#9ece6a" })
    vim.api.nvim_set_hl(0, "yellow", { fg = "#FFFF00" })
    vim.api.nvim_set_hl(0, "orange", { fg = "#f09000" })
end
