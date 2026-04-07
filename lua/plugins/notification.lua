return {
	"j-hui/fidget.nvim",
	event = "LspAttach",
	opts = {
		progress = {
			poll_rate = 0,
			suppress_on_insert = true,
			ignore_done_already = false,
			ignore_empty_message = true,
			ignore = { "null-ls", "none-ls" },
			display = {
				render_limit = 8,
				done_ttl = 3,
				done_icon = "✓",
				done_style = "DiagnosticOk",
				progress_ttl = math.huge,
				progress_icon = { pattern = "dots", period = 1 },
				progress_style = "DiagnosticWarn",
				group_style = "Title",
				icon_style = "DiagnosticInfo",
				priority = 30,
				skip_history = false,
				format_message = function(msg)
					local message = msg.message or ""
					if msg.percentage ~= nil then
						local label = message ~= "" and message or "Working"
						return string.format("%s (%d%%)", label, msg.percentage)
					end
					if message ~= "" then
						return message
					end
					return msg.done and "Done" or "In progress..."
				end,
				format_annote = function(msg)
					return msg.title or ""
				end,
				format_group_name = function(group)
					return tostring(group)
				end,
			},
		},
		notification = {
			poll_rate = 10,
			filter = vim.log.levels.INFO,
			history_size = 128,
			override_vim_notify = true,
			view = {
				stack_upwards = true,
				icon_separator = " ",
				group_separator = "─────",
				group_separator_hl = "Comment",
			},
			window = {
				normal_hl = "Normal",
				winblend = 10,
				border = "rounded",
				zindex = 45,
				max_width = 70,
				max_height = 15,
				x_padding = 1,
				y_padding = 1,
				align = "bottom",
				relative = "editor",
			},
		},
		integration = {
			["nvim-tree"] = { enable = false },
		},
	},
}
