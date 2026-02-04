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
		})

		vim.cmd("colorscheme kanagawa-wave")
	end,
	init = function()
		vim.opt.background = "dark"
	end,
}
