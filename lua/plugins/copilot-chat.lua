return {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim", branch = "master" },
            "github/copilot.vim",
        },
        -- event = "VeryLazy",
        cmd = { "CopilotChatToggle", "CopilotChatClose", "CopilotChatOpen" },
        build = "make tiktoken",
    }
