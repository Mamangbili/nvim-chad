local keys = {}

for level = 0, 9 do
	table.insert(keys, {
		"z" .. level .. "c",
		function()
			require("ufo").closeFoldsWith(level)
		end,
		mode = "n",
		desc = "Close folds at level " .. level,
	})
	table.insert(keys, {
		"z" .. level .. "o",
		function()
			require("fold").fold_exact_level_open(level)
		end,
		mode = "n",
		desc = "Open folds at level " .. level,
	})
	table.insert(keys, {
		"z" .. level .. level .. "c",
		function()
			require("fold").fold_level_in_root(level)
		end,
		mode = "n",
		desc = "Close all folds at level " .. level .. " in root",
	})
	table.insert(keys, {
		"z" .. level .. level .. "o",
		function()
			require("fold").open_level_in_root(level)
		end,
		mode = "n",
		desc = "Open all folds at level " .. level .. " in root",
	})
end

table.insert(keys, {
	"K",
	function()
		local winid = require("ufo").peekFoldedLinesUnderCursor()
		if not winid then
			vim.lsp.buf.hover()
		end
	end,
	mode = "n",
	desc = "Peek fold or LSP hover",
})

local function ensure_dir(path)
	path = vim.fn.expand(path)
	local stat = vim.loop.fs_stat(path)
	if not (stat and stat.type == "directory") then
		vim.fn.mkdir(path, "p") -- 0755
	end
end
return {
	{
		"ThePrimeagen/99",
		enabled = false,
		event = "VeryLazy",
		config = function()
			local _99 = require("99")

			-- For logging that is to a file if you wish to trace through requests
			-- for reporting bugs, i would not rely on this, but instead the provided
			-- logging mechanisms within 99.  This is for more debugging purposes
			local cwd = vim.uv.cwd()
			local basename = vim.fs.basename(cwd)
			_99.setup({
				provider = _99.OpenCodeProvider,
				logger = {
					level = _99.DEBUG,
					path = "/tmp/" .. basename .. ".99.debug",
					print_on_error = true,
				},

				--- A new feature that is centered around tags
				completion = {
					--- Defaults to .cursor/rules
					-- I am going to disable these until i understand the
					-- problem better.  Inside of cursor rules there is also
					-- application rules, which means i need to apply these
					-- differently
					-- cursor_rules = "<custom path to cursor rules>"

					--- A list of folders where you have your own SKILL.md
					--- Expected format:
					--- /path/to/dir/<skill_name>/SKILL.md
					---
					--- Example:
					--- Input Path:
					--- "scratch/custom_rules/"
					---
					--- Output Rules:
					--- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
					--- ... the other rules in that dir ...
					---
					custom_rules = {
						"scratch/custom_rules/",
					},

					--- What autocomplete do you use.  We currently only
					--- support cmp right now
					source = "cmp",
				},

				--- WARNING: if you change cwd then this is likely broken
				--- ill likely fix this in a later change
				---
				--- md_files is a list of files to look for and auto add based on the location
				--- of the originating request.  That means if you are at /foo/bar/baz.lua
				--- the system will automagically look for:
				--- /foo/bar/AGENT.md
				--- /foo/AGENT.md
				--- assuming that /foo is project root (based on cwd)
				md_files = {
					"AGENTS.md",
				},
			})

			-- Create your own short cuts for the different types of actions
			vim.keymap.set("n", "<leader>9f", function()
				_99._99.fill_in_function()
			end, { desc = "fill in function" })
			-- take extra note that i have visual selection only in v mode
			-- technically whatever your last visual selection is, will be used
			-- so i have this set to visual mode so i dont screw up and use an
			-- old visual selection
			--
			-- likely ill add a mode check and assert on required visual mode
			-- so just prepare for it now
			vim.keymap.set("v", "<leader>9v", function()
				_99.visual()
			end)

			--- if you have a request you dont want to make any changes, just cancel it
			vim.keymap.set("v", "<leader>9s", function()
				_99.stop_all_requests()
			end)

			--- Example: Using rules + actions for custom behaviors
			--- Create a rule file like ~/.rules/debug.md that defines custom behavior.
			--- For instance, a "debug" rule could automatically add printf statements
			--- throughout a function to help debug its execution flow.
			vim.keymap.set("n", "<leader>9fd", function()
				_99.fill_in_function()
			end)
		end,
	},

	{ "famiu/bufdelete.nvim" },

	{
		"hrsh7th/nvim-cmp",
		opts = function(_, opts)
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- Assign the new mappings to the opts table
			opts.mapping = cmp.mapping.preset.insert({
				["<C-space>"] = cmp.mapping.complete(), -- Manual trigger
				["<CR>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						if luasnip.expandable() then
							luasnip.expand()
						else
							cmp.confirm({ select = true })
						end
					else
						fallback()
					end
				end),

				["<Tab>"] = cmp.mapping(function(fallback)
					if luasnip.locally_jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { "i", "s" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					end
				end, { "i", "s" }),

				["<Down>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					else
						fallback()
					end
				end, { "i", "s" }),

				["<Up>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					else
						fallback()
					end
				end, { "i", "s" }),
			})

			-- CRITICAL: You must return the opts table!
			return opts
		end,
	},

	{
		"catgoose/nvim-colorizer.lua",
		enabled = true,
		event = "BufReadPre",
		opts = { -- set to setup table
		},
	},

	{
		"numToStr/Comment.nvim",
		opts = {
			ignore = "'^$",
		},
	},

	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" }, -- uncomment for format on save
		cmd = "ConformInfo",
		opts = require("configs.conform"),
	},

	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
			"github/copilot.vim",
		},
		-- event = "VeryLazy",
		cmd = { "CopilotChatToggle", "CopilotChatClose", "CopilotChatOpen" },
		build = "make tiktoken",
	},

	{
		{
			"Badhi/nvim-treesitter-cpp-tools",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			ft = { "cpp", "h", "hpp" },
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
			"DanielMSussman/simpleCppTreesitterTools.nvim",
			ft = { "cpp", "h", "hpp" },
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			config = function()
				require("simpleCppTreesitterTools").setup()
			end,
		},
	},

	{
		"Jorenar/nvim-dap-disasm",
		cmd = { "DapViewToggle", "DapContinue" },
		config = true,
		dependencies = { "igorlfs/nvim-dap-view" },
	},

	{
		"igorlfs/nvim-dap-view",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function(_, _)
			local dap = require("dap")
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
			local dapview = require("dap-view")
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
		end,
		cmd = { "DapToggleBreakpoint", "DapContinue" },
		-- event = "VeryLazy",
	},

	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter",
		},
		cmd = { "DapViewToggle", "DapContinue" },
		config = function()
			require("nvim-dap-virtual-text").setup({
				commented = true,
				virt_text_pos = "inline",
				display_callback = function(variable, _, _, _, options)
					if options.virt_text_pos == "inline" then
						return " = " .. variable.value:gsub("%s+", " ")
					else
						return variable.name .. " = " .. variable.value:gsub("%s+", " ")
					end
				end,
			})
		end,
		-- event = "VeryLazy",
	},

	{
		"mfussenegger/nvim-dap",
		cmd = { "DapContinue", "DapToggleBreakpoint" },
		dependencies = {
			"igorlfs/nvim-dap-view",
			"theHamsta/nvim-dap-virtual-text",
			"igorlfs/nvim-dap-view",
			"Jorenar/nvim-dap-disasm",
		},
		config = function(_, opts)
			local adapter_path = vim.fn.stdpath("data")
			local debugger_path = {
				debugpy = vim.fs.joinpath(
					adapter_path,
					"mason",
					"packages",
					"debugpy",
					"venv",
					"Scripts",
					"python.exe"
				),
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
						vim.fn.stdpath("data"),
						"mason",
						"packages",
						"codelldb",
						"extension",
						"adapter",
						"codelldb"
					),
					cpptools = vim.fs.joinpath(
						vim.fn.stdpath("data"),
						"mason",
						"packages",
						"cpptools",
						"extension",
						"debugAdapters",
						"bin",
						"OpenDebugAD7"
					),
					debugpy = vim.fs.joinpath(
						vim.fn.stdpath("data"),
						"mason",
						"packages",
						"debugpy",
						"venv",
						"bin",
						"python"
					),
				}
			end

			local dap = require("dap")
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
		end,
		init = function()
			-- local dap = require "dap"
			-- vim.keymap.set("n", "<leader>db", function()
			--     dap.toggle_breakpoint()
			-- end, { desc = "Toggle breakpoint" })
			-- vim.keymap.set("n", "<leader>dc", function()
			--     dap.continue()
			-- end, { desc = "dap Continue" })
		end,
		keys = {
			{
				"<leader>db",
				mode = { "n", "x", "o" },
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Flash",
			},
			{
				"<leader>dc",
				mode = { "n", "x", "o" },
				function()
					require("dap").continue()
				end,
				desc = "Continue",
			},
		},
	},

	{
		"luckasRanarison/nvim-devdocs",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
		cmd = {
			"DevdocsInstall",
			"DevdocsSearch",
			"DevdocsOpen",
			"DevdocsFetchs",
			"DevdocsKeywordprg",
			"DevdocsKeywordprgs",
		},
	},

	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "LspAttach",
		priority = 1000,
		opts = {
			options = {
				multilines = true,
			},
		},
		config = function(_, opts)
			require("tiny-inline-diagnostic").setup(opts)
		end,
	},

	{
		"AdrianMosnegutu/docscribe.nvim",
		enabled = false,
		event = "VeryLazy",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("docscribe").setup({
				ui = {
					highlight = {
						style = "signature", -- "signature" | "full" | "none"
						timeout = 2000, -- Highlight duration (ms)
						bg = "#545454", -- Highlight color
					},
				},
				llm = {
					provider = "google", -- "ollama" | "google" | "groq"
					provider_opts = {
						ollama = {
							model = "llama3.2",
						},
						google = {
							model = "gemini-2.5-flash",
							api_key = os.getenv("gemini_key"),
						},
						groq = {
							model = "llama-3.1-8b-instant",
							api_key = os.getenv("GROQ_API_KEY"),
						},
					},
				},
			})
		end,
	},

	{
		"folke/flash.nvim",
		-- event = "VeryLazy",
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"St",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},

	{
		"nvim-focus/focus.nvim",
		version = false,
		event = "CursorMoved",
		config = function()
			require("focus").setup({
				autoresize = {
					minwidth = 85,
				},
			})
		end,
	},

	{
		"OXY2DEV/foldtext.nvim",
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
		"github/copilot.vim",
	},

	{
		"lewis6991/gitsigns.nvim",
		enabled = true,
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
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async", "OXY2DEV/foldtext.nvim" },
		config = function(_, opts)
			-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
			local more_msg_highlight = vim.api.nvim_get_hl_id_by_name("MoreMsg")
			local non_text_highlight = vim.api.nvim_get_hl_id_by_name("NonText")

			local fold_virt_text_handler = function(
				-- The start_line's text.
				virtual_text_chunks,
				-- Start and end lines of fold.
				start_line,
				end_line,
				-- Total text width.
				text_width,
				-- fun(str: string, width: number): string Trunctation function.
				truncate,
				-- Context for the fold.
				ctx
			)
				local line_delta = (" 󰁂 %d "):format(end_line - start_line)
				local remaining_width = text_width
					- vim.fn.strdisplaywidth(ctx.text)
					- vim.fn.strdisplaywidth(line_delta)
				table.insert(virtual_text_chunks, { line_delta, more_msg_highlight })
				local line = start_line
				while remaining_width > 0 and line < end_line do
					line = line + 1
					local line_text = vim.api.nvim_buf_get_lines(ctx.bufnr, line, line + 1, true)[1]
					line_text = " " .. vim.trim(line_text)
					local line_text_width = vim.fn.strdisplaywidth(line_text)
					if line_text_width <= remaining_width - 2 then
						remaining_width = remaining_width - line_text_width
					else
						line_text = truncate(line_text, remaining_width - 2) .. "…"
						remaining_width = remaining_width - vim.fn.strdisplaywidth(line_text)
					end
					table.insert(virtual_text_chunks, { line_text, non_text_highlight })
				end
				return virtual_text_chunks
			end

			require("ufo").setup({
				fold_virt_text_handler = fold_virt_text_handler,
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
			})
			--
			vim.opt.foldopen:remove({ "search", "hor" })
		end,
		init = function()
			vim.o.foldenable = true
			vim.o.foldlevel = 99
			vim.o.foldcolumn = "1"
			vim.o.foldlevelstart = 99
		end,
		keys = keys,
	},

	{
		"ThePrimeagen/harpoon",
		-- enabled = false,
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim", "kevinhwang91/nvim-ufo" },
		config = function()
			local harpoon = require("harpoon")
			local extensions = require("harpoon.extensions")

			-- REQUIRED
			harpoon:setup({
				settings = {
					save_on_toggle = true,
				},
				global_settings = {
					tabline = false,
					tabline_prefix = "   ",
					tabline_suffix = "   ",
				},
			})
			harpoon:extend(extensions.builtins.command_on_nav("UfoEnableFold"))
		end,

		keys = {
			{
				"<leader>a",
				function()
					vim.notify("File added to Harpoon list")
					require("harpoon"):list():add()
				end,
				desc = "Add file to Harpoon list",
			},
			{
				"<leader>1",
				function()
					require("harpoon"):list():select(1)
				end,
				desc = "Harpoon file 1",
			},
			{
				"<leader>2",
				function()
					require("harpoon"):list():select(2)
				end,
				desc = "Harpoon file 2",
			},
			{
				"<leader>3",
				function()
					require("harpoon"):list():select(3)
				end,
				desc = "Harpoon file 3",
			},
			{
				"<leader>4",
				function()
					require("harpoon"):list():select(4)
				end,
				desc = "Harpoon file 4",
			},
			{
				"<leader>5",
				function()
					require("harpoon"):list():select(5)
				end,
				desc = "Harpoon file 5",
			},
			{
				"<leader>6",
				function()
					require("harpoon"):list():select(6)
				end,
				desc = "Harpoon file 6",
			},
			{
				"<leader>7",
				function()
					require("harpoon"):list():select(7)
				end,
				desc = "Harpoon file 7",
			},
			{
				"<leader>8",
				function()
					require("harpoon"):list():select(8)
				end,
				desc = "Harpoon file 8",
			},
			{
				"<leader>9",
				function()
					require("harpoon"):list():select(9)
				end,
				desc = "Harpoon file 9",
			},
			-- {
			--     "<C-p>",
			--     function()
			--         require("harpoon"):list():prev()
			--     end,
			--     desc = "Harpoon previous file",
			-- },
			-- {
			--     "<C-n>",
			--     function()
			--         require("harpoon"):list():next()
			--     end,
			--     desc = "Harpoon next file",
			-- },
		},
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			enabled = false,
			scope = {
				enabled = true,
				show_start = true,
				show_end = false,
				injected_languages = false,
				priority = 500,
			},
		},

		config = function()
			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowGreen",
				"RainbowViolet",
				"RainbowCyan",
			}
			local hooks = require("ibl.hooks")
			-- create the highlight groups in the highlight setup hook, so they are reset
			-- every time the colorscheme changes
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
			end)

			vim.g.rainbow_delimiters = { highlight = highlight }
			require("ibl").setup({ scope = { highlight = highlight } })

			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		end,
	},

	{ "luk400/vim-jukit" },

	{
		"kdheepak/lazygit.nvim",
		-- event = "VeryLazy",
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
			require("telescope").load_extension("lazygit")
		end,
		init = function()
			vim.g.lazygit_floating_window_use_plenary = 0
			vim.g.lazygit_floating_window_scaling_factor = 0.96
		end,
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lspconfig")
		end,
		-- your lsp config or other stuff
	},

	{
		"jay-babu/mason-nvim-dap.nvim",
		-- event = "VeryLazy",
		depedencies = {
			"mfussenegger/nvim-dap",
			"williamboman/mason.nvim",
		},
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		-- event = "VeryLazy",
		opts = {
			ensure_installed = {
				"debugpy",
				"stylua",
				"clangd",
				"clang-format",
				"codelldb",
				"ast-grep",
				"fixjson",
				"ty",
				{
					"gersemi",
					condition = function()
						return vim.fn.executable("python3") == 1
					end,
				},
				"html-lsp",
				"pyright",
				"yaml-language-server",
				"typescript-language-server",
				"rust-analyzer",
				{
					"gopls",
					condition = function()
						return vim.fn.executable("go") == 1
					end,
				},
				"css-lsp",
				"elixir-ls",
			},
		},
	},

	{
		"nvim-mini/mini.nvim",
		version = false,
		event = "VeryLazy",
		config = function(_, opts)
			vim.keymap.set({ "n", "v" }, "S", "<Nop>", { noremap = true })

			require("mini.surround").setup({
				mappings = {
					add = "Sa", -- Add surrounding in Normal and Visual modes
					delete = "Sd", -- Delete surrounding
					replace = "Sr", -- Replace surrounding

					find = "", -- Find surrounding (to the right)
					find_left = "", -- Find surrounding (to the left)
					highlight = "", -- Highlight surrounding
					suffix_last = "", -- Suffix to search with "prev" method
					suffix_next = "",
				},
			})
		end,
		keys = {
			{ "Sa", desc = "Add surrounding", mode = { "n", "v" } },
			{ "Sd", desc = "Delete surrounding", mode = { "n" } },
			{ "Sr", desc = "Replace surrounding", mode = { "n" } },
		},
	},

	{
		"mg979/vim-visual-multi",
		event = "CursorMoved",
		config = function()
			vim.g.VM_maps["Undo"] = "u"
			vim.g.VM_maps["Redo"] = "<C-r>"
		end,
	},

	{
		"SmiteshP/nvim-navbuddy",
		dependencies = {
			"SmiteshP/nvim-navic",
			"MunifTanjim/nui.nvim",
		},
		config = function(_, opts)
			local actions = require("nvim-navbuddy.actions")
			require("nvim-navbuddy").setup({
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
			})
		end,
		keys = {
			{
				mode = { "n", "v" },
				"<leader>nb",
				function()
					require("nvim-navbuddy").open()
				end,
				desc = "navbuddy toggle",
				noremap = true,
			},
		},
	},

	{
		"NeogitOrg/neogit",
		cmd = "Neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration
			"nvim-telescope/telescope.nvim", -- optional
		},
		-- opts = {
		-- 	-- Hides the hints at the top of the status buffer
		-- 	disable_hint = false,
		-- 	-- Disables changing the buffer highlights based on where the cursor is.
		-- 	disable_context_highlighting = false,
		-- 	-- Disables signs for sections/items/hunks
		-- 	disable_signs = false,
		-- 	-- Offer to force push when branches diverge
		-- 	prompt_force_push = true,
		-- 	-- Changes what mode the Commit Editor starts in. `true` will leave nvim in normal mode, `false` will change nvim to
		-- 	-- insert mode, and `"auto"` will change nvim to insert mode IF the commit message is empty, otherwise leaving it in
		-- 	-- normal mode.
		-- 	disable_insert_on_commit = "auto",
		-- 	-- When enabled, will watch the `.git/` directory for changes and refresh the status buffer in response to filesystem
		-- 	-- events.
		-- 	filewatcher = {
		-- 		interval = 1000,
		-- 		enabled = true,
		-- 	},
		-- 	-- "ascii"   is the graph the git CLI generates
		-- 	-- "unicode" is the graph like https://github.com/rbong/vim-flog
		-- 	-- "kitty"   is the graph like https://github.com/isakbm/gitgraph.nvim - use https://github.com/rbong/flog-symbols if you don't use Kitty
		-- 	graph_style = "unicode",
		-- 	-- Show relative date by default. When set, use `strftime` to display dates
		-- 	commit_date_format = nil,
		-- 	log_date_format = nil,
		-- 	-- Show message with spinning animation when a git command is running.
		-- 	process_spinner = false,
		-- 	-- Used to generate URL's for branch popup action "pull request", "open commit" and "open tree"
		-- 	git_services = {
		-- 		["github.com"] = {
		-- 			pull_request = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
		-- 			commit = "https://github.com/${owner}/${repository}/commit/${oid}",
		-- 			tree = "https://${host}/${owner}/${repository}/tree/${branch_name}",
		-- 		},
		-- 		["bitbucket.org"] = {
		-- 			pull_request = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
		-- 			commit = "https://bitbucket.org/${owner}/${repository}/commits/${oid}",
		-- 			tree = "https://bitbucket.org/${owner}/${repository}/branch/${branch_name}",
		-- 		},
		-- 		["gitlab.com"] = {
		-- 			pull_request = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
		-- 			commit = "https://gitlab.com/${owner}/${repository}/-/commit/${oid}",
		-- 			tree = "https://gitlab.com/${owner}/${repository}/-/tree/${branch_name}?ref_type=heads",
		-- 		},
		-- 		["azure.com"] = {
		-- 			pull_request = "https://dev.azure.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target}",
		-- 			commit = "",
		-- 			tree = "",
		-- 		},
		-- 		["codeberg.org"] = {
		-- 			pull_request = "https://${host}/${owner}/${repository}/compare/${branch_name}",
		-- 			commit = "https://${host}/${owner}/${repository}/commit/${oid}",
		-- 			tree = "https://${host}/${owner}/${repository}/src/branch/${branch_name}",
		-- 		},
		-- 	},
		-- 	-- Persist the values of switches/options within and across sessions
		-- 	remember_settings = true,
		-- 	-- Scope persisted settings on a per-project basis
		-- 	use_per_project_settings = true,
		-- 	-- Table of settings to never persist. Uses format "Filetype--cli-value"
		-- 	ignored_settings = {},
		-- 	-- Configure highlight group features
		-- 	highlight = {
		-- 		italic = true,
		-- 		bold = true,
		-- 		underline = true,
		-- 		line_red = "#5e4245",
		-- 		line_green = "#324740",
		-- 	},
		-- 	-- Set to false if you want to be responsible for creating _ALL_ keymappings
		-- 	use_default_keymaps = true,
		-- 	-- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
		-- 	-- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
		-- 	auto_refresh = true,
		-- 	-- Value used for `--sort` option for `git branch` command
		-- 	-- By default, branches will be sorted by commit date descending
		-- 	-- Flag description: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---sortltkeygt
		-- 	-- Sorting keys: https://git-scm.com/docs/git-for-each-ref#_options
		-- 	sort_branches = "-committerdate",
		-- 	-- Value passed to the `--<commit_order>-order` flag of the `git log` command
		-- 	-- Determines how commits are traversed and displayed in the log / graph:
		-- 	--   "topo"         topological order (parents always before children, good for graphs, slower on large repos)
		-- 	--   "date"         chronological order by commit date
		-- 	--   "author-date"  chronological order by author date
		-- 	--   ""             disable explicit ordering (fastest, recommended for very large repos)
		-- 	commit_order = "topo",
		-- 	-- Default for new branch name prompts
		-- 	initial_branch_name = "",
		-- 	-- Change the default way of opening neogit
		-- 	kind = "tab",
		-- 	-- Floating window style
		-- 	floating = {
		-- 		relative = "editor",
		-- 		width = 0.9,
		-- 		height = 0.8,
		-- 		style = "minimal",
		-- 		border = "rounded",
		-- 	},
		-- 	-- Disable line numbers
		-- 	disable_line_numbers = true,
		-- 	-- Disable relative line numbers
		-- 	disable_relative_line_numbers = true,
		-- 	-- The time after which an output console is shown for slow running commands
		-- 	console_timeout = 2000,
		-- 	-- Automatically show console if a command takes more than console_timeout milliseconds
		-- 	auto_show_console = true,
		-- 	-- Automatically close the console if the process exits with a 0 (success) status
		-- 	auto_close_console = true,
		-- 	notification_icon = "󰊢",
		-- 	status = {
		-- 		show_head_commit_hash = true,
		-- 		recent_commit_count = 10,
		-- 		HEAD_padding = 10,
		-- 		HEAD_folded = false,
		-- 		mode_padding = 3,
		-- 		mode_text = {
		-- 			M = "modified",
		-- 			N = "new file",
		-- 			A = "added",
		-- 			D = "deleted",
		-- 			C = "copied",
		-- 			U = "updated",
		-- 			R = "renamed",
		-- 			DD = "unmerged",
		-- 			AU = "unmerged",
		-- 			UD = "unmerged",
		-- 			UA = "unmerged",
		-- 			DU = "unmerged",
		-- 			AA = "unmerged",
		-- 			UU = "unmerged",
		-- 			["?"] = "",
		-- 		},
		-- 	},
		-- 	commit_editor = {
		-- 		kind = "tab",
		-- 		show_staged_diff = true,
		-- 		staged_diff_split_kind = "split",
		-- 		spell_check = true,
		-- 	},
		-- 	commit_select_view = {
		-- 		kind = "tab",
		-- 	},
		-- 	commit_view = {
		-- 		kind = "vsplit",
		-- 		verify_commit = vim.fn.executable("gpg") == 1, -- Can be set to true or false, otherwise we try to find the binary
		-- 	},
		-- 	log_view = {
		-- 		kind = "tab",
		-- 	},
		-- 	rebase_editor = {
		-- 		kind = "auto",
		-- 	},
		-- 	reflog_view = {
		-- 		kind = "tab",
		-- 	},
		-- 	merge_editor = {
		-- 		kind = "auto",
		-- 	},
		-- 	preview_buffer = {
		-- 		kind = "floating_console",
		-- 	},
		-- 	popup = {
		-- 		kind = "split",
		-- 	},
		-- 	stash = {
		-- 		kind = "tab",
		-- 	},
		-- 	refs_view = {
		-- 		kind = "tab",
		-- 	},
		-- 	signs = {
		-- 		-- { CLOSED, OPENED }
		-- 		hunk = { "", "" },
		-- 		item = { ">", "v" },
		-- 		section = { ">", "v" },
		-- 	},
		-- 	-- Each Integration is auto-detected through plugin presence, however, it can be disabled by setting to `false`
		-- 	integrations = {
		-- 		-- If enabled, use telescope for menu selection rather than vim.ui.select.
		-- 		-- Allows multi-select and some things that vim.ui.select doesn't.
		-- 		telescope = true,
		-- 		-- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `diffview`.
		-- 		-- The diffview integration enables the diff popup.
		-- 		--
		-- 		-- Requires you to have `sindrets/diffview.nvim` installed.
		-- 		diffview = nil,
		--
		-- 		-- If enabled, uses fzf-lua for menu selection. If the telescope integration
		-- 		-- is also selected then telescope is used instead
		-- 		-- Requires you to have `ibhagwan/fzf-lua` installed.
		-- 		fzf_lua = nil,
		--
		-- 		-- If enabled, uses mini.pick for menu selection. If the telescope integration
		-- 		-- is also selected then telescope is used instead
		-- 		-- Requires you to have `echasnovski/mini.pick` installed.
		-- 		mini_pick = nil,
		--
		-- 		-- If enabled, uses snacks.picker for menu selection. If the telescope integration
		-- 		-- is also selected then telescope is used instead
		-- 		-- Requires you to have `folke/snacks.nvim` installed.
		-- 		snacks = nil,
		-- 	},
		-- 	sections = {
		-- 		-- Reverting/Cherry Picking
		-- 		sequencer = {
		-- 			folded = false,
		-- 			hidden = false,
		-- 		},
		-- 		untracked = {
		-- 			folded = false,
		-- 			hidden = false,
		-- 		},
		-- 		unstaged = {
		-- 			folded = false,
		-- 			hidden = false,
		-- 		},
		-- 		staged = {
		-- 			folded = false,
		-- 			hidden = false,
		-- 		},
		-- 		stashes = {
		-- 			folded = true,
		-- 			hidden = false,
		-- 		},
		-- 		unpulled_upstream = {
		-- 			folded = true,
		-- 			hidden = false,
		-- 		},
		-- 		unmerged_upstream = {
		-- 			folded = false,
		-- 			hidden = false,
		-- 		},
		-- 		unpulled_pushRemote = {
		-- 			folded = true,
		-- 			hidden = false,
		-- 		},
		-- 		unmerged_pushRemote = {
		-- 			folded = false,
		-- 			hidden = false,
		-- 		},
		-- 		recent = {
		-- 			folded = true,
		-- 			hidden = false,
		-- 		},
		-- 		rebase = {
		-- 			folded = true,
		-- 			hidden = false,
		-- 		},
		-- 	},
		-- 	mappings = {
		-- 		commit_editor = {
		-- 			["q"] = "Close",
		-- 			["<c-c><c-c>"] = "Submit",
		-- 			["<c-c><c-k>"] = "Abort",
		-- 			["<m-p>"] = "PrevMessage",
		-- 			["<m-n>"] = "NextMessage",
		-- 			["<m-r>"] = "ResetMessage",
		-- 		},
		-- 		commit_editor_I = {
		-- 			["<c-c><c-c>"] = "Submit",
		-- 			["<c-c><c-k>"] = "Abort",
		-- 		},
		-- 		rebase_editor = {
		-- 			["p"] = "Pick",
		-- 			["r"] = "Reword",
		-- 			["e"] = "Edit",
		-- 			["s"] = "Squash",
		-- 			["f"] = "Fixup",
		-- 			["x"] = "Execute",
		-- 			["d"] = "Drop",
		-- 			["b"] = "Break",
		-- 			["q"] = "Close",
		-- 			["<cr>"] = "OpenCommit",
		-- 			["gk"] = "MoveUp",
		-- 			["gj"] = "MoveDown",
		-- 			["<c-c><c-c>"] = "Submit",
		-- 			["<c-c><c-k>"] = "Abort",
		-- 			["[c"] = "OpenOrScrollUp",
		-- 			["]c"] = "OpenOrScrollDown",
		-- 		},
		-- 		rebase_editor_I = {
		-- 			["<c-c><c-c>"] = "Submit",
		-- 			["<c-c><c-k>"] = "Abort",
		-- 		},
		-- 		finder = {
		-- 			["<cr>"] = "Select",
		-- 			["<c-c>"] = "Close",
		-- 			["<esc>"] = "Close",
		-- 			["<c-n>"] = "Next",
		-- 			["<c-p>"] = "Previous",
		-- 			["<down>"] = "Next",
		-- 			["<up>"] = "Previous",
		-- 			["<tab>"] = "InsertCompletion",
		-- 			["<c-y>"] = "CopySelection",
		-- 			["<space>"] = "MultiselectToggleNext",
		-- 			["<s-space>"] = "MultiselectTogglePrevious",
		-- 			["<c-j>"] = "NOP",
		-- 			["<ScrollWheelDown>"] = "ScrollWheelDown",
		-- 			["<ScrollWheelUp>"] = "ScrollWheelUp",
		-- 			["<ScrollWheelLeft>"] = "NOP",
		-- 			["<ScrollWheelRight>"] = "NOP",
		-- 			["<LeftMouse>"] = "MouseClick",
		-- 			["<2-LeftMouse>"] = "NOP",
		-- 		},
		-- 		-- Setting any of these to `false` will disable the mapping.
		-- 		popup = {
		-- 			["?"] = "HelpPopup",
		-- 			["A"] = "CherryPickPopup",
		-- 			["d"] = "DiffPopup",
		-- 			["M"] = "RemotePopup",
		-- 			["P"] = "PushPopup",
		-- 			["X"] = "ResetPopup",
		-- 			["Z"] = "StashPopup",
		-- 			["i"] = "IgnorePopup",
		-- 			["t"] = "TagPopup",
		-- 			["b"] = "BranchPopup",
		-- 			["B"] = "BisectPopup",
		-- 			["w"] = "WorktreePopup",
		-- 			["c"] = "CommitPopup",
		-- 			["f"] = "FetchPopup",
		-- 			["l"] = "LogPopup",
		-- 			["m"] = "MergePopup",
		-- 			["p"] = "PullPopup",
		-- 			["r"] = "RebasePopup",
		-- 			["v"] = "RevertPopup",
		-- 		},
		-- 		status = {
		-- 			["j"] = "MoveDown",
		-- 			["k"] = "MoveUp",
		-- 			["o"] = "OpenTree",
		-- 			["q"] = "Close",
		-- 			["I"] = "InitRepo",
		-- 			["1"] = "Depth1",
		-- 			["2"] = "Depth2",
		-- 			["3"] = "Depth3",
		-- 			["4"] = "Depth4",
		-- 			["Q"] = "Command",
		-- 			["<tab>"] = "Toggle",
		-- 			["za"] = "Toggle",
		-- 			["zo"] = "OpenFold",
		-- 			["x"] = "Discard",
		-- 			["s"] = "Stage",
		-- 			["S"] = "StageUnstaged",
		-- 			["<c-s>"] = "StageAll",
		-- 			["u"] = "Unstage",
		-- 			["K"] = "Untrack",
		-- 			["U"] = "UnstageStaged",
		-- 			["y"] = "ShowRefs",
		-- 			["$"] = "CommandHistory",
		-- 			["Y"] = "YankSelected",
		-- 			["<c-r>"] = "RefreshBuffer",
		-- 			["<cr>"] = "GoToFile",
		-- 			["<s-cr>"] = "PeekFile",
		-- 			["<c-v>"] = "VSplitOpen",
		-- 			["<c-x>"] = "SplitOpen",
		-- 			["<c-t>"] = "TabOpen",
		-- 			["{"] = "GoToPreviousHunkHeader",
		-- 			["}"] = "GoToNextHunkHeader",
		-- 			["[c"] = "OpenOrScrollUp",
		-- 			["]c"] = "OpenOrScrollDown",
		-- 			["<c-k>"] = "PeekUp",
		-- 			["<c-j>"] = "PeekDown",
		-- 			["<c-n>"] = "NextSection",
		-- 			["<c-p>"] = "PreviousSection",
		-- 		},
		-- 	},
		-- },
	},

	{ "nvim-neotest/nvim-nio" },

	{
		"folke/noice.nvim",
		-- enabled = false,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		keys = {
			":",
		},
		opts = {
			routes = {
				{
					filter = { event = "msg_show", kind = { "shell_out", "shell_err" } },
					view = "split",
					opts = {
						level = "info",
						skip = false,
						replace = false,
					},
				},
			},
			cmdline = {
				enable = true,
				format = {

					filter = { pattern = "" },
					lua = {
						icon = "", -- ← no icon (was "tolua")
						name = "lua", -- keep name for filtering (optional)
						pattern = "^lua%s", -- matches ":lua " (case-insensitive by default)
					},
				},
			},
			lsp = {
				signature = {
					enabled = false,
				},
				hover = {
					enabled = false,
				},
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = false,
				},
			},
			presets = {
				lsp_doc_border = true, -- Preserve borders
			},
			views = {
				filter_options = {},
				cmdline_popup = {
					position = {
						row = "50%",
						col = "50%",
					},
					size = {
						width = 100,
						height = "auto",
					},
				},
				popupmenu = {
					relative = "editor",
					position = {
						row = "63%",
						col = "50%",
					},
					size = {
						width = 60,
						height = 10,
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
					},
				},
			},
		},
		init = function(_, opts)
			require("notify").setup({
				fps = 10,
				top_down = false,
				stages = "static",
			})
		end,
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
		"nvim-tree/nvim-tree.lua",
		config = {
			filters = {
				custom = {
					"dotfiles",
					"node_modules",
					"env",
					"tmp",
					"build",
					"dist",
					"vendor",
					"builds",
					"__pycache__",
					"target",
					"bin",
					"obj",
				},
				enable = false,
			},
			filesystem_watchers = {
				enable = false, -- enable = nvim tree leaks when cmake generate script
			},
			diagnostics = {
				enable = false,
				show_on_dirs = false,
			},
			view = {
				side = "right",
				float = {
					enable = true,
					open_win_config = {
						relative = "editor",
						border = "rounded",
						width = 40,
						height = 50,
						row = 1,
						col = vim.o.columns,
					},
				},
			},
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")
				local map = vim.keymap.set

				api.config.mappings.default_on_attach(bufnr)
				map(
					"n",
					"D",
					api.marks.bulk.delete,
					{ desc = "hapus bulk di tree buffer", noremap = true, buffer = bufnr }
				)
			end,
		},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen", "NvimTreeClose" },
		keys = {
			{
				"<leader>z",
				function()
					vim.cmd("NvimTreeClose")
					vim.cmd("CopilotChatToggle")
				end,
				mode = { "n", "v" },
				desc = "copilot chat toggle",
				noremap = true,
			},
			{
				"<leader>q",
				function()
					if vim.bo.filetype == "copilot-chat" then
						vim.cmd("CopilotChatClose")
						return
					end
					if vim.bo.filetype == "NvimTree" then
						require("nvim-tree.api").tree.close()
						return
					end
					require("bufdelete").bufdelete(0, true)
				end,
				desc = "Smart Close Buffer",
			},
		},
	},

	{
		"windwp/nvim-ts-autotag",
		ft = { "tsx", "jsx", "html", "typescriptreact", "javascriptreact" },
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					-- Defaults
					enable_close = true, -- Auto close tags
					enable_rename = true, -- Auto rename pairs of tags
					enable_close_on_slash = true, -- Auto close on trailing </
				},
				-- Also override individual filetype configs, these take priority.
				-- Empty by default, useful if one of the "opts" global settings
				-- doesn't work well in a specific filetype
				per_filetype = {
					["html"] = {
						enable_close = true,
					},
				},
			})
		end,
	},

	{
		"obsidian-nvim/obsidian.nvim",
		-- version = "*", -- recommended, use latest release instead of latest commit
		tag = "v3.14.8",
		ft = "markdown",
		cmd = { "Obsidian" },
		--@module 'obsidian'
		--@type obsidian.config
		opts = {
			legacy_commands = false,
			workspaces = {
				{
					name = "personal",
					path = "~/vaults/personal",
				},
				{
					name = "work",
					path = "~/vaults/work",
				},
			},
			note_id_func = function(title)
				if title ~= nil then
					local suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
					return suffix .. "_" .. tostring(os.time())
				else
					return tostring(os.time())
				end
			end,
			templates = {
				folder = "templates",
				date_format = "%Y-%m-%d-%a",
				time_format = "%H:%M",
				substitutions = {
					titleSubs = function(ctx)
						return string.gsub(ctx.partial_note.title, " ", "-")
					end,
					titleSubsUpper = function(ctx)
						local title = string.gsub(ctx.partial_note.title, "(%w)(%w*)", function(first, rest)
							return string.upper(first) .. rest
						end)
						return title
					end,
					titleSubsLower = function(ctx)
						return string.lower(ctx.partial_note.title)
					end,
				},
			},
		},
		build = function()
			local vaults = "~/vaults"
			local personalPath = "~/vaults/personal"
			local workPath = "~/vaults/work/"

			ensure_dir(vaults)
			ensure_dir(personalPath)
			ensure_dir(workPath)
		end,
		keys = {
			{
				"<leader>o",
				function()
					vim.cmd("Obsidian")
				end,
				mode = { "n" },
				desc = "Open Obsidian Personal Vault",
			},
			{
				"<leader>o",
				function()
					vim.cmd("'<,'>Obsidian")
				end,
				mode = { "v" },
				desc = "Open Obsidian Work Vault",
			},
		},
		config = function(_, opts)
			require("obsidian").setup(opts)
			vim.g.enable_render_markdown = false
		end,
	},

	{
		"TheLeoP/powershell.nvim",
		---@type powershell.user_config
		ft = { "ps1", "psm1", "psd1" },
		opts = {
			bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
		},
	},

	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		cmd = {
			"Refactor",
		},
		-- event = "VeryLazy",
		opts = {
			prompt_func_return_type = {
				go = false,
				java = false,

				cpp = true,
				c = false,
				h = false,
				hpp = false,
				cxx = false,
			},
			prompt_func_param_type = {
				go = false,
				java = false,

				cpp = true,
				c = false,
				h = false,
				hpp = false,
				cxx = false,
			},
			printf_statements = {},
			print_var_statements = {},
			show_success_message = false,
		},
		config = function(_, opts)
			require("refactoring").setup(opts)
		end,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
		---@module 'render-markdown'
		opts = {
			link = {
				wiki = {
					icon = " ",
					body = function()
						return nil
					end,
					highlight = "RenderMarkdownWikiLink",
					scope_highlight = nil,
				},
			},
		},
		cmd = { "DevdocsOpen", "DevdocsOpenCurrent", "DevdocsKeywordprgs" },
		ft = "markdown",
		-- event = "VeryLazy",
	},

	{
		"sphamba/smear-cursor.nvim",
		event = "CursorMoved",
		opts = {
			stiffness = 0.8,
			trailing_stiffness_insert_mode = 0.7,
			distance_stop_animating = 0.5,
		},
	},

	{
		"folke/snacks.nvim",
		-- enable = false,
		priority = 1000,
		depedencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		lazy = false,
		---@type snacks.Config
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = false },
			-- dashboard = { enabled = true },
			explorer = { enabled = false },
			indent = { enabled = true, animate = { enabled = false } },
			input = { enabled = false },
			picker = { enabled = true },
			notifier = { enabled = false },
			quickfile = { enabled = false },
			scope = { enabled = false },
			scroll = { enabled = false },
			statuscolumn = { enabled = false },
			words = { enabled = false },
		},
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			mode = "cursor",
		},
		init = function()
			vim.cmd("hi TreesitterContextBottom gui=underline guisp=Grey")
		end,
	},

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
			require("telescope").load_extension("hierarchy")
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		-- event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		cmd = { "Telescope" },
		keys = {
			{
				"<leader>fx",
				function()
					vim.cmd("Telescope lsp_workspace_symbols")
				end,
				desc = "Find symbols in workspace",
				mode = "n",
			},
			{
				"<leader>fs",
				function()
					vim.cmd("Telescope lsp_document_symbols")
				end,
				desc = "Find document symbols",
				mode = "n",
			},
			{
				"<leader>fr",
				function()
					vim.cmd("Telescope lsp_references")
				end,
				desc = "Find document references",
				mode = "n",
			},
			{
				"<leader>fi",
				"<Cmd>Telescope hierarchy incoming_calls<Cr>",
				desc = "Hierarchy incoming_calls",
				mode = "n",
			},
			{
				"<leader>fo",
				"<Cmd>Telescope hierarchy outgoing_calls<Cr>",
				desc = "Hierarchy outgoing calls",
				mode = "n",
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"neovim/nvim-lspconfig",
			"lukas-reineke/indent-blankline.nvim",
			"nvim-treesitter/nvim-treesitter-context",
			"kevinhwang91/nvim-ufo",
		},
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
				local file_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/queries/cpp/highlights.scm"
				local lines = {}
				for line in io.lines(file_path) do
					if line:match("%(namespace_identifier%) %@module") then
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

	{
		"KaitoMuraoka/websearcher.nvim",
	},

	{
		"folke/which-key.nvim",
		opts = {
			show_help = true,
		},
		lazy = false,
	},
}
