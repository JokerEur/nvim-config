return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	keys = {
		{ "<C-n>",     ":Neotree filesystem reveal right<CR>", desc = "Toggle NeoTree" },
		{ "<leader>e", ":Neotree filesystem reveal right<CR>", desc = "Toggle NeoTree" },
	},
	init = function()
		vim.g.neo_tree_remove_legacy_commands = 1

		-- Auto-open NeoTree when starting nvim with a directory
		if vim.fn.argc() == 1 then
			local stat = vim.loop.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				require("neo-tree")
			end
		end
	end,
	config = function()
		-- Enhanced diagnostic signs with better icons
		vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

		require("neo-tree").setup({
			-- Auto-open when opening a directory
			open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },

			-- Performance optimizations
			enable_git_status = true,
			enable_diagnostics = true,
			enable_modified_markers = true,
			use_default_mappings = false,

			-- Close NeoTree if it's the last window
			close_if_last_window = true,

			-- Default component configurations
			default_component_configs = {
				indent = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					with_expanders = false,
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰜌",
					folder_empty_open = "󰜌",
					default = "󰈚",
					highlight = "NeoTreeFileIcon"
				},
				modified = {
					symbol = "",
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				git_status = {
					symbols = {
						added     = "",
						modified  = "",
						deleted   = "",
						renamed   = "➜",
						untracked = "",
						ignored   = "",
						unstaged  = "󰅙",
						staged    = "",
						conflict  = "",
					}
				},
				diagnostics = {
					symbols = {
						hint  = "󰌵",
						info  = "",
						warn  = "",
						error = "",
					},
				},
			},

			-- Filesystem configuration with LARGER window
			filesystem = {
				-- Auto-open when opening a directory with nvim .
				hijack_netrw_behavior = "open_default",
				bind_to_cwd = true,
				follow_current_file = {
					enabled = true,
				},

				window = {
					position = "right",
					width = 40,
					mappings = {
						["<space>"] = "toggle_node",
						["<2-LeftMouse>"] = "open",
						["<cr>"] = "open",
						["S"] = "open_split",
						["s"] = "open_vsplit",
						["t"] = "open_tabnew",
						["C"] = "close_node",
						["a"] = "add",
						["d"] = "delete",
						["r"] = "rename",
						["y"] = "copy_to_clipboard",
						["x"] = "cut_to_clipboard",
						["p"] = "paste_from_clipboard",
						["c"] = "copy",
						["m"] = "move",
						["q"] = "close_window",
						["R"] = "refresh",
						["?"] = "show_help",
						["<"] = "prev_source",
						[">"] = "next_source",
						["zh"] = "toggle_hidden", -- quickly show/hide dotfiles & ignored
					}
				},
				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_by_name = {
						"node_modules",
						".git",
						"dist",
						"build",
						"target",
					},
					never_show = {
						".DS_Store",
						"thumbs.db",
					},
				},
				renderers = {
					directory = {
						{ "indent" },
						{ "icon" },
						{ "current_filter" },
						{ "name", use_git_status_colors = true },
						{ "diagnostics" },
						{ "git_status" },
					},
					file = {
						{ "indent" },
						{ "icon" },
						{ "name", use_git_status_colors = true },
						{ "diagnostics" },
						{ "git_status" },
					},
				},
				use_libuv_file_watcher = true,
				group_empty_dirs = true,
			},

			-- Window configuration (also larger)
			window = {
				position = "right",
				width = 40, -- Increased from 35 to 50
				mappings = {
					["<space>"] = "toggle_node",
					["<2-LeftMouse>"] = "open",
					["<cr>"] = "open",
					["S"] = "open_split",
					["s"] = "open_vsplit",
					["t"] = "open_tabnew",
					["C"] = "close_node",
					["a"] = "add",
					["d"] = "delete",
					["r"] = "rename",
					["y"] = "copy_to_clipboard",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",
					["c"] = "copy",
					["m"] = "move",
					["q"] = "close_window",
					["R"] = "refresh",
					["?"] = "show_help",
					["<"] = "prev_source",
					[">"] = "next_source",
				}
			},

			-- Source selector
			source_selector = {
				winbar = true,
				statusline = false,
				sources = {
					{ source = "filesystem", display_name = " 󰉓 Files " },
					{ source = "buffers", display_name = " 󰈙 Buffers " },
					{ source = "git_status", display_name = " 󰊢 Git " },
				},
			},

			-- Buffers configuration
			buffers = {
				follow_current_file = {
					enabled = true,
				},
				group_empty_dirs = true,
				show_unloaded = true,
				window = {
					position = "left",
					mappings = {
						["<space>"] = "toggle_node",
						["<2-LeftMouse>"] = "open",
						["<cr>"] = "open",
						["S"] = "open_split",
						["s"] = "open_vsplit",
						["t"] = "open_tabnew",
						["C"] = "close_node",
						["bd"] = "buffer_delete",
						["<"] = "prev_source",
						[">"] = "next_source",
					}
				},
			},

			-- Git status configuration
			git_status = {
				window = {
					position = "float",
				},
			},
		})

		-- Custom highlights for Kanagawa integration
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = function()
				vim.api.nvim_set_hl(0, "NeoTreeNormal", { link = "Normal" })
				vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { link = "NormalNC" })
				vim.api.nvim_set_hl(0, "NeoTreeVertSplit", { link = "VertSplit" })
				vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { link = "WinSeparator" })
				vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { link = "FloatBorder" })
				vim.api.nvim_set_hl(0, "NeoTreeRootName", { fg = "#E6C384", bold = true })
				vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", { fg = "#7E9CD8", bold = true })
			end,
		})

		-- Auto-open NeoTree when nvim starts with a directory
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function(data)
				-- Only open if we're opening a directory and no file was specified
				local directory = vim.fn.isdirectory(data.file) == 1
				if not directory then
					return
				end

				-- Change to the directory
				vim.cmd.cd(data.file)

				-- Open neo-tree
				require("neo-tree.command").execute({
					source = "filesystem",
					position = "right",
					toggle = true,
					dir = vim.loop.cwd(),
				})
			end,
		})

		-- Set NeoTree window options
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "neo-tree",
			callback = function()
				vim.wo.signcolumn = "no"
				vim.wo.number = false
				vim.wo.relativenumber = false
				vim.wo.wrap = false
			end,
		})
	end,
}
