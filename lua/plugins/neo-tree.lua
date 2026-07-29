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
			local stat = vim.uv.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				require("neo-tree")
			end
		end
	end,
	config = function()
		-- Enhanced diagnostic signs with better icons
		vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

		require("neo-tree").setup({
			open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },

			popup_border_style = "rounded",
			sort_case_insensitive = true,

			enable_git_status = true,
			enable_diagnostics = true,
			enable_modified_markers = true,
			use_default_mappings = false,

			close_if_last_window = true,

			default_component_configs = {
				container = {
					enable_character_fade = true,
				},
				indent = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = "\u{E5FF}",
					folder_open = "\u{E5FE}",
					folder_empty = "󰜌",
					folder_empty_open = "󰜌",
					default = "󰈚",
					highlight = "NeoTreeFileIcon"
				},
				modified = {
					symbol = "",
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				git_status = {
					symbols = {
						added     = "",
						modified  = "",
						deleted   = "",
						renamed   = "➜",
						untracked = "",
						ignored   = "",
						unstaged  = "󰅙",
						staged    = "",
						conflict  = "",
					}
				},
				diagnostics = {
					symbols = {
						hint  = "󰌵",
						info  = "",
						warn  = "",
						error = "",
					},
				},
				file_size = {
					enabled = true,
					required_width = 64,
				},
				last_modified = {
					enabled = true,
					required_width = 88,
				},
				created = {
					enabled = false,
				},
				symlink_target = {
					enabled = true,
				},
			},

			-- Filesystem configuration
			filesystem = {
				hijack_netrw_behavior = "open_default",
				bind_to_cwd = true,
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				use_libuv_file_watcher = true,
				group_empty_dirs = true,

				window = {
					position = "right",
					width = 40,
					mappings = {
						-- Navigation
						["<space>"] = "toggle_node",
						["<2-LeftMouse>"] = "open",
						["<cr>"] = "open",
						["l"] = "open",
						["h"] = "close_node",
						["H"] = "navigate_up",
						["."] = "set_root",
						["<bs>"] = "navigate_up",
						-- Open modes
						["S"] = "open_split",
						["s"] = "open_vsplit",
						["t"] = "open_tabnew",
						["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = false } },
						-- File operations
						["a"] = { "add", config = { show_path = "relative" } },
						["A"] = "add_directory",
						["d"] = "delete",
						["r"] = "rename",
						["y"] = "copy_to_clipboard",
						["x"] = "cut_to_clipboard",
						["p"] = "paste_from_clipboard",
						["c"] = { "copy", config = { show_path = "relative" } },
						["m"] = { "move", config = { show_path = "relative" } },
						-- Info & search
						["i"] = "show_file_details",
						["f"] = "fuzzy_finder",
						["F"] = "fuzzy_finder_directory",
						["#"] = "fuzzy_sorter",
						["/"] = "filter_on_submit",
						["<esc>"] = "clear_filter",
						-- Window & view
						["q"] = "close_window",
						["R"] = "refresh",
						["?"] = "show_help",
						["<"] = "prev_source",
						[">"] = "next_source",
						["zh"] = "toggle_hidden",
						-- Sort
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					}
				},
				filtered_items = {
					visible = true,
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
						{ "diagnostics", zindex = 20 },
						{ "git_status", zindex = 10 },
					},
					file = {
						{ "indent" },
						{ "icon" },
						{ "name", use_git_status_colors = true },
						{ "diagnostics", zindex = 20 },
						{ "git_status", zindex = 10 },
					},
					symlink = {
						{ "indent" },
						{ "icon", default = "" },
						{ "name", use_git_status_colors = true },
						{ "symlink_target", highlight = "NeoTreeSymbolicLinkTarget" },
					},
				},
			},

			-- Global window config (for non-filesystem sources)
			window = {
				position = "right",
				width = 40,
				mappings = {
					["<space>"] = "toggle_node",
					["<2-LeftMouse>"] = "open",
					["<cr>"] = "open",
					["l"] = "open",
					["h"] = "close_node",
					["S"] = "open_split",
					["s"] = "open_vsplit",
					["t"] = "open_tabnew",
					["P"] = { "toggle_preview", config = { use_float = true } },
					["C"] = "close_node",
					["a"] = "add",
					["d"] = "delete",
					["r"] = "rename",
					["y"] = "copy_to_clipboard",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",
					["c"] = "copy",
					["m"] = "move",
					["i"] = "show_file_details",
					["q"] = "close_window",
					["R"] = "refresh",
					["?"] = "show_help",
					["<"] = "prev_source",
					[">"] = "next_source",
				}
			},

			-- Source selector (tabs at the top)
			source_selector = {
				winbar = false,
				statusline = false,
				separator = { left = "", right = "" },
				show_scrolled_off_parent_node = true,
				sources = {
					{ source = "filesystem", display_name = " 󰉓 Files " },
					{ source = "buffers", display_name = " 󰈙 Buffers " },
					{ source = "git_status", display_name = " 󰊢 Git " },
				},
			},

			-- Buffers
			buffers = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				group_empty_dirs = true,
				show_unloaded = true,
				window = {
					position = "left",
					mappings = {
						["<space>"] = "toggle_node",
						["<2-LeftMouse>"] = "open",
						["<cr>"] = "open",
						["l"] = "open",
						["S"] = "open_split",
						["s"] = "open_vsplit",
						["t"] = "open_tabnew",
						["i"] = "show_file_details",
						["C"] = "close_node",
						["bd"] = "buffer_delete",
						["<"] = "prev_source",
						[">"] = "next_source",
					}
				},
			},

			-- Git status
			git_status = {
				window = {
					position = "float",
					mappings = {
						["A"]  = "git_add_all",
						["gu"] = "git_unstage_file",
						["ga"] = "git_add_file",
						["gr"] = "git_revert_file",
						["gc"] = "git_commit",
						["gp"] = "git_push",
						["gg"] = "git_commit_and_push",
						["<cr>"] = "open",
						["q"] = "close_window",
					}
				},
			},
		})

		-- =====================================================================
		-- Follow the active colorscheme.
		--
		-- Rather than hardcoding one theme's palette (which looked wrong under
		-- moonfly and the light kanagawa-lotus), derive neo-tree's colors from
		-- standard highlight groups every scheme defines (GitSigns*, Directory,
		-- Function, Comment, Diagnostic*). Loading a scheme wipes custom
		-- highlights, so re-apply on every ColorScheme (and once now).
		-- =====================================================================
		local function hl(name, attr)
			local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
			if not ok or not h then return nil end
			local v = h[attr]
			if type(v) ~= "number" then return nil end
			return string.format("#%06x", v)
		end

		local function pick(attr, groups, fallback)
			for _, g in ipairs(groups) do
				local c = hl(g, attr)
				if c then return c end
			end
			return fallback
		end

		local function apply_neotree_highlights()
			local dir       = pick("fg", { "Directory", "Title", "Function" }, "#7E9CD8")
			local accent    = pick("fg", { "Function", "Directory" }, "#7E9CD8")
			local special   = pick("fg", { "Special", "Type", "Constant" }, "#6A9589")
			local dim        = pick("fg", { "Comment", "NonText" }, "#727169")
			local dimmer     = pick("fg", { "NonText", "Comment" }, dim)
			-- Intuitive, high-contrast git palette so file status is obvious at a
			-- glance: GREEN = new/added, ORANGE/YELLOW = modified, RED = deleted.
			-- We deliberately source "modified" from a warning (yellow) group
			-- rather than GitSignsChange, because some schemes (moonfly) make
			-- GitSignsChange blue — which reads like an ordinary, unchanged file.
			local git_add   = pick("fg", { "GitSignsAdd", "diffAdded", "Added", "String" }, "#8CC85F")
			local git_chg   = pick("fg", { "DiagnosticWarn", "WarningMsg", "GitSignsChange" }, "#E0AF68")
			local git_del   = pick("fg", { "GitSignsDelete", "diffRemoved", "Removed", "ErrorMsg" }, "#F7768E")
			local untracked = pick("fg", { "GitSignsAdd", "diffAdded", "String" }, "#8CC85F")
			local renamed   = pick("fg", { "Function", "GitSignsChange", "Type" }, "#7FB4CA")
			local warn      = pick("fg", { "DiagnosticWarn", "WarningMsg" }, "#E0AF68")
			local err       = pick("fg", { "DiagnosticError", "ErrorMsg" }, "#F7768E")

			-- Base (link so window bg/borders match the scheme)
			vim.api.nvim_set_hl(0, "NeoTreeNormal", { link = "Normal" })
			vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { link = "NormalNC" })
			vim.api.nvim_set_hl(0, "NeoTreeVertSplit", { link = "VertSplit" })
			vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { link = "WinSeparator" })
			vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { link = "FloatBorder" })
			-- File info
			vim.api.nvim_set_hl(0, "NeoTreeRootName", { fg = dir, bold = true })
			vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", { fg = accent, bold = true })
			vim.api.nvim_set_hl(0, "NeoTreeSymbolicLinkTarget", { fg = special, italic = true })
			-- Git status colors. Changed entries are BOLD so they stand out from
			-- the neutral (gray) unchanged files. New files are italic to tell
			-- "brand new / untracked" apart from "modified".
			vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = git_add, bold = true })
			vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = git_chg, bold = true })
			vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = git_del, bold = true, strikethrough = true })
			vim.api.nvim_set_hl(0, "NeoTreeGitRenamed", { fg = renamed, bold = true })
			vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = untracked, italic = true })
			vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", { fg = dim, italic = true })
			vim.api.nvim_set_hl(0, "NeoTreeGitUnstaged", { fg = warn, bold = true })
			vim.api.nvim_set_hl(0, "NeoTreeGitStaged", { fg = git_add, bold = true })
			vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { fg = err, bold = true, underline = true })
			-- Dim metadata
			vim.api.nvim_set_hl(0, "NeoTreeFileSize", { fg = dimmer })
			vim.api.nvim_set_hl(0, "NeoTreeLastModified", { fg = dimmer })
		end

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("neotree_follow_colorscheme", { clear = true }),
			callback = apply_neotree_highlights,
		})
		apply_neotree_highlights()

		-- Auto-open NeoTree when nvim starts with a directory
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function(data)
				local directory = vim.fn.isdirectory(data.file) == 1
				if not directory then
					return
				end
				vim.cmd.cd(data.file)
				require("neo-tree.command").execute({
					source = "filesystem",
					position = "right",
					toggle = true,
					dir = vim.uv.cwd(),
				})
			end,
		})

		-- Set NeoTree window options + show file info in statusline on hover
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "neo-tree",
			callback = function(ev)
				vim.wo.signcolumn = "no"
				vim.wo.number = false
				vim.wo.relativenumber = false
				vim.wo.wrap = false

				local function fmt_size(bytes)
					if bytes < 1024 then return bytes .. " B"
					elseif bytes < 1024 * 1024 then return string.format("%.1f KB", bytes / 1024)
					else return string.format("%.1f MB", bytes / (1024 * 1024))
					end
				end

				vim.api.nvim_create_autocmd("CursorMoved", {
					buffer = ev.buf,
					callback = function()
						local ok, manager = pcall(require, "neo-tree.sources.manager")
						if not ok then return end
						local state = manager.get_state("filesystem")
						if not state or not state.tree then return end
						local node = state.tree:get_node()
						if not node or node.type ~= "file" then
							vim.wo.statusline = " "
							return
						end
						local stat = vim.uv.fs_stat(node.path)
						if not stat then
							vim.wo.statusline = " "
							return
						end
						local size = fmt_size(stat.size)
						local mtime = os.date("  %d %b %Y  %H:%M", stat.mtime.sec)
						vim.wo.statusline = "%#NeoTreeFileSize#   " .. size .. " %#NeoTreeLastModified#" .. mtime .. " %*"
					end,
				})
			end,
		})
	end,
}
