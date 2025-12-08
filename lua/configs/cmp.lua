return function(_, opts)
    -- modify the options table
    local cmp = require "cmp"
    local luasnip = require "luasnip"
    opts.mapping = {
        ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                if luasnip.expandable() then
                    luasnip.expand()
                else
                    cmp.confirm {
                        select = true,
                    }
                end
            else
                fallback()
            end
        end),

        ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(1) then
                luasnip.jump(1)
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<C-j>"] = cmp.mapping(function(fallback)
            cmp.select_next_item()
        end, { "i", "s" }),

        ["<C-k>"] = cmp.mapping(function(fallback)
            cmp.select_prev_item()
        end, { "i", "s" }),
        ["<Down>"] = cmp.mapping(function(fallback)
            cmp.select_next_item()
        end, { "i", "s" }),

        ["<Up>"] = cmp.mapping(function(fallback)
            cmp.select_prev_item()
        end, { "i", "s" }),

        -- ... Your other mappings ...
    }
end
