return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	confing = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
			ensure_installed = { "lua", "rust", "cpp", "toml", "python", "cmake" },
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			rainbow = {
				enable = true,
				extended_mode = true,
				max_file_lines = nil,
			}
		})
	end
}
