return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local ts_configs = require("nvim-treesitter.configs")

			-- Disable Treesitter for large files (over ~256 KB)
			local function disable_large_files(_, buf)
				local max_filesize = 256 * 1024 -- 256 KB
				local fname = vim.api.nvim_buf_get_name(buf)
				local stat = vim.loop.fs_stat(fname)
				return stat and stat.size > max_filesize
			end

			ts_configs.setup({
				-- Parsers to install
				ensure_installed = {
					"lua",
					"rust",
					"cpp",
					"go",
					"gomod",
					"gosum",
					"gowork",
					"toml",
					"python",
					"cmake",
					"proto",
					"json",
					"yaml",
					"html",
					"css",
					"javascript",
					"typescript",
					"vue",
				},

				ignore_install = {},
				modules = {},

				auto_install = false,
				sync_install = false,

				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
					disable = disable_large_files,
				},

				indent = {
					enable = true,
					disable = disable_large_files,
				},

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn",
						node_incremental = "grn",
						scope_incremental = "grc",
						node_decremental = "grm",
					},
				},

			})
		end,
	},
}
