vim.cmd [[
  cabbrev <expr> h ((getcmdtype() == ':' && getcmdline() ==# 'h') ? 'vert help' : 'h')
]]

if vim.g.vscode then
  -- Set leader key
  print "✅ VSCode detected!"
  vim.g.mapleader = " "

  local vscode = require "vscode"

  -- INSERT MODE
  vim.keymap.set("i", "jk", "<Esc><Right>", { noremap = true, silent = true })

  -- NORMAL MODE
  vim.keymap.set("i", "<C-k>", function()
    vscode.call "editor.action.accessibleViewAcceptInlineCompletion"
  end, { silent = true })
  vim.keymap.set("n", "<C-k>", function()
    vscode.call "editor.action.accessibleViewAcceptInlineCompletion"
  end, { silent = true })
  vim.keymap.set("n", "<S-l>", function()
    vscode.call "workbench.action.nextEditor"
  end, { silent = true })
  vim.keymap.set("n", "<S-h>", function()
    vscode.call "workbench.action.previousEditor"
  end, { silent = true })
  vim.keymap.set("n", "<C-j>", function()
    vscode.call "editor.action.showDefinitionPreviewHover"
  end, { silent = true })
  vim.keymap.set("n", "<C-y>", function()
    vscode.call "undo"
  end, { silent = true })
  vim.keymap.set("n", "<A-q>", function()
    vscode.call "workbench.action.closeActiveEditor"
  end, { silent = true })
  vim.keymap.set("n", "<leader><leader>q", function()
    vscode.call "workbench.action.closeEditorsInGroup"
  end, { silent = true })
  vim.keymap.set("n", "tc", function()
    vscode.call "workbench.files.action.collapseExplorerFolders"
  end, { silent = true })
  vim.keymap.set("n", "gh", function()
    vscode.call "editor.action.triggerParameterHints"
  end, { silent = true })
  vim.keymap.set("n", "s", function()
    vscode.call "leap.findForward"
  end, { silent = true })
  vim.keymap.set("n", "S", function()
    vscode.call "leap.findBackward"
  end, { silent = true })
  vim.keymap.set("n", "z", function()
    vscode.call "editor.action.addselectiontonextfindmatch"
  end, { silent = true })
  vim.keymap.set("n", "<C-l>", function()
    vscode.call "workbench.action.focusNextGroup"
  end, { silent = true })
  vim.keymap.set("n", "<C-h>", function()
    vscode.call "workbench.action.focusPreviousGroup"
  end, { silent = true })
  vim.keymap.set("n", "tt", function()
    vscode.call "workbench.action.toggleSidebarVisibility"
  end, { silent = true })
  vim.keymap.set("n", "<leader>t", function()
    vscode.call "workbench.view.explorer"
  end, { silent = true })
  vim.keymap.set("n", "<leader>q", function()
    vscode.call "workbench.action.closeActiveEditor"
  end, { silent = true })
  vim.keymap.set("n", "<leader><leader>v", function()
    vscode.call "workbench.action.splitEditorRight"
  end, { silent = true })
  vim.keymap.set("n", "<C-n>", function()
    vscode.call "workbench.action.nextEditor"
  end, { silent = true })
  vim.keymap.set("n", "<C-p>", function()
    vscode.call "workbench.action.previousEditor"
  end, { silent = true })
  vim.keymap.set("n", "]", function()
    vscode.call "workbench.action.increaseViewWidth"
  end, { silent = true })
  vim.keymap.set("n", "[", function()
    vscode.call "workbench.action.decreaseViewWidth"
  end, { silent = true })
  vim.keymap.set("n", "<leader>f", function()
    vscode.call "workbench.action.quickOpen"
  end, { silent = true })
  vim.keymap.set("n", "<leader>n", ":nohl<CR>", { silent = true })
else
  vim.opt.guicursor = "n-v-c:block-blinkon100-blinkoff100,i:ver25-blinkon100-blinkoff100"
  vim.o.sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,terminal,localoptions"

  vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
  vim.g.mapleader = " "
  vim.o.shell = "powershell.exe"
  vim.o.shellcmdflag = "-Command"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
  vim.o.relativenumber = true
  vim.o.clipboard = ""
  vim.o.scrolloff = 6

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
      return 1
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
      vim.bo.commentstring = "// %s"
    end,
  })

  vim.filetype.add {
    filename = {
      ["CMakelists.txt"] = "cmake",
      ["CMakeLists.txt"] = "cmake",
    },
  }

  require("autocmd").setup()

  local nsn = vim.api.nvim_get_namespaces()

  local counts = {}

  for name, ns in pairs(nsn) do
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local count = #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
      if count > 0 then
        counts[#counts + 1] = {
          name = name,
          buf = buf,
          count = count,
          ft = vim.bo[buf].ft,
        }
      end
    end
  end
  table.sort(counts, function(a, b)
    return a.count > b.count
  end)
  vim.print(counts)
end
