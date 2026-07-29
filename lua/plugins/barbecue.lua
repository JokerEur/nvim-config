return {
	"utilyre/barbecue.nvim",
	event = "LspAttach",
	dependencies = {
		"SmiteshP/nvim-navic",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("barbecue").setup({
			-- Disable the default autocmd (runs on every CursorMoved — very expensive)
			-- We replace it with a CursorHold-based update below
			create_autocmd = false,
			kinds = {
				File = "",
				Module = "",
				Namespace = "",
				Package = "",
				Class = "",
				Method = "",
				Property = "",
				Field = "",
				Constructor = "",
				Enum = "",
				Interface = "",
				Function = "",
				Variable = "",
				Constant = "",
				String = "",
				Number = "",
				Boolean = "",
				Array = "",
				Object = "",
				Key = "",
				Null = "",
				EnumMember = "",
				Struct = "",
				Event = "",
				Operator = "",
				TypeParameter = "",
			},
			separator = " › ",
		})

		-- Update winbar only on meaningful events, not on every cursor move
		vim.api.nvim_create_autocmd({
			"BufWinEnter",
			"BufWritePost",
			"CursorHold",
			"InsertLeave",
			"WinResized",
		}, {
			group = vim.api.nvim_create_augroup("barbecue.updater", { clear = true }),
			callback = function()
				require("barbecue.ui").update()
			end,
		})
	end,
}
