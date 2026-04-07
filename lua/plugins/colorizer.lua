return {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        filetypes = { "*", "!lazy", "!mason" },
        user_default_options = {
            RGB      = true,
            RRGGBB   = true,
            names    = false, -- avoid false positives on words like "red"
            RRGGBBAA = true,
            css      = true,
            mode     = "background", -- show swatch as background behind the text
        },
    },
}
