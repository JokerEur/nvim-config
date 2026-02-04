return{
	'windwp/nvim-autopairs',
	config = function()
      require("nvim-autopairs").setup({
        fast_wrap = {},
        disable_filetype = { "TelescopePrompt", "vim" },
      })
	end
}
