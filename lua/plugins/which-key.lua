return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.opt.timeout = true
		vim.opt.timeoutlen = 300
	end,
	opts = {
		---@type false | "classic" | "modern" | "helix"
		preset = "modern",

		-- Delay before showing the popup
		delay = function(ctx)
			return ctx.plugin and 0 or 150
		end,

		-- Filtering
		filter = function(mapping)
			return mapping.desc and mapping.desc ~= ""
		end,

		spec = {
			-- Leader groups
			{ "<leader>f", group = "Find", icon = " " },
			{ "<leader>g", group = "Git", icon = "󰊢 " },
			{ "<leader>c", group = "Code", icon = " " },
			{ "<leader>a", group = "AI", icon = "󱚣 " },
			{ "<leader>x", group = "Trouble", icon = "󱖫 " },
			{ "<leader>b", group = "Buffer", icon = "󰈙 " },
			{ "<leader>d", group = "Debug", icon = " " },
			{ "<leader>t", group = "Test/Terminal", icon = "󰙨 " },
			{ "<leader>s", group = "Search/Replace", icon = " " },
			{ "<leader>u", group = "UI/Toggle", icon = "󰙵 " },
			{ "<leader>w", group = "Window", icon = " " },
			{ "<leader>q", group = "Session/Quit", icon = "󰗼 " },

			-- Goto groups
			{ "g", group = "Goto", icon = "󰁔 " },
			{ "gs", group = "Surround", icon = "󰅪 " },

			-- Bracket navigation
			{ "]", group = "Next", icon = "󰒭 " },
			{ "[", group = "Prev", icon = "󰒮 " },

			-- z commands
			{ "z", group = "Fold/Scroll", icon = "󰁌 " },

			-- LSP specific (shown in buffer with LSP)
			{ "<leader>l", group = "LSP", icon = " " },
			{ "<leader>lw", group = "Workspace", icon = "󰉋 " },
		},

		win = {
			no_overlap = true,
			border = "rounded",
			padding = { 1, 2 },
			title = true,
			title_pos = "center",
			zindex = 1000,
			bo = {},
			wo = {
				winblend = 10,
			},
		},

		layout = {
			width = { min = 20 },
			spacing = 3,
		},

		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = " ",
			ellipsis = "…",
			mappings = true,
			rules = {
				{ pattern = "find", icon = " ", color = "green" },
				{ pattern = "search", icon = " ", color = "green" },
				{ pattern = "grep", icon = " ", color = "green" },
				{ pattern = "git", icon = "󰊢 ", color = "orange" },
				{ pattern = "commit", icon = " ", color = "orange" },
				{ pattern = "branch", icon = " ", color = "orange" },
				{ pattern = "hunk", icon = "󰊢 ", color = "orange" },
				{ pattern = "diagnostic", icon = " ", color = "red" },
				{ pattern = "trouble", icon = "󱖫 ", color = "red" },
				{ pattern = "error", icon = " ", color = "red" },
				{ pattern = "warning", icon = " ", color = "yellow" },
				{ pattern = "buffer", icon = "󰈙 ", color = "cyan" },
				{ pattern = "file", icon = " ", color = "cyan" },
				{ pattern = "terminal", icon = " ", color = "purple" },
				{ pattern = "test", icon = "󰙨 ", color = "yellow" },
				{ pattern = "debug", icon = " ", color = "red" },
				{ pattern = "code.action", icon = "󰌵 ", color = "yellow" },
				{ pattern = "rename", icon = "󰑕 ", color = "purple" },
				{ pattern = "format", icon = "󰉿 ", color = "cyan" },
				{ pattern = "definition", icon = "󰈮 ", color = "blue" },
				{ pattern = "reference", icon = "󰈇 ", color = "blue" },
				{ pattern = "symbol", icon = " ", color = "purple" },
				{ pattern = "hover", icon = "󰋼 ", color = "cyan" },
				{ pattern = "fold", icon = "󰁌 ", color = "purple" },
				{ pattern = "split", icon = "󰤼 ", color = "cyan" },
				{ pattern = "window", icon = " ", color = "cyan" },
				{ pattern = "tab", icon = "󰓩 ", color = "cyan" },
				{ pattern = "help", icon = "󰋖 ", color = "purple" },
				{ pattern = "session", icon = "󰁯 ", color = "azure" },
				{ pattern = "quit", icon = "󰗼 ", color = "red" },
				{ pattern = "close", icon = "󰅖 ", color = "red" },
				{ pattern = "delete", icon = "󰆴 ", color = "red" },
				{ pattern = "next", icon = "󰒭 ", color = "blue" },
				{ pattern = "prev", icon = "󰒮 ", color = "blue" },
				{ pattern = "toggle", icon = "󰔡 ", color = "yellow" },
				{ pattern = "lazy", icon = "󰒲 ", color = "cyan" },
				{ pattern = "mason", icon = " ", color = "cyan" },
				{ pattern = "claude", icon = "󱚣 ", color = "azure" },
				{ pattern = "diff", icon = "󰦓 ", color = "yellow" },
			},
			colors = true,
			keys = {
				Up = " ",
				Down = " ",
				Left = " ",
				Right = " ",
				C = "󰘴 ",
				M = "󰘵 ",
				D = "󰘳 ",
				S = "󰘶 ",
				CR = "󰌑 ",
				Esc = "󱊷 ",
				ScrollWheelDown = "󱕐 ",
				ScrollWheelUp = "󱕑 ",
				NL = "󰌑 ",
				BS = "󰁮",
				Space = "󱁐 ",
				Tab = "󰌒 ",
				F1 = "󱊫",
				F2 = "󱊬",
				F3 = "󱊭",
				F4 = "󱊮",
				F5 = "󱊯",
				F6 = "󱊰",
				F7 = "󱊱",
				F8 = "󱊲",
				F9 = "󱊳",
				F10 = "󱊴",
				F11 = "󱊵",
				F12 = "󱊶",
			},
		},

		sort = { "local", "order", "group", "alphanum", "mod" },

		expand = 0,

		plugins = {
			marks = true,
			registers = true,
			spelling = {
				enabled = true,
				suggestions = 20,
			},
			presets = {
				operators = true,
				motions = true,
				text_objects = true,
				windows = true,
				nav = true,
				z = true,
				g = true,
			},
		},

		keys = {
			scroll_down = "<c-d>",
			scroll_up = "<c-u>",
		},

		replace = {
			key = {
				function(key)
					return require("which-key.view").format(key)
				end,
			},
			desc = {
				{ "<Plug>%(?(.*)%)?", "%1" },
				{ "^%+", "" },
				{ "<[cC]md>", "" },
				{ "<[cC][rR]>", "" },
				{ "<[sS]ilent>", "" },
				{ "^lua%s+", "" },
				{ "^call%s+", "" },
				{ "^:%s*", "" },
			},
		},

		show_help = true,
		show_keys = true,

		disable = {
			ft = { "TelescopePrompt", "neo-tree", "alpha", "dashboard" },
			bt = { "terminal", "prompt" },
		},

		debug = false,
	},
}
