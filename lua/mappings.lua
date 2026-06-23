require("nvchad.mappings")
local u = require("utils")

-- add yours here
-- telescope outgoing calls expand <l>, fold <h>

local remap = vim.keymap.set
local unmap = vim.keymap.del
local autocmd = vim.api.nvim_create_autocmd

remap("n", "<leader>9", "<cmd>Lazy<Cr>")

vim.opt.timeoutlen = 10000
remap("v", "r", "<nop>")
remap("i", "<C-i>", function()
	require("cmp").complete()
end, { noremap = true, silent = true, expr = true, desc = "show autocompletion" })

remap("i", "<C-i>", "cpm#complete()", { desc = "show autocompletion" })

remap("n", "<leader>ng", "<cmd>Neogit<cr>", { desc = "neogit", noremap = true })

remap("n", "<leader>dq", "<cmd>DiffviewClose<cr>", { desc = "close diff", noremap = true })

-- glance reference
-- remap("n", "<leader>fr", "<cmd>Glance references<cr>", { desc = "glance references", noremap = true })
remap("n", "<leader>fd", "<cmd>Glance definitions<cr>", { desc = "glance definitions", noremap = true })

vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-K>", "copilot#Accept('<CR>')", { silent = true, expr = true }) -- DON"T USE REMAP"

vim.defer_fn(function()
	unmap("n", "<leader>n")
end, 1000)
unmap("n", "<leader>th")
unmap("n", "<leader>fo")

remap("n", "<leader>fo", "<Cmd>Telescope hierarchy outgoing_calls<Cr>", { desc = "outgoing call ", noremap = true })
remap("n", "<leader>ft", "<Cmd>Telescope treesitter<Cr>", { desc = "outgoing call ", noremap = true })

remap("n", "t", function()
	require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end, { desc = "Harpoon Menu", noremap = true })

remap("i", "<C-h>", "<C-w>")
remap("t", "<F9>", require("nvchad.tabufline").close_buffer, { desc = "terminal toggle floating term" })

remap("n", "<leader>y", ":setf cpp<Cr>", { desc = "setfile to cpp", noremap = true })

-- e,l untuk expand. c,h untuk fold tree hierarchy. t untuk toggle buka tutup
-- d untuk defini current node hierarchy

remap("n", "<leader>t", function()
	vim.cmd("CopilotChatClose")
	vim.cmd("NvimTreeToggle")
end, { desc = "nvimtree toggle window" })

remap("i", "jk", "<Esc>`^")
remap("n", "O", "O<Space><BS>")
remap("n", "o", "o<Space><BS>")
-- remap("n", "<leader>q", function()
-- 	u.Close_buffer()
-- end, { desc = "close buffer/diff" })

remap("n", "<leader>ww", function()
	u.Close_window()
end, { desc = "close window" })

-- split window
remap("n", "<leader>h", u.telescope_hsplit, { desc = "new horizontal window" })
remap("n", "<leader>v", u.telescope_vsplit, { desc = "new vertical window" })

-- terminal mode
remap("t", "<leader><Esc>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
remap({ "n", "i" }, "<A-t>", "<cmd>terminal<CR>", { desc = "enter terminal mode" })

remap({ "n", "t" }, "<A-/>", function()
	require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "terminal toggleable horizontal term" })

remap({ "n", "t" }, "<A-i>", function()
	require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "terminal toggle floating term" })

local function open_definition_on_new_window()
	local cursor_row, cursor_column = unpack(vim.api.nvim_win_get_cursor(0))
	vim.cmd("vsplit")
	vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_column })
	vim.lsp.buf.definition()
end

remap("n", "gvd", open_definition_on_new_window, { desc = "open defintion on new window" })
remap("n", "gi", vim.lsp.buf.implementation, { desc = "lsp implementation" })
remap("n", "gd", vim.lsp.buf.definition, { desc = "lsp definition" })
remap("n", "gD", vim.lsp.buf.declaration, { desc = "lsp declaration" })
remap("n", "<leader>ra", vim.lsp.buf.rename, { desc = "lsp rename" })

-- redo
remap("n", "U", function()
	vim.cmd("redo")
end, { desc = "redo" })
-- map for indenting in visual mode

-- resize window
remap({ "n", "i", "x" }, "<C-Up>", ":resize +5<CR>", { desc = "increase height", noremap = true, silent = true })
remap({ "n", "i", "x" }, "<C-Down>", ":resize -5<CR>", { desc = "decrease height", noremap = true, silent = true })
remap(
	{ "n", "i", "x" },
	"<C-Left>",
	":vertical resize -5<CR>",
	{ desc = "decrease width", noremap = true, silent = true }
)
remap(
	{ "n", "i", "x" },
	"<C-Right>",
	":vertical resize +5<CR>",
	{ desc = "increase width", noremap = true, silent = true }
)

-- remap({ "n", "v" }, "<leader>nb", function()
--     require("nvim-navbuddy").open()
-- end, { desc = "navboddy toggle", noremap = true })

-- inlay hint
-- shift + k

-- remove q: to disable command-line window
-- remap("n", "q:", "<nop>", { desc = "Disable command-line window", noremap = true })
-- remap("n", "q/", "<Nop>", { desc = "Disable command-line window", noremap = true })

-- Start listening
vim.on_key(u.on_key)

remap({ "n", "v", "t" }, "<C-u>", "10<C-y>", { desc = "scroll up", noremap = true })
remap({ "n", "v", "t" }, "<C-d>", "10<C-e>", { desc = "scroll down", noremap = true })

-- remap("t", "<C-i>", u.toggle_betwee, { desc = "toggle terminal mode", noremap = true })
remap("v", "rb", ":s/", { desc = "substitute in block", noremap = true })
remap("n", "<leader>rr", ":.,$s/", { desc = "substitute until end", noremap = true })
remap("n", "<leader>wb", ":BDeleteOthers<CR>", { desc = "delete all buffer except current" })

-- unmap("n", "<Tab>")

remap("n", "zO", function()
	vim.cmd("normal! zC")
	vim.cmd("normal! zO")
end)

remap({ "n", "v", "x" }, "<leader>rf", function()
	vim.lsp.buf.code_action({})
end, {
	noremap = true,
	desc = "code action",
})

autocmd("FileType", {
	pattern = "cpp",
	callback = function(ev)
		remap("x", "<leader>rm", u.cpp_move_to_file, { desc = "Cpp move to files", buffer = ev.buf, noremap = true })
	end,
})

remap("n", "<S-h>", ":BufPrevCycle<CR>", { noremap = true, silent = true })
remap("n", "<S-l>", ":BufNextCycle<CR>", { noremap = true, silent = true })
remap("n", "<C-o>", ":BufJumpPrev<CR>", { noremap = true, silent = true })

-- Copy absolute path to clipboard
vim.keymap.set("n", "<leader>cp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path)
end, { desc = "Copy current buffer path" })
