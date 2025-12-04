require "nvchad.mappings"
local tree = require("nvim-tree.api").tree

-- add yours here
-- telescope outgoing calls expand <l>, fold <h>

local map = vim.keymap.set
local unmap = vim.keymap.del

function Close_window()
    vim.cmd "q!"
end

function Close_buffer()
    if vim.bo.filetype == "copilot-chat" then
        vim.cmd "CopilotChatClose"
        return
    end
    if vim.bo.filetype == "NvimTree" then
        tree.close()
        return
    end
    require("bufdelete").bufdelete(0, true)
end

vim.keymap.set("i", "<C-Space>", function()
    require("cmp").complete()
end, { noremap = true, silent = true, expr = true, desc = "show autocompletion" })

map("i", "<C-i>", "cpm#complete()", { desc = "show autocompletion" })

map({ "n", "v" }, "<leader>z", function()
    tree.close()
    vim.cmd "CopilotChatToggle"
end, { desc = "copilot chat toggle", noremap = true })

map("n", "<leader>ng", "<cmd>Neogit<cr>", { desc = "neogit", noremap = true })

map("n", "<leader>dq", "<cmd>DiffviewClose<cr>", { desc = "close diff", noremap = true })

map("n", "<C-y>", "<C-r>", { noremap = true, silent = true })

-- glance reference
map("n", "<leader>fr", "<cmd>Glance references<cr>", { desc = "glance references", noremap = true })
map("n", "<leader>fd", "<cmd>Glance definitions<cr>", { desc = "glance definitions", noremap = true })

vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

unmap("n", "<leader>th")
unmap("n", "<TAB>")
unmap("n", "<leader>fh")
unmap("n", "<leader>fo")

map("n", "<C-i>", "<C-i>")

map("n", "<leader>y", ":setf cpp<Cr>", { desc = "setfile to cpp", noremap = true })

local telescope = require "telescope.builtin"
map("n", "<leader>fx", telescope.lsp_workspace_symbols, { desc = "Find symbols in workspace", noremap = true })
map("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "Find document symbols", noremap = true })
-- map("n", "<leader>fr", telescope.lsp_references, { desc = "Find document symbols", noremap = true })
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

map("n", "<leader>t", function()
    vim.cmd "CopilotChatClose"
    vim.cmd "NvimTreeToggle>"
end, { desc = "nvimtree toggle window" })

map("i", "jk", "<ESC>")

map("n", "<leader>q", function()
    Close_buffer()
end, { desc = "close buffer/diff" })

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
map("t", "<leader><Esc>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
map({ "n", "i" }, "<A-t>", "<cmd>terminal<CR>", { desc = "enter terminal mode" })

-- toggleable
-- map({ "n", "t" }, "<A-\\>", function()
--   require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
--   -- require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
--   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
-- end, { desc = "terminal toggleable vertical term" })

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
map("n", "gi", vim.lsp.buf.implementation, { desc = "lsp implementation" })

-- redo
map("n", "U", function()
    vim.cmd "redo"
end, { desc = "redo" })

-- map for indenting in visual mode

-- resize window
map({ "n", "i", "x" }, "<C-Up>", ":resize +5<CR>", { desc = "increase height", noremap = true, silent = true })
map({ "n", "i", "x" }, "<C-Down>", ":resize -5<CR>", { desc = "decrease height", noremap = true, silent = true })
map(
    { "n", "i", "x" },
    "<C-Left>",
    ":vertical resize -5<CR>",
    { desc = "decrease width", noremap = true, silent = true }
)
map(
    { "n", "i", "x" },
    "<C-Right>",
    ":vertical resize +5<CR>",
    { desc = "increase width", noremap = true, silent = true }
)

-- map("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", {desc = "Toggle Nvim Tree", noremap=true})

-- aerial
map({ "n", "v" }, "<leader>nb", require("nvim-navbuddy").open, { desc = "aerial toggle", noremap = true })

-- inlay hint
-- shift + k
