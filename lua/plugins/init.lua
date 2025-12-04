local NS = { noremap = true, silent = true }

return {
    { "luk400/vim-jukit" },
    {
        "KaitoMuraoka/websearcher.nvim",
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "SmiteshP/nvim-navbuddy",
                dependencies = {
                    "SmiteshP/nvim-navic",
                    "MunifTanjim/nui.nvim",
                },
                opts = {
                    lsp = { auto_attach = true },
                    source_buffer = {
                        follow_node = false, -- Keep the current node in focus on the source buffer
                        highlight = true, -- Highlight the currently focused node
                        reorient = "smart", -- "smart", "top", "mid" or "none"
                        scrolloff = nil, -- scrolloff value when navbuddy is open
                    },
                },
            },
        },
        -- your lsp config or other stuff
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        lazy = false,
        opts = {
            mode = "cursor",
        },
        init = function()
            vim.cmd "hi TreesitterContextBottom gui=underline guisp=Grey"
        end,
    },
    { "famiu/bufdelete.nvim" },
    { "OXY2DEV/foldtext.nvim", lazy = false },
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "VeryLazy",
        config = require "configs.ufo",
        init = function()
            vim.o.foldenable = true
            vim.o.foldlevel = 99
            vim.o.foldcolumn = "1"
            vim.o.foldlevelstart = 99
        end,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim", branch = "master" },
            "github/copilot.vim",
        },
        event = "VeryLazy",
        cmd = { "CopilotChatToggle", "CopilotChatClose", "CopilotChatOpen" },
        build = "make tiktoken",
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = require "configs.harpoon",
    },
    {
        "isakbm/gitgraph.nvim",
        dependencies = {
            "sindrets/diffview.nvim",
        },
        opts = {
            git_cmd = "git",
            symbols = {
                merge_commit = "M",
                commit = "*",
            },
            format = {
                timestamp = "%H:%M:%S %d-%m-%Y",
                fields = { "hash", "timestamp", "author", "branch_name", "tag" },
            },
            hooks = {
                -- Check diff of a commit
                on_select_commit = function(commit)
                    vim.notify("DiffviewOpen " .. commit.hash .. "^!")
                    vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
                end,
                -- Check diff from commit a -> commit b
                on_select_range_commit = function(from, to)
                    vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                    vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                end,
            },
        },
        keys = {
            {
                "<leader>gl",
                function()
                    require("gitgraph").draw({}, { all = true, max_count = 5000 })
                end,
                desc = "GitGraph - Draw",
            },
        },
    },
    {
        "kdheepak/lazygit.nvim",
        event = "VeryLazy",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
        },
        opts = {
            config = {},
        },
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
        config = function()
            require("telescope").load_extension "lazygit"
        end,
        init = function()
            vim.g.lazygit_floating_window_use_plenary = 0
            vim.g.lazygit_floating_window_scaling_factor = 0.96
        end,
    },

    {
        "NeogitOrg/neogit",
        cmd = "Neogit",
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration
            "nvim-telescope/telescope.nvim", -- optional
        },
        opts = require "configs.neogit",
    },
    {
        "dnlhc/glance.nvim",
        cmd = "Glance",
        opts = {
            border = {
                enable = true,
            },
        },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "VeryLazy",
        opts = {},
    },
    { "github/copilot.vim", event = "VimEnter" },
    { "OmniSharp/omnisharp-vim" },
    { "ranjithshegde/ccls.nvim" },
    {
        "jmacadie/telescope-hierarchy.nvim",
        dependencies = {
            {
                "nvim-telescope/telescope.nvim",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
        },
        keys = {
            { -- lazy style key map
                -- Choose your own keys, this works for me
                "<leader>fh",
                "<cmd>Telesope hierarchy incoming_calls<cr>",
                desc = "LSP: [S]earch [I]ncoming Calls",
            },
            {
                "<leader>fo",
                "<cmd>Telescope hierarchy outgoing_calls<cr>",
                desc = "LSP: [S]earch [O]utgoing Calls",
            },
        },
        opts = {
            -- don't use `defaults = { }` here, do this in the main telescope spec
            extensions = {
                hierarchy = {},
                -- no other extensions here, they can have their own spec too
            },
        },
        config = function(_, opts)
            require("telescope").setup(opts)
            require("telescope").load_extension "hierarchy"
        end,
    },

    {
        "numToStr/Comment.nvim",
        opts = {
            ignore = "'^$",
        },
    },

    "nvim-neotest/nvim-nio",
    {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        depedencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = require "configs.dap-ui",
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        event = "VeryLazy",
        depedencies = {
            "mfussenegger/nvim-dap",
            "williamboman/mason.nvim",
        },
        opts = {},
    },
    {
        "mfussenegger/nvim-dap",
    },
    {
        "Vonr/align.nvim",
        branch = "v2",
        lazy = true,
        init = function()
            vim.keymap.set("x", "aa", function()
                require("align").align_to_char {
                    length = 1,
                }
            end, NS)

            -- Aligns to 2 characters with previews
            vim.keymap.set("x", "ad", function()
                require("align").align_to_char {
                    preview = true,
                    length = 2,
                }
            end, NS)

            -- Aligns to a string with previews
            vim.keymap.set("x", "aw", function()
                require("align").align_to_string {
                    preview = true,
                    regex = false,
                }
            end, NS)

            -- Aligns to a Vim regex with previews
            vim.keymap.set("x", "ar", function()
                require("align").align_to_string {
                    preview = true,
                    regex = true,
                }
            end, NS)

            -- Example gawip to align a paragraph to a string with previews
            vim.keymap.set("n", "gaw", function()
                local a = require "align"
                a.operator(a.align_to_string, {
                    regex = false,
                    preview = true,
                })
            end, NS)

            -- Example gaaip to align a paragraph to 1 character
            vim.keymap.set("n", "gaa", function()
                local a = require "align"
                a.operator(a.align_to_char)
            end, NS)
        end,
    },
    {

        "kylechui/nvim-surround",
        version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup {}
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" }, -- uncomment for format on save
        cmd = "ConformInfo",
        opts = require "configs.conform",
    },

    -- These are some examples, uncomment them if you want to see them work!
    {
        "neovim/nvim-lspconfig",
        -- lazy = false,
        event = "VimEnter",
        config = function()
            require "configs.lspconfig"
        end,
    },

    -- {
    --   "folke/tokyonight.nvim",
    --   lazy = false,
    --   priority = 1000,
    --   opts = {
    --     transparent = true,
    --   },
    --
    --   config = function(_, opts)
    --     local tokyonight = require "tokyonight"
    --     tokyonight.setup(opts)
    --     tokyonight.load()
    --   end,
    -- },

    {
        "nvim-tree/nvim-tree.lua",
        event = "VeryLazy",
        config = require "configs.nvim-tree",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enable = false,
    },

    {
        "nvim-tree/nvim-web-devicons",
        opts = {
            override = {
                CSS = {
                    icon = "",
                    color = "#42A5F5",
                    name = "CSS",
                },
            },
        },
    },
    {
        "folke/which-key.nvim",
        lazy = false,
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "clangd ",
                "clangd-format",
                "codelldb",
                "eslint-lsp",
                "ast-grep",
                "fixjson",
                "gersemi",
                "mix",
                "html",
                "cssls",
                "pyright",
                "yamlls",
                "typescript-language-server",
                "rust-analyzer",
                "gopls",
                "css-lsp",
                "elixirls",
            },
        },
    },
    {
        "ewis6991/gitsigns.nvim",
        event = "VeryLazy",
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        event = "VeryLazy",
        opts = require "configs.refactor",
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "c",
                "cpp",
                "lua",
                "python",
                "javascript",
                "typescript",
                "tsx",
                "rust",
                "go",
                "java",
                "json",
                "html",
                "css",
                "bash",
                "yaml",
                "cmake",
            },
        },
        build = function()
            local function cpp_priority()
                local file_path = vim.fn.stdpath "data" .. "/lazy/nvim-treesitter/queries/cpp/highlights.scm"
                local lines = {}
                for line in io.lines(file_path) do
                    if line:match "%(namespace_identifier%) %@module" then
                        table.insert(lines, "((namespace_identifier) @module (#set! priority 105))")
                    else
                        table.insert(lines, line)
                    end
                end
                local f = io.open(file_path, "w")
                f:write(table.concat(lines, "\n"))
                f:close()
            end

            cpp_priority()
        end,
    },
}
