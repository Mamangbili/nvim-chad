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

  -- conflict with session
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

  -- Function to fold exact level
  local function fold_exact_level_close(level)
    local last = vim.api.nvim_buf_line_count(0)
    local lnum = 1
    while lnum <= last do
      local flevel = vim.fn.foldlevel(lnum)
      local fclosed = vim.fn.foldclosed(lnum)

      -- only fold if level matches and it's open
      if flevel == level and fclosed == -1 then
        vim.cmd(lnum .. "foldclose")
        -- skip lines inside this fold
        local fold_end = vim.fn.foldclosedend(lnum)
        if fold_end > 0 then
          lnum = fold_end + 1
        else
          lnum = lnum + 1
        end
      else
        lnum = lnum + 1
      end
    end
  end

  -- Function to open exact level
  local function fold_exact_level_open(level)
    local last = vim.api.nvim_buf_line_count(0)
    local lnum = 1
    while lnum <= last do
      local flevel = vim.fn.foldlevel(lnum)
      local fclosed = vim.fn.foldclosed(lnum)

      if flevel == level then
        vim.cmd(lnum .. "foldopen")
        -- safely skip folded region if it's closed
        if fclosed ~= -1 then
          lnum = vim.fn.foldclosedend(lnum) + 1
        else
          lnum = lnum + 1
        end
      else
        lnum = lnum + 1
      end
    end
  end

  local function fold_level_in_root(level)
    local cursor = vim.fn.line "."
    local buf_last = vim.api.nvim_buf_line_count(0)

    -- Find root fold start
    local root_start = cursor
    while root_start > 1 and vim.fn.foldlevel(root_start) > 1 do
      root_start = root_start - 1
    end

    -- Find root fold end
    local root_end = root_start
    while root_end <= buf_last and vim.fn.foldlevel(root_end) >= 1 do
      root_end = root_end + 1
    end
    root_end = root_end - 1

    -- Save view to restore cursor/window position
    local view = vim.fn.winsaveview()

    -- Open entire root fold to make all children visible
    vim.cmd(root_start .. "," .. root_end .. "foldopen!")

    -- Go to start of root fold
    vim.api.nvim_win_set_cursor(0, { root_start, 0 })

    -- Temporarily fold level recursively inside root
    for l = 1, level - 1 do
      -- Fold all higher levels first to expose exact-level folds
      vim.cmd(root_start .. "," .. root_end .. "foldopen!")
    end

    -- Fold all folds at the exact target level
    for lnum = root_start, root_end do
      if vim.fn.foldlevel(lnum) == level and vim.fn.foldclosed(lnum) == -1 then
        vim.cmd(lnum .. "foldclose")
      end
    end

    -- Restore view
    vim.fn.winrestview(view)
  end

  -- Open all folds of a specific level inside the root-level fold under cursor
  local function open_level_in_root(level)
    local cursor = vim.fn.line "."
    local buf_last = vim.api.nvim_buf_line_count(0)

    -- Find root fold start
    local root_start = cursor
    while root_start > 1 and vim.fn.foldlevel(root_start) > 1 do
      root_start = root_start - 1
    end

    -- Find root fold end
    local root_end = root_start
    while root_end <= buf_last and vim.fn.foldlevel(root_end) >= 1 do
      root_end = root_end + 1
    end
    root_end = root_end - 1

    -- Ensure root fold is open so children are visible
    vim.cmd(root_start .. "," .. root_end .. "foldopen!")

    -- Helper: check if a line is the start of a fold
    local function is_fold_start(lnum)
      local curr = vim.fn.foldlevel(lnum)
      local prev = (lnum == 1) and 0 or vim.fn.foldlevel(lnum - 1)
      return curr > prev
    end

    -- Open all folds at the target level inside root
    for lnum = root_start, root_end do
      if vim.fn.foldlevel(lnum) == level and vim.fn.foldclosed(lnum) ~= -1 and is_fold_start(lnum) then
        vim.cmd(lnum .. "foldopen")
      end
    end
  end

  -- Keymaps for levels 1–9
  for level = 1, 9 do
    vim.keymap.set("n", "z" .. level .. "c", function()
      fold_exact_level_close(level)
    end, { noremap = true, silent = true })

    vim.keymap.set("n", "z" .. level .. "o", function()
      fold_exact_level_open(level)
    end, { noremap = true, silent = true })

    vim.keymap.set("n", "z" .. level .. level .. "c", function()
      fold_level_in_root(level)
    end, {
      noremap = true,
      silent = true,
      desc = "fold all level " .. level .. " on next lines but still within scope ",
    })

    vim.keymap.set("n", "z" .. level .. level .. "o", function()
      open_level_in_root(level)
    end, { noremap = true, silent = true })
  end
end
