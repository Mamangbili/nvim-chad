require "nvchad.mappings"
local u = require "utils"
local tree = require("nvim-tree.api").tree

-- add yours here
-- telescope outgoing calls expand <l>, fold <h>

local remap = vim.keymap.set
local unmap = vim.keymap.del

vim.opt.timeoutlen = 10000
remap("v", "r", "<nop>")
remap("i", "<C-i>", function()
    require("cmp").complete()
end, { noremap = true, silent = true, expr = true, desc = "show autocompletion" })

remap("i", "<C-i>", "cpm#complete()", { desc = "show autocompletion" })

remap({ "n", "v" }, "<leader>z", function()
    tree.close()
    vim.cmd "CopilotChatToggle"
end, { desc = "copilot chat toggle", noremap = true })

remap("n", "<leader>ng", "<cmd>Neogit<cr>", { desc = "neogit", noremap = true })

remap("n", "<leader>dq", "<cmd>DiffviewClose<cr>", { desc = "close diff", noremap = true })

-- glance reference
remap("n", "<leader>fr", "<cmd>Glance references<cr>", { desc = "glance references", noremap = true })
remap("n", "<leader>fd", "<cmd>Glance definitions<cr>", { desc = "glance definitions", noremap = true })

vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-K>", "copilot#Accept('<CR>')", { silent = true, expr = true }) -- DON"T USE REMAP"

unmap("n", "<leader>e")
unmap("n", "<leader>b")
unmap("n", "<leader>th")
unmap("n", "<TAB>")
unmap("n", "<leader>fo")

remap("t", "<F9>", require("nvchad.tabufline").close_buffer, { desc = "terminal toggle floating term" })

local harpoon = require "harpoon"
remap("n", "<leader>e", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon quick menu", noremap = true })

remap("n", "<leader>y", ":setf cpp<Cr>", { desc = "setfile to cpp", noremap = true })

local telescope = require "telescope.builtin"
remap("n", "<leader>fx", telescope.lsp_workspace_symbols, { desc = "Find symbols in workspace", noremap = true })
remap("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "Find document symbols", noremap = true })
-- map("n", "<leader>fr", telescope.lsp_references, { desc = "Find document symbols", noremap = true })
remap(
    "n",
    "<leader>fi",
    "<Cmd>Telescope hierarchy incoming_calls<Cr>",
    { desc = "Hierarchy incoming_calls", noremap = true }
)
remap(
    "n",
    "<leader>fo",
    "<Cmd>Telescope hierarchy outgoing_calls<Cr>",
    { desc = "Hierarchy outgoin calls", noremap = true }
)
-- e,l untuk expand. c,h untuk fold tree hierarchy. t untuk toggle buka tutup
-- d untuk defini current node hierarchy

remap("n", "<leader>t", function()
    vim.cmd "CopilotChatClose"
    vim.cmd "NvimTreeToggle"
end, { desc = "nvimtree toggle window" })

remap("i", "jk", "<ESC>")

remap("n", "<leader>q", function()
    u.Close_buffer()
end, { desc = "close buffer/diff" })

remap("n", "<leader>ww", function()
    u.Close_window()
end, { desc = "close window" })

-- split window
remap("n", "<leader>h", function()
    require("telescope.builtin").find_files {
        attach_mappings = function(prompt_bufnr)
            local actions = require "telescope.actions"
            actions.select_default:replace(function()
                actions.file_split(prompt_bufnr)
            end)
            return true
        end,
    }
end, { desc = "new horizontal window" })

remap("n", "<leader>v", function()
    require("telescope.builtin").find_files {
        attach_mappings = function(prompt_bufnr)
            local actions = require "telescope.actions"
            actions.select_default:replace(function()
                actions.file_vsplit(prompt_bufnr)
            end)
            return true
        end,
    }
end, { desc = "new vertical window" })

remap("n", "<S-l>", function()
    require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

remap("n", "<S-h>", function()
    require("nvchad.tabufline").prev()
end, { desc = "buffer goto next" })

-- terminal mode
remap("t", "<leader><Esc>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
remap({ "n", "i" }, "<A-t>", "<cmd>terminal<CR>", { desc = "enter terminal mode" })

remap({ "n", "t" }, "<A-/>", function()
    require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
    -- require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "terminal toggleable horizontal term" })

remap({ "n", "t" }, "<A-i>", function()
    require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "terminal toggle floating term" })

remap("n", "gf", vim.lsp.buf.code_action, { desc = "quick fix" })
remap("n", "gi", vim.lsp.buf.implementation, { desc = "lsp implementation" })

-- redo
remap("n", "U", function()
    vim.cmd "redo"
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

-- aerial
remap({ "n", "v" }, "<leader>nb", require("nvim-navbuddy").open, { desc = "navboddy toggle", noremap = true })

-- inlay hint
-- shift + k

-- remove q: to disable command-line window
remap("n", "q:", "<nop>", { desc = "Disable command-line window", noremap = true })
remap("n", "q/", "<Nop>", { desc = "Disable command-line window", noremap = true })

-- Start listening
vim.on_key(u.on_key)

remap({ "n", "v", "t" }, "<C-u>", "10<C-y>", { desc = "undotree toggle", noremap = true })
remap({ "n", "v", "t" }, "<C-d>", "10<C-e>", { desc = "undotree toggle", noremap = true })

remap({ "t", "n" }, "<C-i>", u.toggle_betwee, { desc = "toggle terminal mode", noremap = true })
remap("v", "rb", ":s/", { desc = "substitute in block", noremap = true })
remap("n", "<leader>rr", ":.,$s/", { desc = "substitute until end", noremap = true })
