return {
	-- Telescope Core
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
		},
		cmd = "Telescope",
		keys = {
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live Grep",
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Find Buffers",
			},
			{
				"<leader>fc",
				function()
					require("telescope.builtin").git_commits()
				end,
				desc = "Git Commits",
			},
			{
				"<leader>fw",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find()
				end,
				desc = "Find word in current buffer",
			},
			{
				"<leader>ca",
				vim.lsp.buf.code_action,
				desc = "Code Actions",
			},
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local open_with_trouble = require("trouble.sources.telescope").open
			local add_to_trouble = require("trouble.sources.telescope").add

			telescope.setup({
				defaults = {
					-- No borders - clean look
					border = true,

					layout_strategy = "vertical",
					layout_config = {
						center = {
							width = 0.6, -- 60% of screen width
							height = 0.6, -- 60% of screen height
							preview_cutoff = 30,
							prompt_position = "top",
						},
					},

					-- Clean visual configuration
					prompt_prefix = "   ",
					selection_caret = "  ",
					entry_prefix = "  ",
					initial_mode = "insert",
					sorting_strategy = "ascending",

					-- Essential mappings
						mappings = {
							i = {
								["<C-j>"] = actions.move_selection_next,
								["<C-k>"] = actions.move_selection_previous,
								["<C-c>"] = actions.close,
								["<Esc>"] = actions.close,
								["<CR>"] = actions.select_default,
								["<C-x>"] = actions.select_horizontal,
								["<C-v>"] = actions.select_vertical,
								["<C-t>"] = open_with_trouble,
								["<C-a>"] = add_to_trouble,
							},
							n = {
								["q"] = actions.close,
								["<CR>"] = actions.select_default,
								["<C-t>"] = open_with_trouble,
								["<C-a>"] = add_to_trouble,
							},
						},

					-- File handling
					file_ignore_patterns = {
						"node_modules/",
						".git/",
						"target/",
						"build/",
						"dist/",
					},
					path_display = { "truncate" },

					-- Fast grep configuration
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
					},

					-- UI improvements
					preview = {
						timeout = 80,
						treesitter = true,
					},
					color_devicons = true,
					set_env = { ["COLORTERM"] = "truecolor" },

					-- Subtle visual enhancements without borders
					winblend = 0, -- Solid background
				},

				pickers = {
					find_files = {
						find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
						layout_config = {
							center = { width = 0.65, height = 0.55 },
						},
					},
					live_grep = {
						additional_args = function()
							return { "--hidden" }
						end,
						layout_config = {
							center = { width = 0.75, height = 0.65 },
						},
					},
					buffers = {
						layout_config = {
							center = { width = 0.6, height = 0.5 },
						},
					},
					help_tags = {
						layout_config = {
							center = { width = 0.6, height = 0.5 },
						},
					},
				},

				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					["ui-select"] = {
						require("telescope.themes").get_dropdown({
							width = 0.4,
							previewer = false,
						}),
					},
				},
			})

			-- Load extensions
			telescope.load_extension("fzf")
			telescope.load_extension("ui-select")

			-- Clean highlights for borderless design
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function()
					local colors = {
						bg = "#1F1F28",
						bg_dark = "#16161D",
						bg_highlight = "#2A2A37",
						fg = "#DCD7BA",
						yellow = "#E6C384",
						green = "#98BB6C",
						blue = "#7E9CD8",
					}

					vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = colors.bg, fg = colors.fg })
					vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = colors.bg_dark })
					vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.yellow, bold = true })
					vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = colors.bg_highlight, bold = true })
					vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.green, bold = true })

					-- Remove border highlights since we don't have borders
					vim.api.nvim_set_hl(0, "TelescopeBorder", {})
					vim.api.nvim_set_hl(0, "TelescopePromptBorder", {})
					vim.api.nvim_set_hl(0, "TelescopePreviewBorder", {})
				end,
			})

			-- Apply clean highlights immediately
			vim.schedule(function()
				vim.api.nvim_set_hl(0, "TelescopeSelection", { link = "Visual" })
				vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "Normal" })
			end)
		end,
	},
}
