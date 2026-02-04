return {
	"folke/todo-comments.nvim",
	config = function()
		require('todo-comments').setup({
			-- Show icons in the signs column

			signs = true,

			-- Sign priority determines where the sign appears in the sign column relative to other signs
			sign_priority = 8,

			-- Keywords and their settings
			keywords = {
				FIX = {
					icon = " ", -- Icon used for the sign and in search results
					color = "error", -- Color of the highlight (can be hex or named color)
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- Alternative keywords that map to this keyword
				},
				TODO = {
					icon = " ",
					color = "info"
				},
				HACK = {
					icon = " ",
					color = "warning"
				},
				WARN = {
					icon = " ",
					color = "warning",
					alt = { "WARNING", "XXX" }
				},
				PERF = {
					icon = " ",
					alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" }
				},
				NOTE = {
					icon = " ",
					color = "hint",
					alt = { "INFO" }
				},
				TEST = {
					icon = "⏲ ",
					color = "test",
					alt = { "TESTING", "PASSED", "FAILED" }
				},
			},

			-- GUI style for the highlights (foreground and background styles)
			gui_style = {
				fg = "NONE", -- The foreground style (None means no specific style)
				bg = "BOLD", -- Bold background style
			},

			-- Merge custom keywords with default ones
			merge_keywords = true,

			-- Highlighting settings for todo comments
			highlight = {
				multiline = true,                -- Enable highlighting for multi-line todo comments
				multiline_pattern = "^.",        -- Lua pattern to match the next multiline after the keyword
				multiline_context = 10,          -- Extra lines that will be considered for multi-line todo comments
				before = "",                     -- Highlighting before the keyword (empty means no highlight)
				keyword = "wide",                -- Wide highlighting around the keyword (can be "fg", "bg", "wide", etc.)
				after = "fg",                    -- Highlighting after the keyword (foreground style)
				pattern = [[.*<(KEYWORDS)\s*:]], -- Pattern for matching todo comments
				comments_only = true,            -- Only highlight keywords in comment lines
				max_line_len = 400,              -- Maximum line length for highlighting (ignores longer lines)
				exclude = {},                    -- List of file types to exclude from highlighting
			},

			-- Color customization for different keyword categories
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#10B981" },
				default = { "Identifier", "#7C3AED" },
				test = { "Identifier", "#FF00FF" }
			},

			-- Search settings for finding todo comments using ripgrep (rg)
			search = {
				command = "rg",      -- Use ripgrep for searching
				args = {
					"--color=never",   -- Disable color in the search result
					"--no-heading",    -- Hide headings for search results
					"--with-filename", -- Include the filename in the result
					"--line-number",   -- Include the line number
					"--column",        -- Include the column number
				},
				-- Pattern for searching todo comments in files (KEYWORDS placeholder is replaced)
				pattern = [[\b(KEYWORDS):]], -- Ripgrep regex pattern
			}
		})
	end
}

