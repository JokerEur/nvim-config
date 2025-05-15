return {
	"folke/trouble.nvim",
	event = "VeryLazy",
	keys = {
		vim.keymap.set("n", "<leader>xx", function()
			local trouble = require("trouble")
			if trouble.is_open() then
				trouble.close()
			else
				trouble.open("diagnostics")
				vim.schedule(function()
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						local bufname = vim.api.nvim_buf_get_name(buf)
						if bufname:match("Trouble") then
							vim.api.nvim_set_current_win(win)
							break
						end
					end
				end)
			end
		end, { desc = "Toggle Diagnostics (Trouble) and jump" }),
	},
	opts = {
		position = "bottom",
		height = 10,
		width = 50,
		mode = "workspace_diagnostics",
		severity = nil,
		fold_open = "",
		fold_closed = "",
		group = true,
		padding = true,
		cycle_results = true,
		action_keys = {
			close = "q",
			cancel = "<esc>",
			refresh = "r",
			jump = { "<cr>", "<tab>", "<2-leftmouse>" },
			open_split = { "<c-x>" },
			open_vsplit = { "<c-v>" },
			open_tab = { "<c-t>" },
			jump_close = { "o" },
			toggle_mode = "m",
			switch_severity = "s",
			toggle_preview = "P",
			hover = "K",
			preview = "p",
			open_code_href = "c",
			close_folds = { "zM", "zm" },
			open_folds = { "zR", "zr" },
			toggle_fold = { "zA", "za" },
			previous = "k",
			next = "j",
			help = "?",
		},
		multiline = true,
		indent_lines = true,
		win_config = { border = "rounded" },
		auto_open = false,
		auto_close = false,
		auto_preview = true,
		auto_fold = false,
		auto_jump = { "lsp_definitions" },
		include_declaration = { "lsp_references", "lsp_implementations", "lsp_definitions" },
		signs = {
			error = "",
			warning = "",
			hint = "",
			information = "",
			other = "",
		},
		use_diagnostic_signs = false,
	},
}
