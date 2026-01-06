local function ensure_dir(path)
    path = vim.fn.expand(path)
    local stat = vim.loop.fs_stat(path)
    if not (stat and stat.type == "directory") then
        vim.fn.mkdir(path, "p") -- 0755
    end
end
return {
    "obsidian-nvim/obsidian.nvim",
    -- version = "*", -- recommended, use latest release instead of latest commit
    tag = "v3.14.8",
    ft = "markdown",
    cmd = { "Obsidian" },
    --@module 'obsidian'
    --@type obsidian.config
    opts = {
        legacy_commands = false,
        workspaces = {
            {
                name = "personal",
                path = "~/vaults/personal",
            },
            {
                name = "work",
                path = "~/vaults/work",
            },
        },
        note_id_func = function(title)
            if title ~= nil then
                local suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                return suffix .. "_" .. tostring(os.time())
            else
                return tostring(os.time())
            end
        end,
        templates = {
            folder = "templates",
            date_format = "%Y-%m-%d-%a",
            time_format = "%H:%M",
            substitutions = {
                titleSubs = function(ctx)
                    return string.gsub(ctx.partial_note.title, " ", "-")
                end,
                titleSubsUpper = function(ctx)
                    local title = string.gsub(ctx.partial_note.title, "(%w)(%w*)", function(first, rest)
                        return string.upper(first) .. rest
                    end)
                    return title
                end,
                titleSubsLower = function(ctx)
                    return string.lower(ctx.partial_note.title)
                end,
            },
        },
    },
    build = function()
        local vaults = "~/vaults"
        local personalPath = "~/vaults/personal"
        local workPath = "~/vaults/work/"

        ensure_dir(vaults)
        ensure_dir(personalPath)
        ensure_dir(workPath)
    end,
    keys = {
        {
            "<leader>o",
            function()
                vim.cmd "Obsidian"
            end,
            mode = { "n" },
            desc = "Open Obsidian Personal Vault",
        },
        {
            "<leader>o",
            function()
                vim.cmd "'<,'>Obsidian"
            end,
            mode = { "v" },
            desc = "Open Obsidian Work Vault",
        },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)
        vim.g.enable_render_markdown = false
    end,
}
