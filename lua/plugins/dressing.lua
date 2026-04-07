return {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
        input = {
            default_prompt = "➤ ",
            prefer_width = 0.4,
            win_options = {
                winblend = 10,
                winhighlight = "NormalFloat:Normal,FloatBorder:FloatBorder",
            },
        },
        select = {
            backend = { "telescope", "builtin" },
            telescope = {
                layout_strategy = "cursor",
                layout_config = { width = 0.5, height = 0.4 },
            },
        },
    },
}
