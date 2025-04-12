require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

function Close_window()
    vim.cmd("bd")
end

map("i", "jk", "<ESC>")

map("n", "<leader>q", function()
   Close_window()
end, {desc = "close window"})

-- split window
map("n", "<leader>h", function()
  vim.cmd('sp')
end, { desc = "new horizontal window" })

map("n", "<leader>v", function()
  vim.cmd('vsp')
end, { desc = "new vertical window" })

map("n", "<S-l>", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "<S-h>", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto next" })

-- terminal mode
map("t", "jk", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
map("t", "<ESC>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
map({"n","i"}, "<A-e>", "<cmd>terminal<CR>", { desc = "enter terminal mode" })

-- toggleable
map({ "n", "t" }, "<A-\\>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "terminal toggleable vertical term" })

map({ "n", "t" }, "<A-/>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "terminal toggleable horizontal term" })

map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "terminal toggle floating term" })



-- resize window
map("n","{", "<cmd>vertical resize+5<cr>", {desc = "increase window size"})
map("n","}", "<cmd>vertical resize-5<cr>", {desc = "decrease window size"})

-- map("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", {desc = "Toggle Nvim Tree", noremap=true})

