return function(_, opts)
    local actions = require "nvim-navbuddy.actions"
    require("nvim-navbuddy").setup {
        icons = {
            String = "",
        },
        lsp = { auto_attach = true },
        source_buffer = {
            follow_node = false, -- Keep the current node in focus on the source buffer
            highlight = true, -- Highlight the currently focused node
            reorient = "smart", -- "smart", "top", "mid" or "none"
            scrolloff = nil, -- scrolloff value when navbuddy is open
        },
        mappings = {
            ["<C-c>"] = actions.close(),
        },
    }
end
