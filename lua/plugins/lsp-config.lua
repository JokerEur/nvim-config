-- ===============================
-- Universal project root detection
-- ===============================
local function get_project_root(fname)
	fname = fname or vim.api.nvim_buf_get_name(0)
	local dir = vim.fn.fnamemodify(fname, ":p:h")

	local root_markers = {
		".git",
		"package.json",
		"pyproject.toml",
		"setup.py",
		"requirements.txt",
		"go.mod",
		"Cargo.toml",
		"compile_commands.json",
		"Makefile",
		"build.gradle",
		"pom.xml",
		"mix.exs",
		"Gemfile",
	}

	local function is_root(d)
		for _, marker in ipairs(root_markers) do
			if vim.fn.globpath(d, marker) ~= "" then
				return true
			end
		end
		return false
	end

	while dir ~= "/" do
		if is_root(dir) then
			return dir
		end
		dir = vim.fn.fnamemodify(dir, ":h")
	end

	if vim.fn.isdirectory(vim.fn.fnamemodify(fname, ":p:h")) == 1 then
		return vim.fn.fnamemodify(fname, ":p:h")
	end

	return vim.fn.getcwd()
end

-- ===============================
-- Capabilities
-- ===============================
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- ===============================
-- Floating highlights
-- ===============================
local function set_float_hl()
	-- Slightly darker than Gruvbox Dark background
	local bg_color = "#1B1B1B"

	-- Gruvbox standard foregrounds
	local fg_default = "#EBDBB2" -- default text
	local fg_blue = "#83A598" -- for FloatBorder accent
	local fg_yellow = "#FABD2F" -- for focused border / highlights

	-- Floating window background and text
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = bg_color, fg = fg_default })

	-- Borders
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = fg_blue, bg = bg_color, bold = true })
	vim.api.nvim_set_hl(0, "LspFloatBorderFocused", { fg = fg_yellow, bg = bg_color, bold = true })
end
set_float_hl()
vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = set_float_hl })

-- ===============================
-- Fade-in effect
-- ===============================
local fade_steps, fade_delay = 5, 10
local function fade_in(winnr)
	for i = 0, fade_steps do
		vim.defer_fn(function()
			if vim.api.nvim_win_is_valid(winnr) then
				vim.api.nvim_win_set_option(winnr, "winblend", math.floor(100 - (i / fade_steps) * 100))
			end
		end, i * fade_delay)
	end
end

-- ===============================
-- Floating preview
-- ===============================
local function float_preview(contents, filetype, opts)
	opts = opts or {}
	opts.border = opts.border or "rounded"
	local bufnr, winnr = vim.lsp.util.open_floating_preview(contents, filetype, opts)
	if winnr and vim.api.nvim_win_is_valid(winnr) then
		vim.api.nvim_win_set_option(winnr, "winhl", "Normal:NormalFloat,FloatBorder:FloatBorder")
		vim.api.nvim_win_set_option(winnr, "winblend", 0)
		fade_in(winnr)
	end
	return bufnr, winnr
end

-- ===============================
-- Hover & signature caches
-- ===============================
local hover_cache = {}
local signature_cache = {}

local function hover_with_cache()
	local pos = vim.api.nvim_win_get_cursor(0)
	local key = vim.fn.expand("%:p") .. ":" .. pos[1] .. ":" .. pos[2]
	if hover_cache[key] then
		float_preview(hover_cache[key], "markdown", { max_width = 80 })
		return
	end
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return
	end
	local encoding = clients[1].offset_encoding or "utf-16"
	local params = vim.lsp.util.make_position_params(nil, encoding)
	vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result)
		if err or not result or not result.contents then
			return
		end
		local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
		lines = vim.tbl_filter(function(l)
			return l and l ~= ""
		end, lines)
		if vim.tbl_isempty(lines) then
			return
		end
		hover_cache[key] = lines
		vim.schedule(function()
			float_preview(lines, "markdown", { max_width = 80 })
		end)
	end)
end

local function signature_with_cache()
	local pos = vim.api.nvim_win_get_cursor(0)
	local key = vim.fn.expand("%:p") .. ":" .. pos[1] .. ":" .. pos[2]
	if signature_cache[key] then
		float_preview(signature_cache[key], "markdown", { max_width = 80 })
		return
	end
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return
	end
	local encoding = clients[1].offset_encoding or "utf-16"
	local params = vim.lsp.util.make_position_params(nil, encoding)
	vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(err, result)
		if err or not result or not result.signatures then
			return
		end
		local lines = vim.lsp.util.convert_signature_help_to_markdown_lines(result)
		lines = vim.tbl_filter(function(l)
			return l and l ~= ""
		end, lines)
		if vim.tbl_isempty(lines) then
			return
		end
		signature_cache[key] = lines
		vim.schedule(function()
			float_preview(lines, "markdown", { max_width = 80 })
		end)
	end)
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	pattern = "*",
	callback = function()
		local file = vim.fn.expand("%:p")
		for k in pairs(hover_cache) do
			if k:match("^" .. file) then
				hover_cache[k] = nil
			end
		end
		for k in pairs(signature_cache) do
			if k:match("^" .. file) then
				signature_cache[k] = nil
			end
		end
	end,
})

local function normalize_offset_encoding(client)
	if client.offset_encoding ~= "utf-16" then
		client.offset_encoding = "utf-16"
	end
end

local function on_attach(client, bufnr)
	normalize_offset_encoding(client)
	if client.name == "tsserver" or client.name == "volar" or client.name == "ts_ls" or client.name == "vue_ls" then
		client.server_capabilities.documentFormattingProvider = false
	end

	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	map("K", hover_with_cache, "Hover Documentation (cached)")
	map("<C-k>", signature_with_cache, "Signature Help (cached)")

	local orig_open_float = vim.diagnostic.open_float
	vim.diagnostic.open_float = function(...)
		local bufnr, winnr = orig_open_float(...)
		if winnr and vim.api.nvim_win_is_valid(winnr) then
			fade_in(winnr)
		end
		return bufnr, winnr
	end

	vim.diagnostic.config({
		virtual_text = true,
		signs = true,
		underline = true,
		update_in_insert = false,
		float = { border = "rounded", source = "always", focusable = false },
	})

	map("<leader>ca", vim.lsp.buf.code_action, "Code Actions")
	map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
	map("<leader>gl", vim.diagnostic.open_float, "Show Diagnostics")
	map("<leader>gn", vim.diagnostic.goto_next, "Next Diagnostic")
	map("<leader>gp", vim.diagnostic.goto_prev, "Previous Diagnostic")
	map("gd", vim.lsp.buf.definition, "Go to Definition")
	map("gD", vim.lsp.buf.declaration, "Go to Declaration")
	map("gr", vim.lsp.buf.references, "References")
	map("gi", vim.lsp.buf.implementation, "Implementation")
	map("<leader>gf", function()
		vim.lsp.buf.format({ async = true })
	end, "Format Buffer")
end

-- ===============================
-- Plugin configurations
-- ===============================
return {
	-- Rust tools
	{
		"simrat39/rust-tools.nvim",
		ft = "rust",
		config = function()
			require("rust-tools").setup({
				server = { on_attach = on_attach, capabilities = capabilities, root_dir = get_project_root },
			})
		end,
	},

	-- Mason
	{ "williamboman/mason.nvim", cmd = "Mason", config = true },

	-- Mason LSP
	{
		"williamboman/mason-lspconfig.nvim",
		event = "BufReadPre",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"clangd",
					"cmake",
					"pylsp",
					"gopls",
					"pbls",
					"intelephense",
					"ts_ls",
					"vue_ls",
					"html",
					"cssls",
				},
			})
		end,
	},

	-- LSP Config
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local lspconfig = require("lspconfig")
			local vue_typescript_plugin_path = vim.fn.stdpath("data")
				.. "/mason/packages/vue-language-server/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin"

			lspconfig.ts_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = get_project_root,
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = vue_typescript_plugin_path,
							languages = { "vue" },
						},
					},
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
				single_file_support = false,
			})

			lspconfig.vue_ls.setup({ on_attach = on_attach, capabilities = capabilities, root_dir = get_project_root })

			lspconfig.html.setup({ on_attach = on_attach, capabilities = capabilities, root_dir = get_project_root })
			lspconfig.cssls.setup({ on_attach = on_attach, capabilities = capabilities, root_dir = get_project_root })
			lspconfig.intelephense.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = get_project_root,
			})
			lspconfig.lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = get_project_root,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true) },
					},
				},
			})
			lspconfig.clangd.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				cmd = { "clangd", "--compile-commands-dir=" .. get_project_root() },
				root_dir = get_project_root,
			})
			lspconfig.pylsp.setup({ on_attach = on_attach, capabilities = capabilities, root_dir = get_project_root })
			lspconfig.gopls.setup({ on_attach = on_attach, capabilities = capabilities, root_dir = get_project_root })
			lspconfig.pbls.setup({ on_attach = on_attach, capabilities = capabilities, root_dir = get_project_root })
			lspconfig.cmake.setup({ on_attach = on_attach, capabilities = capabilities, root_dir = get_project_root })
			lspconfig.rust_analyzer.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = get_project_root,
			})
		end,
	},

	-- null-ls
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "williamboman/mason.nvim", "jay-babu/mason-null-ls.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local null_ls = require("null-ls")
			local mason_null_ls = require("mason-null-ls")
			local tools = {
				"stylua",
				"black",
				"isort",
				"clang_format",
				"gofmt",
				"goimports",
				"ruff",
				"eslint_d",
				"prettier",
				"jsonlint",
			}
			local sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.isort,
				null_ls.builtins.formatting.clang_format,
				null_ls.builtins.formatting.gofmt,
				null_ls.builtins.formatting.goimports,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.diagnostics.eslint_d,
			}
			null_ls.setup({ sources = sources, on_attach = on_attach, diagnostics_format = "[null-ls] #{m} (#{s})" })
			mason_null_ls.setup({ ensure_installed = tools, automatic_installation = true })
		end,
	},
}
