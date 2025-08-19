require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local unmap = vim.keymap.del

function Close_window()
  vim.cmd "q!"
end

function Close_buffer()
  vim.cmd "bnext | bd! #"
end

vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

unmap("n", "<leader>th")
unmap("n", "<TAB>")
unmap("n", "<leader>fh")
unmap("n", "<leader>fo")

map("n", "<C-i>", "<C-i>")

map("n", "<leader>y", ":setf cpp<Cr>", { desc = "setfile to cpp", noremap = true })

local telescope = require "telescope.builtin"
map("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "Find document symbols", noremap = true })
map("n", "<leader>fr", telescope.lsp_references, { desc = "Find document symbols", noremap = true })
map(
  "n",
  "<leader>fi",
  "<Cmd>Telescope hierarchy incoming_calls<Cr>",
  { desc = "Hierarchy incoming_calls", noremap = true }
)
map(
  "n",
  "<leader>fo",
  "<Cmd>Telescope hierarchy outgoing_calls<Cr>",
  { desc = "Hierarchy outgoin calls", noremap = true }
)
-- e,l untuk expand. c,h untuk fold tree hierarchy. t untuk toggle buka tutup
-- d untuk defini current node hierarchy

map("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

map("i", "jk", "<ESC>l")

map("n", "<leader>q", function()
  Close_buffer()
end, { desc = "close window" })

map("n", "<leader>ww", function()
  Close_window()
end, { desc = "close window" })

-- split window
map("n", "<leader>h", function()
  vim.cmd "sp"
end, { desc = "new horizontal window" })

map("n", "<leader>v", function()
  vim.cmd "vsp"
end, { desc = "new vertical window" })

map("n", "<S-l>", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "<S-h>", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto next" })

-- terminal mode
map("t", "<ESC>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
map({ "n", "i" }, "<A-t>", "<cmd>terminal<CR>", { desc = "enter terminal mode" })

-- toggleable
map({ "n", "t" }, "<A-\\>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
  -- require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "terminal toggleable vertical term" })

map({ "n", "t" }, "<A-/>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
  -- require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "terminal toggleable horizontal term" })

map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "terminal toggle floating term" })

map("n", "gf", vim.lsp.buf.code_action, { desc = "quick fix" })

-- redo
map("n", "U", function()
  vim.cmd "redo"
end, { desc = "redo" })

-- resize window
map({ "n", "i", "x" }, "<C-Up>", ":resize +5<CR>", { desc = "increase height", noremap = true })
map({ "n", "i", "x" }, "<C-Down>", ":resize -5<CR>", { desc = "decrease height", noremap = true })
map({ "n", "i", "x" }, "<C-Left>", ":vertical resize -5<CR>", { desc = "decrease width", noremap = true })
map({ "n", "i", "x" }, "<C-Right>", ":vertical resize +5<CR>", { desc = "increase width", noremap = true })

-- map("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", {desc = "Toggle Nvim Tree", noremap=true})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp", "c", "h", "hpp", "cc" },
  callback = function()
    map("n", "gf", vim.lsp.buf.code_action, { desc = "quick fix" })
    vim.keymap.set("n", "<leader>l", ":echo 'awe'<CR>", { buffer = true })
  end,
})

-- inlay hint
-- shift + k
