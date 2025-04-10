-- Function to get compile_commands.json directory
local function get_compile_commands_dir()
	local base_dir = vim.fn.getcwd() .. "/"
	local dirs = vim.fn.glob(base_dir .. "/*", 1, 1)

	if #dirs == 0 then
		return nil
	end

	for _, dir in ipairs(dirs) do
		local compile_commands = dir .. "/compile_commands.json"
		if vim.fn.filereadable(compile_commands) == 1 then
			return dir
		end
	end

	return nil
end

-- Fix indentation for Rust files (2 spaces)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
		vim.bo.expandtab = true
	end,
})

return {
	-- Rust Tools: Enhances Rust Analyzer with additional features
	{
		"simrat39/rust-tools.nvim",
		ft = "rust", -- Load only when editing Rust files
		config = function()
			local rt = require("rust-tools")
			rt.setup({
				server = {
					on_attach = function(_, bufnr)
						vim.keymap.set("n", "<Leader>h", rt.hover_actions.hover_actions, { buffer = bufnr })
						vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
					end,
				},
			})
		end,
	},

	-- Mason: Manages external tooling (LSPs, linters, formatters)
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason LSPconfig: Bridges Mason and nvim-lspconfig
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
				},
			})
		end,
	},

	-- nvim LSPconfig: Configures language servers
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "hrsh7th/cmp-nvim-lsp" }, -- Ensures LSP completion support
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			-- Custom LSP handlers for UI improvements
			vim.lsp.handlers["textDocument/hover"] =
					vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", focusable = false, max_width = 80 })

			vim.lsp.handlers["textDocument/signatureHelp"] =
					vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", focusable = false })

			-- Floating Diagnostics Instead of Inline Errors
			vim.diagnostic.config({
				virtual_text = true, -- Don't show inline text
				signs = true,
				underline = true,
				update_in_insert = false,
				float = {
					source = "always",
					border = "rounded",
				},
			})

			-- Global on_attach function to enable keymaps for all LSPs
			local on_attach = function(client, bufnr)
				local opts = { buffer = bufnr }

				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)                     -- Hover with borders
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)               -- Go to definition
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- Code actions
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)           -- Rename symbol
			end

			-- Lua Language Server
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Rust Analyzer (with rustfmt.toml settings for 2-space tabs)
			lspconfig.rust_analyzer.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						checkOnSave = { command = "clippy" },
						diagnostics = { enable = true },
						formatting = {
							command = "rustfmt",
							options = {
								tab_spaces = 2,
							},
						},
					},
				},
			})

			-- Clangd Configuration
			local compile_commands_dir = get_compile_commands_dir() or vim.fn.getcwd()

			lspconfig.clangd.setup({
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--background-index", -- Enables full indexing
					"--clang-tidy",
					"--completion-style=detailed",
					"--header-insertion=never",
					"--cross-file-rename",
					"--pch-storage=memory", -- Fixes precompiled headers issue
					"--compile-commands-dir=" .. compile_commands_dir,
					"--all-scopes-completion",
				},
				on_attach = on_attach,
			})

			-- Null-ls for additional formatting/linting
			require("null-ls").setup({
				sources = {}, -- Add sources as needed
				on_attach = on_attach,
			})

			-- CMake Language Server
			lspconfig.cmake.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Python Language Server (pylsp)
			lspconfig.pylsp.setup({
				capabilities = capabilities,
				settings = {
					pylsp = {
						plugins = {
							black = { enabled = true },
							autopep8 = { enabled = false },
							yapf = { enabled = false },
							pylint = { enabled = true, executable = "pylint" },
							pyflakes = { enabled = false },
							pygments = { enabled = false },
							pylsp_mypy = { enabled = true },
							jedi_completion = { fuzzy = true },
							pyls_isort = { enabled = true },
						},
					},
				},
				on_attach = on_attach,
			})

			-- Protobuf LSP
			lspconfig.pbls.setup({
				capabilities = capabilities,
				filetypes = { "proto" },
				on_attach = on_attach,
			})

			-- Go Language Server (gopls)
			lspconfig.gopls.setup({
				capabilities = capabilities,
				settings = {
					gopls = {
						analyses = { unusedparams = true, useany = true },
						staticcheck = true,
						completeUnimported = true, -- Auto-complete missing imports
						usePlaceholders = true,
					},
				},
				on_attach = on_attach,
			})

			-- Smarter "Go to Definition" using quickfix list
			local function go_to_definition()
				local params = vim.lsp.util.make_position_params()
				vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, ctx)
					if not result or vim.tbl_isempty(result) then
						print("No definition found")
						return
					end

					if vim.tbl_islist(result) then
						if #result > 1 then
							vim.fn.setqflist(
								{},
								" ",
								{ title = "LSP Definitions", items = vim.lsp.util.locations_to_items(result) }
							)
							vim.cmd("copen")                  -- Open quickfix list
						else
							vim.lsp.util.jump_to_location(result[1]) -- Single result: Jump directly
						end
					else
						vim.lsp.util.jump_to_location(result) -- Non-list result: Jump directly
					end
				end)
			end

			vim.keymap.set("n", "gd", go_to_definition, { buffer = bufnr }) -- Override default behavior
		end,
	},
}

