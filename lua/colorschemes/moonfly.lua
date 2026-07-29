return {
	"bluz71/vim-moonfly-colors",
	name = "moonfly",
	priority = 1000,
	init = function()
		-- Options must be set before the colorscheme is loaded.
		-- See :help moonfly
		vim.g.moonflyItalics = true
		vim.g.moonflyCursorColor = true
		vim.g.moonflyNormalFloat = true
		vim.g.moonflyUnderlineMatchParen = true
		vim.g.moonflyVirtualTextColor = true
		vim.g.moonflyTransparent = false
		vim.g.moonflyWinSeparator = 2
	end,
}
