return {
	"j-hui/fidget.nvim",
	branch = "main",
	event = "LspAttach",
	config = function()
		local ok, fidget = pcall(require, "fidget")
		if not ok then
			vim.notify("Fidget.nvim not found. Skipping setup.", vim.log.levels.WARN)
			return
		end

		fidget.setup({
			text = {
				spinner = "dots",
				done = "✔",
				commenced = "Started",
				completed = "Completed",
			},
			timer = {
				spinner_rate = 125,
				fidget_decay = 2000,
				task_decay = 1000,
			},
			fmt = {
				leftpad = true,
				stack_upwards = true,
				max_width = 50,
				fidget = function(name, spinner)
					return name .. " " .. spinner
				end,
				task = function(task_name, message, percentage)
					return string.format(
						"%s%s%s",
						task_name,
						message ~= "" and ": " .. message or "",
						percentage and (" (" .. percentage .. "%)") or ""
					)
				end,
			},
			sources = { ["null-ls"] = { ignore = true } },
			debug = { logging = false, strict = false },
			progress = {
				poll_rate = 0,
				suppress_on_insert = true,
				ignore_done_already = true,
				ignore_empty_message = true,
				clear_on_detach = function(client_id)
					local client = vim.lsp.get_client_by_id(client_id)
					return client and client.name or nil
				end,
				display = {
					render_limit = 16,
					done_ttl = 3,
					done_icon = "✔",
					done_style = "Constant",
					progress_ttl = math.huge,
					progress_icon = { "dots" },
					progress_style = "WarningMsg",
					group_style = "Title",
					icon_style = "Question",
					priority = 30,
					skip_history = true,
				},
			},
			notification = {
				poll_rate = 10,
				filter = vim.log.levels.INFO,
				history_size = 128,
				override_vim_notify = false,
				view = {
					stack_upwards = true,
					icon_separator = " ",
					group_separator = "---",
					group_separator_hl = "Comment",
					line_margin = 1,
					render_message = function(msg, cnt)
						return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg)
					end,
				},
				align = { bottom = true, right = true }, -- keep right-aligned
				window = {
					relative = "editor",
					winblend = 100, -- fully transparent
					border = "none",
					zindex = 45,
					align = "bottom",
				},
			},
			integration = { ["nvim-tree"] = { enable = true } },
			logger = {
				level = vim.log.levels.WARN,
				max_size = 10000,
				float_precision = 0.01,
				path = string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache")),
			},
		})
	end,
}
