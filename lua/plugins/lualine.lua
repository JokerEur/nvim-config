return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		-- Read a color attribute ("fg"/"bg") from a highlight group and return it
		-- as "#rrggbb", following links. Returns nil when the group/attr is unset
		-- so callers can fall back.
		local function hl(name, attr)
			local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
			if not ok or not h then return nil end
			local v = h[attr]
			if type(v) ~= "number" then return nil end
			return string.format("#%06x", v)
		end

		-- First group that actually defines `attr`, else the hardcoded fallback.
		local function pick(attr, groups, fallback)
			for _, g in ipairs(groups) do
				local c = hl(g, attr)
				if c then return c end
			end
			return fallback
		end

		-- Derive the palette from the ACTIVE colorscheme's highlight groups.
		-- Semantic slots map to widely-defined standard groups, so the statusline
		-- follows whatever scheme is loaded (kanagawa, moonfly, …). The fallbacks
		-- are the old kanagawa-wave values, used only if a group is missing.
		local function get_colors()
			return {
				bg      = pick("bg", { "StatusLine", "Normal" }, "#1F1F28"),
				fg      = pick("fg", { "Normal" }, "#DCD7BA"),
				yellow  = pick("fg", { "DiagnosticWarn", "WarningMsg" }, "#E6C384"),
				cyan    = pick("fg", { "DiagnosticInfo", "Special" }, "#7FB4CA"),
				green   = pick("fg", { "String", "DiagnosticOk", "DiagnosticHint" }, "#98BB6C"),
				orange  = pick("fg", { "Constant", "Number" }, "#FFA066"),
				violet  = pick("fg", { "Statement", "Keyword" }, "#957FB8"),
				magenta = pick("fg", { "Identifier", "Type" }, "#C8A3D9"),
				red     = pick("fg", { "DiagnosticError", "ErrorMsg" }, "#E46876"),
				accent  = pick("fg", { "Function" }, "#7E9CD8"),
			}
		end

		local conditions = {
			buffer_not_empty = function()
				return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
			end,
			hide_in_width = function()
				return vim.fn.winwidth(0) > 80
			end,
		}

		-- LSP display (cached): statusline re-renders a lot; keep this O(1) per redraw.
		local lsp_cache = {}
		local function compute_lsp_segment(bufnr)
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			if not clients or vim.tbl_isempty(clients) then
				return ""
			end

			local names = {}
			for _, client in ipairs(clients) do
				names[#names + 1] = client.name
			end

			if #names == 0 then return "" end
			return " " .. table.concat(names, ", ")
		end

		local function update_lsp_cache(bufnr)
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end
			lsp_cache[bufnr] = compute_lsp_segment(bufnr)
		end

		vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
			callback = function(args)
				update_lsp_cache(args.buf)
			end,
		})

		vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "FileType" }, {
			callback = function(args)
				update_lsp_cache(args.buf)
			end,
		})

		vim.api.nvim_create_autocmd("BufWipeout", {
			callback = function(args)
				lsp_cache[args.buf] = nil
			end,
		})

		-- Build the full lualine config against the CURRENT palette. Called on
		-- first setup and again on every ColorScheme so component colors track
		-- the active scheme instead of being frozen to kanagawa.
		local function build_config()
			local colors = get_colors()

			local config = {
				options = {
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					-- "auto" derives the section palette from the active
					-- colorscheme, so it adapts when you switch schemes.
					theme = "auto",
					globalstatus = true,
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

			-- Left section
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
				color = { fg = colors.bg, bg = colors.accent, gui = "bold" },
				padding = { left = 1, right = 1 },
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
				symbols = { modified = "  ", readonly = "  ", unnamed = "  " },
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
				symbols = { error = " ", warn = " ", info = " ", hint = " " },
				diagnostics_color = {
					error = { fg = colors.red },
					warn = { fg = colors.yellow },
					info = { fg = colors.cyan },
					hint = { fg = colors.green },
				},
				colored = true,
				update_in_insert = false,
			})

			ins_left({
				function()
					local bufnr = vim.api.nvim_get_current_buf()
					local seg = lsp_cache[bufnr]
					if seg == nil then
						update_lsp_cache(bufnr)
						seg = lsp_cache[bufnr]
					end
					return seg or ""
				end,
				color = { fg = colors.fg, gui = "italic" },
				cond = conditions.hide_in_width,
			})

			-- Macro recording indicator
			ins_left({
				function()
					local reg = vim.fn.reg_recording()
					return reg ~= "" and ("  @" .. reg) or ""
				end,
				color = { fg = colors.red, gui = "bold" },
			})

			-- Search count
			ins_left({
				function()
					if vim.v.hlsearch == 0 then return "" end
					local ok, count = pcall(vim.fn.searchcount, { recompute = true, maxcount = 999 })
					if not ok or count.total == 0 then return "" end
					return string.format("  %d/%d", count.current, count.total)
				end,
				color = { fg = colors.cyan },
			})

			ins_left({
				function()
					return "%="
				end,
			})

			-- Right section
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
				symbols = { unix = " ", dos = " ", mac = " " },
				color = { fg = colors.green, gui = "bold" },
			})

			ins_right({
				"branch",
				icon = "",
				color = { fg = colors.violet, gui = "bold" },
			})

			ins_right({
				"diff",
				symbols = { added = " ", modified = " ", removed = " " },
				diff_color = {
					added = { fg = colors.green },
					modified = { fg = colors.orange },
					removed = { fg = colors.red },
				},
				cond = conditions.hide_in_width,
			})

			ins_right({
				"filetype",
				color = { fg = colors.accent, gui = "bold" },
				padding = { left = 1, right = 1 },
			})

			return config
		end

		require("lualine").setup(build_config())

		-- Re-derive component colors from the new scheme on every switch.
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("lualine_follow_colorscheme", { clear = true }),
			callback = function()
				require("lualine").setup(build_config())
			end,
		})
	end,
}
