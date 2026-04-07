return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    cmd = {
        "IBLEnable",
        "IBLDisable",
        "IBLToggle",
        "IBLEnableScope",
        "IBLDisableScope",
        "IBLToggleScope",
    },
    keys = {
        { "<leader>ug", "<cmd>IBLToggle<CR>",      desc = "Toggle indent guides" },
        { "<leader>us", "<cmd>IBLToggleScope<CR>", desc = "Toggle indent scope" },
    },
    ---@module "ibl"
    ---@type ibl.config
    opts = {
        -- Keep indent guides enabled by default (<leader>ug toggles it)
        enabled = true,
        -- Fewer refreshes = lower CPU use in large projects
        debounce = 300,
        viewport_buffer = {
            -- Generate guides only near viewport instead of huge offscreen ranges
            min = 15,
        },
        indent = {
            char = "▏",
            tab_char = "▏",
            smart_indent_cap = true,
        },
        whitespace = {
            remove_blankline_trail = true,
        },
        scope = {
            -- Keep scope enabled by default (<leader>us toggles it)
            enabled            = true,
            injected_languages = false,
            show_start         = true, -- underline at scope opening line
            show_end           = true, -- underline at scope closing line
        },
        exclude = {
            -- Disable guides in UI/special buffers where they add noise
            filetypes = {
                "alpha",
                "dashboard",
                "help",
                "lazy",
                "lspinfo",
                "mason",
                "neo-tree",
                "TelescopePrompt",
                "TelescopeResults",
                "Trouble",
                "trouble",
            },
            buftypes = {
                "terminal",
                "nofile",
                "prompt",
                "quickfix",
            },
        },
    },
    config = function(_, opts)
        local hooks = require("ibl.hooks")

        -- Hard stop for giant buffers/files to avoid unnecessary redraw work.
        hooks.register(hooks.type.ACTIVE, function(bufnr)
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name ~= "" then
                local ok_stat, stat = pcall(vim.loop.fs_stat, name)
                if ok_stat and stat and stat.size and stat.size > 256 * 1024 then
                    return false
                end
            end

            local ok_lines, line_count = pcall(vim.api.nvim_buf_line_count, bufnr)
            if ok_lines and line_count and line_count > 6000 then
                return false
            end

            return true
        end)

        require("ibl").setup(opts)
    end,
}
