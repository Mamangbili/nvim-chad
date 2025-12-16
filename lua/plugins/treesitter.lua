return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
        ensure_installed = {
            "c",
            "cpp",
            "lua",
            "python",
            "javascript",
            "typescript",
            "tsx",
            "rust",
            "go",
            "java",
            "json",
            "html",
            "css",
            "bash",
            "yaml",
            "cmake",
        },
    },
    build = function()
        local function cpp_priority()
            local file_path = vim.fn.stdpath "data" .. "/lazy/nvim-treesitter/queries/cpp/highlights.scm"
            local lines = {}
            for line in io.lines(file_path) do
                if line:match "%(namespace_identifier%) %@module" then
                    table.insert(lines, "((namespace_identifier) @module (#set! priority 105))")
                else
                    table.insert(lines, line)
                end
            end
            local f = io.open(file_path, "w")
            f:write(table.concat(lines, "\n"))
            f:close()
        end

        cpp_priority()
    end,
}
