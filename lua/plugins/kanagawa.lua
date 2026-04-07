return {
	"rebelot/kanagawa.nvim",
	priority = 1000,
	config = function()
		require("kanagawa").setup({
			compile = true,
			undercurl = true,
			commentStyle = { italic = true },
			keywordStyle = { italic = true },
			statementStyle = { bold = true },
			transparent = false,
			terminalColors = true,
			theme = "wave",
			overrides = function(colors)
				local theme = colors.theme
				return {
					LspInlayHint    = { link = "CodeiumSuggestion" },
					-- cursorlineopt="number" — highlight only the number; make it pop
					CursorLineNr    = { fg = colors.palette.carpYellow, bold = true },

					-- Crisp, visible window separator
					WinSeparator    = { fg = "#2D4F67", bold = true },

					-- Floats with a slightly darker background and blue border
					NormalFloat     = { bg = theme.ui.bg_m3 },
					FloatBorder     = { fg = "#7E9CD8", bg = theme.ui.bg_m3 },
					FloatTitle      = { fg = "#7E9CD8", bg = theme.ui.bg_m3, bold = true },

					-- Telescope inherits the float styling
					TelescopeNormal          = { bg = theme.ui.bg_m3 },
					TelescopeBorder          = { fg = "#7E9CD8", bg = theme.ui.bg_m3 },
					TelescopePromptNormal    = { bg = theme.ui.bg_p1 },
					TelescopePromptBorder    = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
					TelescopePromptTitle     = { fg = theme.ui.bg_p1, bg = "#E46876", bold = true },
					TelescopePreviewTitle    = { fg = theme.ui.bg_m3, bg = "#98BB6C", bold = true },
					TelescopeResultsTitle    = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
				}
			end,
		})

		vim.cmd("colorscheme kanagawa-wave")
	end,
	init = function()
		vim.opt.background = "dark"
	end,
}