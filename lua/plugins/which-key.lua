return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "classic",

		delay = function(ctx)
			return ctx.plugin and 0 or 400
		end,

		filter = function(mapping)
			return mapping.desc and mapping.desc ~= ""
		end,

		spec = {
			{ "<leader>f", group = "Find" },
			{ "<leader>g", group = "Git" },
			{ "<leader>c", group = "Code" },
			{ "<leader>a", group = "AI" },
			{ "<leader>x", group = "Trouble" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>t", group = "Test/Terminal" },
			{ "<leader>s", group = "Search/Replace" },
			{ "<leader>u", group = "UI/Toggle" },
			{ "<leader>w", group = "Window" },
			{ "<leader>q", group = "Session/Quit" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>h", group = "Hunk" },
			{ "g",         group = "Goto" },
			{ "]",         group = "Next" },
			{ "[",         group = "Prev" },
		},

		win = {
			border = "single",
			padding = { 1, 1 },
			title = false,
			wo = {
				winblend = 10,
			},
		},

		layout = {
			width = { min = 20, max = 50 },
			spacing = 3,
		},

		icons = {
			breadcrumb = "»",
			separator = "→",
			group = "+",
			mappings = false,
			colors = false,
		},

		sort = { "local", "order", "group", "alphanum", "mod" },

		expand = 0,

		plugins = {
			marks = false,
			registers = false,
			spelling = { enabled = false },
			presets = {
				operators = false,
				motions = false,
				text_objects = false,
				windows = false,
				nav = false,
				z = false,
				g = false,
			},
		},

		show_help = false,
		show_keys = true,

		disable = {
			ft = { "TelescopePrompt", "neo-tree", "alpha", "dashboard" },
			bt = { "terminal", "prompt" },
		},
	},
}