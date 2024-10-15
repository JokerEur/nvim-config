return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	confing = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
			ensure_installed = { "lua", "rust", "cpp", "go", "gomod", "gosum", "gowork", "toml", "python", "cmake", "proto" },
			auto_install = true,
			sync_install = false,
			highlight = {
				enable = true,
				disable = function(lang, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
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
