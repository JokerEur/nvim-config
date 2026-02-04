return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy", -- Faster loading
	config = function()
		-- Kanagawa color palette (wave theme)
		local colors = {
			bg = "#1F1F28", -- Kanagawa background
			fg = "#DCD7BA", -- Foreground
			yellow = "#E6C384", -- Yellow
			cyan = "#7FB4CA", -- Cyan
			darkblue = "#7E9CD8", -- Blue
			green = "#98BB6C", -- Green
			orange = "#FFA066", -- Orange
			violet = "#957FB8", -- Violet
			magenta = "#C8A3D9", -- Magenta
			blue = "#7FB4CA", -- Light blue
			red = "#E46876", -- Red
			waveBlue = "#7E9CD8", -- Wave theme blue
			crystalBlue = "#7EB3C8", -- Crystal blue
		}

		local conditions = {
			buffer_not_empty = function()
				return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
			end,
			hide_in_width = function()
				return vim.fn.winwidth(0) > 80
			end,
			check_git_workspace = function()
				local filepath = vim.fn.expand("%:p:h")
				local gitdir = vim.fn.finddir(".git", filepath .. ";")
				return gitdir and #gitdir > 0 and #gitdir < #filepath
			end,
		}

		local config = {
			options = {
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				theme = "kanagawa", -- Use built-in Kanagawa theme
				globalstatus = true, -- Single statusline for all windows
				disabled_filetypes = { statusline = { "dashboard", "alpha" } },
			},
			sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_y = {},
				lualine_z = {},
				lualine_c = {},
				lualine_x = {},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_y = {},
				lualine_z = {},
				lualine_c = {},
				lualine_x = {},
			},
			extensions = { "neo-tree", "lazy" },
		}

		local function ins_left(component)
			table.insert(config.sections.lualine_c, component)
		end

		local function ins_right(component)
			table.insert(config.sections.lualine_x, component)
		end

		-- Left section - Enhanced visual design
		ins_left({
			function()
				return ""
			end,
			color = { fg = colors.waveBlue, bg = colors.bg },
			padding = { left = 0, right = 0 },
		})
		ins_left({
			"mode",
			fmt = function(str)
				local mode_map = {
					n = "NORMAL",
					i = "INSERT",
					v = "VISUAL",
					V = "V-LINE",
					[""] = "V-BLOCK",
					c = "COMMAND",
					s = "SELECT",
					S = "S-LINE",
					ic = "INSERT",
					R = "REPLACE",
					Rv = "V-REPLACE",
					cv = "COMMAND",
					ce = "COMMAND",
					r = "PROMPT",
					rm = "MORE",
					["r?"] = "CONFIRM",
					["!"] = "SHELL",
					t = "TERMINAL",
				}
				return mode_map[str] or str
			end,
			color = { fg = colors.bg, bg = colors.waveBlue, gui = "bold" },
			padding = { left = 1, right = 1 },
		})
		ins_left({
			function()
				return ""
			end,
			color = { fg = colors.waveBlue, bg = "transparent" },
			padding = { left = 0, right = 1 },
		})

		ins_left({
			"filesize",
			cond = conditions.buffer_not_empty,
			color = { fg = colors.cyan, gui = "italic" },
		})

		ins_left({
			"filename",
			cond = conditions.buffer_not_empty,
			color = { fg = colors.magenta, gui = "bold" },
			symbols = { modified = "  ", readonly = "  ", unnamed = "  " },
		})

		ins_left({
			"location",
			color = { fg = colors.yellow },
		})

		ins_left({
			"progress",
			color = { fg = colors.fg, gui = "bold" },
			fmt = function()
				return "%P:%L"
			end,
		})

		ins_left({
			"diagnostics",
			sources = { "nvim_diagnostic" },
			symbols = { error = " ", warn = " ", info = " ", hint = " " },
			diagnostics_color = {
				error = { fg = colors.red },
				warn = { fg = colors.yellow },
				info = { fg = colors.cyan },
				hint = { fg = colors.green },
			},
			colored = true,
			update_in_insert = false,
		})

		-- LSP & formatters display - Optimized
		ins_left({
			function()
				local buf_ft = vim.bo.filetype
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if not clients or vim.tbl_isempty(clients) then
					return ""
				end

				local client_names = {}
				for _, client in ipairs(clients) do
					if client.name ~= "null-ls" then
						table.insert(client_names, client.name)
					end
				end

				-- Check for null-ls formatters
				local formatters = {}
				local ok, null_ls = pcall(require, "null-ls")
				if ok and null_ls then
					local sources = null_ls.get_sources()
					for _, source in ipairs(sources) do
						if source.filetypes and vim.tbl_contains(source.filetypes, buf_ft) then
							if source.method == null_ls.methods.FORMATTING then
								table.insert(formatters, source.name)
							end
						end
					end
				end

				local parts = {}
				if #client_names > 0 then
					table.insert(parts, " " .. table.concat(client_names, ", "))
				end
				if #formatters > 0 then
					table.insert(parts, " " .. table.concat(formatters, ", "))
				end

				return #parts > 0 and table.concat(parts, " | ") or ""
			end,
			color = { fg = colors.fg, gui = "italic" },
			cond = conditions.hide_in_width,
		})

		ins_left({
			function()
				return "%="
			end,
		})

		-- Right section - Enhanced design
		ins_right({
			"o:encoding",
			fmt = string.upper,
			cond = conditions.hide_in_width,
			color = { fg = colors.green, gui = "bold" },
		})

		ins_right({
			"fileformat",
			fmt = string.upper,
			icons_enabled = true,
			symbols = { unix = " ", dos = " ", mac = " " },
			color = { fg = colors.green, gui = "bold" },
		})

		ins_right({
			"branch",
			icon = "",
			color = { fg = colors.violet, gui = "bold" },
		})

		ins_right({
			"diff",
			symbols = { added = " ", modified = " ", removed = " " },
			diff_color = {
				added = { fg = colors.green },
				modified = { fg = colors.orange },
				removed = { fg = colors.red },
			},
			cond = conditions.hide_in_width,
		})

		-- Right side visual separator
		ins_right({
			function()
				return ""
			end,
			color = { fg = colors.crystalBlue, bg = "transparent" },
			padding = { left = 1, right = 0 },
		})
		ins_right({
			"filetype",
			color = { fg = colors.bg, bg = colors.crystalBlue, gui = "bold" },
			padding = { left = 1, right = 1 },
		})
		ins_right({
			function()
				return ""
			end,
			color = { fg = colors.crystalBlue, bg = colors.bg },
			padding = { left = 0, right = 0 },
		})

		-- Apply configuration
		require("lualine").setup(config)
	end,
}
