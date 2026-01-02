local M = {}
local function Close_window()
    vim.cmd "q!"
end
local function telescope_vsplit()
    require("telescope.builtin").find_files {
        attach_mappings = function(prompt_bufnr)
            local actions = require "telescope.actions"
            actions.select_default:replace(function()
                actions.file_vsplit(prompt_bufnr)
            end)
            return true
        end,
    }
end
local function telescope_hsplit()
    require("telescope.builtin").find_files {
        attach_mappings = function(prompt_bufnr)
            local actions = require "telescope.actions"
            actions.select_default:replace(function()
                actions.file_split(prompt_bufnr)
            end)
            return true
        end,
    }
end

local function paste_without_newline()
    local content = vim.fn.getreg "+"
    -- Remove trailing CR/LF (handles \n, \r\n, \r)
    content = content:gsub("[\r\n]+$", "")
    vim.fn.setreg("z", content) -- use 'z' as temp register (safe, non-default)
    return "<C-r>z"
end

local function Close_buffer()
local tree = require("nvim-tree.api").tree
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
-- toggle between terminal mode and normal terminal mode
local function toggle_betwee()
    local mode = vim.fn.mode()
    if mode == "t" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
        -- else
        --     vim.api.nvim_feedkeys("i", "n", false)
    end
end

local function subtitute_old_word()
    local old_word = nil
    vim.ui.input({ prompt = "Substitute old word: " }, function(input)
        old_word = input
    end)
    if old_word == nil then
        return
    end
    local prompt = "Substitute " .. old_word .. " with new word: "
    vim.ui.input({ prompt = prompt }, function(new_word)
        if old_word ~= "" and new_word ~= nil then
            -- Escape inputs
            local esc_old = vim.fn.escape(old_word, "/\\.*$^~[]")
            local esc_new = vim.fn.escape(new_word, "/\\&~")
            local start_pos = vim.fn.getpos "'<"
            local end_pos = vim.fn.getpos "'>"

            -- Build command safely
            -- local cmd = string.format("'<,'>s/%s/%s/g", esc_old, esc_new)
            local cmd = start_pos[2] .. "," .. end_pos[2] .. "s/" .. esc_old .. "/" .. esc_new .. "/gI"
            vim.cmd(cmd)
            vim.cmd ":nohl"
        end
    end)
end

-- Detect 'q' then '/' in Normal mode
local last_key = nil

local function on_key(key)
    local mode = vim.fn.mode(1)

    if mode ~= "n" then
        last_key = nil -- reset on mode change
        return
    end

    if (last_key == "q" and key == "/") or (last_key == "q" and key == ":") or (last_key == "q" and key == "?") then
        vim.schedule(function()
            vim.cmd "q!"
        end)
    end

    last_key = key
end
M.telescope_vsplit = telescope_vsplit
M.telescope_hsplit = telescope_hsplit
M.paste_without_newline = paste_without_newline
M.on_key = on_key
M.subtitute_old_word = subtitute_old_word
M.Close_window = Close_window
M.Close_buffer = Close_buffer
M.toggle_betwee = toggle_betwee
return M
