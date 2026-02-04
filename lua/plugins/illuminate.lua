return {
	'RRethy/vim-illuminate',
	event = { "BufReadPost", "BufNewFile" }, -- Load only when editing a file
	config = function()
	local illuminate = require('illuminate')
	illuminate.configure({
			providers = {
				'lsp',        -- Prefer precise LSP locations
				'treesitter', -- Fallback when no LSP info
				'regex',      -- Last resort
			},

			-- Small, but not instant, to reduce flicker & CPU
			delay = 80,

			filetype_overrides = {},

			-- Deny UI-related and non-code buffers for efficiency
			filetypes_denylist = {
				'dirbuf', 'dirvish', 'fugitive',
				'neo-tree', 'nerdtree', 'packer', 'lazy', 'help',
				'qf', 'dashboard', 'alpha', 'log', 'man',
				'toggleterm', 'terminal', 'nofile', 'prompt',
			},

			filetypes_allowlist = {},

			-- Do not highlight while typing; only in normal/visual
			modes_denylist = { 'i' },
			modes_allowlist = {},

			-- Avoid matching inside comments/strings for regex provider
			providers_regex_syntax_denylist = { 'comment', 'string' },
			providers_regex_syntax_allowlist = {},

			under_cursor = true, -- Highlight word under cursor

			-- Optimize large file handling to avoid performance drops
			large_file_cutoff = 3000, -- Reduce impact on large files (default: 5000)
			large_file_overrides = {
				delay = 200,           -- Slightly increase delay for large files
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

		-- Underline-only highlight for illuminated words (no background fill)
		local function set_illuminate_highlights()
			local ok = pcall(vim.api.nvim_set_hl, 0, 'IlluminatedWordText', {
				underline = true,
				bold = false,
			})
			if not ok then return end

			vim.api.nvim_set_hl(0, 'IlluminatedWordRead', {
				underline = true,
				bold = false,
			})

			vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', {
				underline = true,
				bold = false,
			})
		end

		set_illuminate_highlights()
		vim.api.nvim_create_autocmd('ColorScheme', {
			callback = set_illuminate_highlights,
		})

		-- Developer helpers: jump between references and toggle
		local map_opts = { noremap = true, silent = true }
		vim.keymap.set('n', ']r', function()
			illuminate.goto_next_reference(false)
		end, vim.tbl_extend('keep', { desc = 'Next reference (illuminate)' }, map_opts))

		vim.keymap.set('n', '[r', function()
			illuminate.goto_prev_reference(false)
		end, vim.tbl_extend('keep', { desc = 'Previous reference (illuminate)' }, map_opts))

		vim.keymap.set('n', '<leader>ui', '<cmd>IlluminateToggle<CR>', vim.tbl_extend('keep', {
			desc = 'Toggle word highlighting (illuminate)',
		}, map_opts))
	end
}
