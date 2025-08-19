local NS = { noremap = true, silent = true }

return {
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
    config = function()
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
    end,
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
    config = function(_)
      require("nvim-tree").setup {
        diagnostics = {
          enable = true,
          show_on_dirs = true,
        },
        view = {
          side = "right",
        },
        on_attach = function(bufnr)
          local api = require "nvim-tree.api"
          local map = vim.keymap.set

          api.config.mappings.default_on_attach(bufnr)
          map("n", "D", api.marks.bulk.delete, { desc = "hapus bulk di tree buffer", noremap = true, buffer = bufnr })
        end,
      }
    end,
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
