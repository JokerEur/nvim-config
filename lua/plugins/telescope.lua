return {
	-- Telescope Core
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
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
				"<leader>fg",
				function()
					local saved = vim.fn.getreg('"')
					vim.cmd('noau normal! y')
					local sel = vim.fn.getreg('"')
					vim.fn.setreg('"', saved)
					require("telescope.builtin").live_grep({ default_text = sel })
				end,
				mode = "v",
				desc = "Live Grep (selection)",
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
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local trouble_ok, trouble_tel = pcall(require, "trouble.sources.telescope")
			local open_with_trouble = trouble_ok and trouble_tel.open or nil
			local add_to_trouble   = trouble_ok and trouble_tel.add  or nil

			telescope.setup({
				defaults = {
					-- No borders - clean look
					border = true,

					layout_strategy = "vertical",
					layout_config = {
						vertical = {
							width = 0.6,
							height = 0.8,
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
							vertical = { width = 0.65, height = 0.75 },
						},
					},
					live_grep = {
						additional_args = function()
							return { "--hidden" }
						end,
						layout_config = {
							vertical = { width = 0.75, height = 0.85 },
						},
					},
					buffers = {
						layout_config = {
							vertical = { width = 0.6, height = 0.6 },
						},
					},
					help_tags = {
						layout_config = {
							vertical = { width = 0.6, height = 0.7 },
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
							borderchars = {
								prompt  = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
								results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
								preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
							},
						}),
					},
				},
			})

			-- Load extensions
			telescope.load_extension("fzf")
			telescope.load_extension("ui-select")

		end,
	},
}
