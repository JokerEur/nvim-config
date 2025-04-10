return {
	'RRethy/vim-illuminate',
	event = { "BufReadPost", "BufNewFile" }, -- Load only when editing a file
	config = function()
		require('illuminate').configure({
			providers = {
				'lsp',    -- Use LSP-based highlighting as primary provider
				'treesitter', -- Treesitter-based highlighting (fallback)
				'regex',  -- Regex-based highlighting (last resort)
			},

			delay = 50, -- Faster response time (default: 100ms)

			filetype_overrides = {},

			-- Deny UI-related and non-code buffers for efficiency
			filetypes_denylist = {
				'dirbuf', 'dirvish', 'fugitive',
				'nerdtree', 'packer', 'lazy', 'help',
				'qf', 'dashboard', 'alpha', 'log', 'man',
				'toggleterm', 'terminal', 'nofile', 'prompt',
			},

			filetypes_allowlist = {},

			modes_denylist = {},
			modes_allowlist = {},

			providers_regex_syntax_denylist = {},
			providers_regex_syntax_allowlist = {},

			under_cursor = true, -- Highlight word under cursor

			-- Optimize large file handling to avoid performance drops
			large_file_cutoff = 3000, -- Reduce impact on large files (default: 5000)
			large_file_overrides = {
				delay = 200,         -- Slightly increase delay for large files
				providers = { 'lsp' }, -- Only use LSP for large files
			},

			min_count_to_highlight = 2, -- Reduce noise by requiring at least 2 occurrences

			-- Disable illuminate in specific filetypes
			should_enable = function(bufnr)
				local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
				return not vim.tbl_contains({
					'nerdtree', 'packer', 'help', 'dashboard',
					'log', 'man', 'nofile', 'prompt'
				}, filetype)
			end,

			case_insensitive_regex = false, -- Keep regex case-sensitive for precision
		})
	end
}
