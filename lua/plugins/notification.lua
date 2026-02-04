return {
	"j-hui/fidget.nvim",
	event = "LspAttach",
	opts = {
		progress = {
			poll_rate = 0,
			suppress_on_insert = true,
			ignore_done_already = true,
			ignore_empty_message = true,
			ignore = { "null-ls", "none-ls" },
			display = {
				render_limit = 5,
				done_ttl = 2,
				done_icon = "✓",
				done_style = "Constant",
				progress_ttl = math.huge,
				progress_icon = { pattern = "dots", period = 1 },
				progress_style = "WarningMsg",
				group_style = "Title",
				icon_style = "Question",
				priority = 30,
				skip_history = true,
				format_message = function(msg)
					if msg.message then
						return msg.message
					end
					return msg.done and "Completed" or "In progress..."
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
			history_size = 64,
			override_vim_notify = true,
			view = {
				stack_upwards = false,
				icon_separator = " ",
				group_separator = "─────",
				group_separator_hl = "Comment",
			},
			window = {
				normal_hl = "Comment",
				winblend = 0,
				border = "rounded",
				zindex = 45,
				max_width = 40,
				max_height = 0,
				x_padding = 1,
				y_padding = 1,
				align = "top",
				relative = "win",
			},
		},
		integration = {
			["nvim-tree"] = { enable = false },
		},
	},
}
