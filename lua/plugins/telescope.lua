return {
	-- Telescope Core
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		branch = "0.1.x",
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
				"<leader>fw",
				function()
					require("telescope.builtin").grep_string()
				end,
				desc = "Find Word",
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
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Find Help Tags",
			},

			{
				"<leader>gs",
				function()
					local input = vim.fn.input("Grep for > ")
					if input ~= "" then
						require("telescope.builtin").grep_string({ search = input })
					end
				end,
				desc = "Grep String (Prompt)",
			},
		},
		dependencies = { "nvim-telescope/telescope-ui-select.nvim" },
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					prompt_prefix = "   ",
					selection_caret = " ",
					sorting_strategy = "ascending",
					layout_config = { prompt_position = "top" },
					mappings = {
						i = {
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<Esc>"] = actions.close,
						},
					},
					file_ignore_patterns = { "node_modules", ".git/", "target/", "build/", "dist/" },
					path_display = { "truncate" },
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
				},
			})
		end,
	},

	-- UI-Select Plugin (Ensures it loads properly)
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
