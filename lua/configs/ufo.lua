return function(_, opts)
  vim.o.foldcolumn = "1" -- '0' is not bad
  vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true

  -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
  vim.keymap.set("n", "zR", require("ufo").openAllFolds)
  vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

  require("ufo").setup(opts)

  -- Save folds on exit (only for real files)
  vim.api.nvim_create_autocmd("BufWinLeave", {
    pattern = "*",
    desc = "Save folds on exit",
    callback = function()
      if vim.fn.expand "%" ~= "" then
        vim.cmd "mkview"
      end
    end,
  })

  -- Load folds on entry (only for real files)
  vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    desc = "Load folds on entry",
    callback = function()
      if vim.fn.expand "%" ~= "" then
        vim.cmd "silent! loadview"
      end
    end,
  })
  vim.opt.foldopen:remove { "search", "hor" }
end
