vim.cmd [[
  cabbrev <expr> h ((getcmdtype() == ':' && getcmdline() ==# 'h') ? 'vert help' : 'h')
]]
vim.loader.enable()
vim.o.shada = "!,'100,<50,s10,h"

-- if windows
if vim.loop.os_uname().sysname == "Windows_NT" then
    vim.g._jukit_python_os_cmd = "python"
    vim.opt.shell = "powershell.exe"
    vim.opt.shellcmdflag = "-ExecutionPolicy RemoteSigned -Command"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
    vim.g.python3_host_prog = "C:\\python313\\python3.exe"
    vim.cmd "language en_US.UTF-8"
    vim.opt.langmenu = "en_US.UTF-8"
    vim.g.lang = "en_US.UTF-8"
else
    vim.g._jukit_python_os_cmd = "/usr/bin/python3"
    vim.o.termguicolors = true
end

vim.opt.conceallevel = 1
vim.o.cmdheight = 0
vim.o.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true

vim.o.tabstop = 4
vim.bo.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.bo.shiftwidth = 4

vim.opt.guicursor =
    "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
vim.o.sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,terminal,localoptions"

vim.o.sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,terminal,localoptions"
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.o.relativenumber = true
vim.o.scrolloff = 17

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    local repo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)
vim.opt.rtp:append(vim.fn.stdpath "config" .. "/lua")

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

vim.filetype.add {
    filename = {
        ["CMakelists.txt"] = "cmake",
        ["CMakeLists.txt"] = "cmake",
    },
}

require("autocmd").setup()
