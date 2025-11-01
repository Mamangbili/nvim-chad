return function(_, opts)
  local dap = require "dap"
  dap.adapters.codelldb = {
    type = "executable",
    command = "C:\\Users\\MSiGAMING\\Desktop\\extension\\adapter\\codelldb.exe",
    -- khusus window
    -- detached = false,
  }
  dap.adapters.cppdbg = {
    id = "cppdbg",
    type = "executable",
    command = "C:\\Users\\MSiGAMING\\Desktop\\extension\\debugAdapters\\bin\\OpenDebugAD7.exe",
    options = {
      detached = false,
    },
  }
  dap.configurations.cpp = {
    {
      name = "Launch",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "\\", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
    },
  }
  local dapui = require "dapui"
  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.after.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.after.event_exited["dapui_config"] = function()
    dapui.close()
  end

  vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
  vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
  vim.keymap.set("n", "<F1>", dap.step_over)
  vim.keymap.set("n", "<F2>", dap.step_into)
  vim.keymap.set("n", "<F3>", dap.step_out)
  vim.keymap.set("n", "<F10>", dapui.close)
end
