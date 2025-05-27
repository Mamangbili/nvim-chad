vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.o.shell = "powershell"
vim.o.relativenumber = true
vim.o.clipboard = ""

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

local start = os.time()
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
  pattern = "*",
  callback = function(args)
    local deltaTime = os.time() - start
    deltaTime = deltaTime

    local sec = 10
    print(deltaTime)
    if deltaTime > sec then
      vim.cmd "silent! write"
      print("💾 Auto-saved at " .. os.date "%H:%M:%S")
      start = os.time()
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*",
  callback = function(args)
    require("conform").format { async = true, bufnr = args.buf }
  end,
})

local afk_timeout = 60 -- seconds
local last_input_time = os.time()

-- Track any keypress
vim.on_key(function()
  last_input_time = os.time()
end)

-- Check every 5 seconds for AFK
vim.fn.timer_start(5000, function()
  if os.time() - last_input_time >= afk_timeout then
    -- Put your AFK action here
    print "AFK detected: no input for 30 seconds"
    vim.cmd "silent! write"
    print("💾 Auto-saved at " .. os.date "%H:%M:%S")
    -- Optionally reset last_input_time to avoid repeated triggers
    last_input_time = os.time()
  end
end, { ["repeat"] = -1 })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    vim.bo.commentstring = "// %s"
  end,
})
-----------------------
