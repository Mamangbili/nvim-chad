local NS = { noremap = true, silent = true }

return {
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
  { "github/copilot.vim", lazy = false },
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
      -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
      -- configs for us. We won't use data, as everything is iin it's own namespace (telescope
      -- defaults, as well as each extension).i
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
    event = "VeryLazy",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },

    config = function(_, opts)
      local tokyonight = require "tokyonight"
      tokyonight.setup(opts)
      tokyonight.load()
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    config = require "configs.nvim-tree",
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
      },
    },
  },
  {
    "ewis6991/gitsigns.nvim",
    event = "VeryLazy",
  },
  {
    "Badhi/nvim-treesitter-cpp-tools",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    -- Optional: Configuration
    opts = function()
      local options = {
        preview = {
          quit = "q", -- optional keymapping for quit preview
          accept = "<tab>", -- optional keymapping for accept preview
        },
        header_extension = "h", -- optional
        source_extension = "cpp", -- optional
        custom_define_class_function_commands = { -- optional
          TSCppImplWrite = {
            output_handle = require("nt-cpp-tools.output_handlers").get_add_to_cpp(),
          },
          --[[
                <your impl function custom command name> = {
                    output_handle = function (str, context) 
                        -- string contains the class implementation
                        -- do whatever you want to do with it
                    end
                }
                ]]
        },
      }
      return options
    end,
    -- End configuration
    config = true,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "VeryLazy",
    config = require "configs.ufo",
    opts = {
      provider_selector = function(_, _, _)
        return { "lsp", "indent" }
      end,
    },
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

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
