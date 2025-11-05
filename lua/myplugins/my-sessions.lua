local M = {}

local autocmd = vim.api.nvim_create_autocmd
local Path = vim.fn.stdpath "data" .. "/sessions/"
local cwd = vim.fn.getcwd()
local safe_cwd = string.gsub(cwd, "[\\:/]", "_") .. ".vim"

local function save_session()
  if vim.fn.isdirectory(Path) == 0 then
    vim.fn.mkdir(Path, "p")
  end

  vim.cmd("mksession! " .. Path .. safe_cwd)
end

local function load_session()
  local api = require "nvim-tree.api"

  if vim.fn.filereadable(Path .. safe_cwd .. "") == 1 then
    vim.cmd("source " .. Path .. safe_cwd)
  end

  if not api.tree.is_visible() then
    api.tree.open()
  end
end

function M:setup()
  autocmd({ "BufWinLeave", "VimLeave" }, {
    desc = "create sessions folder if not exists",
    once = true,
    callback = function()
      save_session()
    end,
  })

  local timer = vim.uv.new_timer()
  if not timer then
    print "Error creating timer for session saving"
    return
  end

  timer:start(
    1000,
    0,
    vim.schedule_wrap(function()
      save_session()
    end)
  )

  autocmd({ "VimEnter" }, {
    desc = "load session if exists",
    callback = function()
      load_session()
    end,
  })
end

return M
