return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- Not strictly required but recommended for icons
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window
	},

	config = function()
		-- Define custom diagnostic signs (improves visibility)
		vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

		-- NeoTree configuration
		require("neo-tree").setup({
			-- Close NeoTree if it's the last window
			close_if_last_window = true,

			-- Filesystem configuration
			filesystem = {
				filtered_items = {
					visible = true,          -- Show hidden files by default
					hide_dotfiles = false,   -- Show dotfiles
					hide_gitignored = false, -- Show git-ignored files
				},
			},

			-- Window position and behavior
			window = {
				position = "right",                     -- Position the NeoTree on the right
				hijack_netrw_behavior = "open_default", -- When opening a directory, open NeoTree instead of netrw
				-- Other options:
				-- "open_current" - Open in the current window (like netrw)
				-- "disabled"    - Don't handle opening directories, netrw will open them
			},

			-- Icon configuration
			icon = {
				folder_closed = "",
				folder_open = "",
				folder_empty = "󰜌",
				provider = function(icon, node, state)
					-- Use nvim-web-devicons if available
					if node.type == "file" or node.type == "terminal" then
						local success, web_devicons = pcall(require, "nvim-web-devicons")
						local name = node.type == "terminal" and "terminal" or node.name
						if success then
							local devicon, hl = web_devicons.get_icon(name)
							icon.text = devicon or icon.text
							icon.highlight = hl or icon.highlight
						end
					end
				end,
				default = "*",                 -- Default icon
				highlight = "NeoTreeFileIcon", -- Icon highlight group
			},

			-- Git status indicators
			git_status = {
				symbols = {
					added = "✚", -- Added files
					modified = "", -- Modified files
					deleted = "✖", -- Deleted files
					renamed = "󰁕", -- Renamed files
					untracked = "", -- Untracked files
					ignored = "", -- Ignored files
					unstaged = "󰄱", -- Unstaged changes
					staged = "", -- Staged changes
					conflict = "", -- Conflicting files
				},
			},
		})

		-- Key mapping to toggle NeoTree
		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal right<CR>", { noremap = true, silent = true })

		-- Optional improvements for user experience:
		-- Auto-resize NeoTree window when opening
		vim.cmd([[autocmd FileType neo-tree setlocal winwidth=30]])
	end
}
