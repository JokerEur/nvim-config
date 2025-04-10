return {
	"nvimtools/none-ls.nvim",
	dependencies = { "williamboman/mason.nvim", "jay-babu/mason-null-ls.nvim" },
	config = function()
		local null_ls = require("null-ls")
		require("mason-null-ls").setup({
			ensure_installed = { "stylua", "black", "isort", "clang_format", "gofmt", "goimports", "ruff" },
			automatic_setup = true,
		})

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.isort,
				null_ls.builtins.formatting.clang_format,
				null_ls.builtins.formatting.goimports,
				null_ls.builtins.formatting.gofmt,
				-- null_ls.builtins.diagnostics.ruff, -- Faster than pylint
			},
		})

		-- Keymaps for diagnostics and formatting
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format Code" })
		vim.keymap.set("n", "<leader>gn", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
		vim.keymap.set("n", "<leader>gp", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
		vim.keymap.set("n", "<leader>gl", vim.diagnostic.open_float, { desc = "Show Diagnostic" })
	end,
}
