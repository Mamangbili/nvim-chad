local function ensure_dir(path)
    path = vim.fn.expand(path)
    local stat = vim.loop.fs_stat(path)
    if not (stat and stat.type == "directory") then
        vim.fn.mkdir(path, "p") -- 0755
    end
end
return {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    ft = "markdown",
    cmd = { "Obsidian" },
    ---@module 'obsidian'
    ---@type obsidian.config
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
}
