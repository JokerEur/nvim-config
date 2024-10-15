return {
	{
		'simrat39/rust-tools.nvim',
		config = function()
			local rt = require("rust-tools")

			rt.setup({
				server = {
					on_attach = function(_, bufnr)
						-- Hover actions
						vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
						-- Code action groups
						vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
					end,
				}, }) end
	},
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "cmake", "pylsp", "gopls", "pbls" }
			})
		end
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require('cmp_nvim_lsp')

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				capabilities
			})
			lspconfig.rust_analyzer.setup({
				capabilities
			})
			lspconfig.clangd.setup({
				capabilities
			})
			lspconfig.cmake.setup({
				capabilities
			})
			lspconfig.pylsp.setup({
				capabilities
			})
			lspconfig.pbls.setup({
				capabilities
			})
			lspconfig.gopls.setup({
				capabilities,
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
							useany = true,
						},
						staticcheck = true,
					},
				},
			})

			vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
			vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})
		end
	},
}
