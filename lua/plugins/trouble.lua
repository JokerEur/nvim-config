--TODO fix trouble 
return {
	'folke/trouble.nvim',
	config = function()
	 	local	dependencies = { "nvim-tree/nvim-web-devicons" }

		require('trouble').setup({dependencies})
	end
}
