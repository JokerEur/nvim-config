return {
	"folke/which-key.nvim",
	-- Lazy load the plugin when a buffer is entered
	event = "BufWinEnter",

	config = function()
		-- Setup which-key with optimized settings
		require("which-key").setup({
			-- Use the classic preset for key mapping display style
			preset = "classic",

			-- Delay before showing the popup, adjust based on context
			delay = function(ctx)
				return ctx.plugin and 0 or 150 -- Shorter delay for a more responsive experience
			end,

			-- Filters mappings (default to including all mappings)
			filter = function(mapping)
				-- Only show mappings with a description
				return mapping.desc and mapping.desc ~= ""
			end,

			-- Automatically configure key mappings using the default spec
			spec = {},

			-- Show warning if there are issues with the mappings
			notify = true,

			-- Define key triggers
			triggers = {
				{ "<auto>", mode = "nxso" },
			},

			-- Defer showing the popup for Visual or Visual Block mode
			defer = function(ctx)
				return ctx.mode == "V" or ctx.mode == "<C-V>"
			end,

			-- Plugin-specific configuration
			plugins = {
				marks = true,  -- Show marks on `'` and `` ` ``
				registers = true, -- Show registers on `"`, <C-r>` in Insert mode
				spelling = {
					enabled = true, -- Enable spelling suggestions for z=
					suggestions = 10, -- Fewer suggestions for faster response
				},
				presets = {
					operators = true, -- Help for operators like d, y, etc.
					motions = true, -- Help for motions
					text_objects = true, -- Help for text objects after an operator
					windows = true, -- Bindings for window management with <c-w>
					nav = true,     -- Miscellaneous window management keybindings
					z = true,       -- Bindings for folds and other 'z' prefixed operations
					g = true,       -- Bindings for 'g' prefixed commands
				},
			},

			-- Window settings for which-key popup
			win = {
				no_overlap = true, -- Avoid overlapping the cursor
				padding = { 1, 2 }, -- Padding around the popup window
				title = true,   -- Display title for the window
				title_pos = "center", -- Center align title
				zindex = 1000,  -- Control z-index of the popup window
				border = "rounded", -- Border style (rounded)

				-- Dynamic height and width based on screen resolution
				height = { min = math.floor(vim.o.lines * 0.2), max = math.floor(vim.o.lines * 0.2) }, -- 10%-20% of screen height
				width = { min = math.floor(vim.o.columns * 0.45), max = math.floor(vim.o.columns * 0.45) }, -- 30%-50% of screen width

				-- Position window at the bottom with padding from the screen edges
				row = math.floor(vim.o.lines * 0.78), -- Position it near the bottom (80% of screen height)
				col = math.floor(vim.o.columns * 0.20), -- Padding from the left (5% of screen width)

				-- Set a transparent background (use winblend)
				wo = {
					winblend = 10, -- Semi-transparent background
				},
			},
			-- Layout settings for the key mapping popup window
			layout = {
				width = { min = 20, max = 50 }, -- Set a maximum and minimum width to avoid full width
				height = { min = 10, max = 20 }, -- Set a fixed height range
				spacing = 3,                 -- Spacing between columns
			},

			-- Scroll bindings inside the popup window
			keys = {
				scroll_down = "<c-d>", -- Scroll down inside popup
				scroll_up = "<c-u>", -- Scroll up inside popup
			},

			-- Sorting of key mappings
			sort = { "local", "order", "group", "alphanum", "mod" },

			-- Expand mappings when a group has less than 'n' mappings
			expand = 0, -- No automatic expansion based on mapping count

			-- Formatting for labels
			replace = {
				key = {
					function(key)
						return require("which-key.view").format(key)
					end,
				},
				desc = {
					{ "<Plug>%(?(.*)%)?", "%1" },
					{ "^%+",              "" },
					{ "<[cC]md>",         "" },
					{ "<[cC][rR]>",       "" },
					{ "<[sS]ilent>",      "" },
					{ "^lua%s+",          "" },
					{ "^call%s+",         "" },
					{ "^:%s*",            "" },
				},
			},

			-- Icons to use in the mappings
			icons = {
				breadcrumb = "»", -- Symbol for active key combo
				separator = "➜", -- Symbol between key and label
				group = "+", -- Symbol for groups
				ellipsis = "…", -- Ellipsis symbol for overflow
				mappings = true, -- Enable mapping icons
				rules = {}, -- Customize icon rules
				colors = true, -- Enable color highlighting
				keys = {
					Up = " ",
					Down = " ",
					Left = " ",
					Right = " ",
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
				},
			},

			-- Show help message when pressing ?
			show_help = true,
			-- Show currently pressed key in the command line
			show_keys = true,

			-- Disable which-key for Neo-tree buffers
			disable = {
				ft = { "neo-tree" }, -- Disable which-key in Neo-tree filetype
				bt = {},         -- You can also add buffer types if needed
			},

			-- Enable debug logging
			debug = false,
		})
	end,
}
