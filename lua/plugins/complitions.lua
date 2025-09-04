return {
	-- LSP Completion Source
	{ "hrsh7th/cmp-nvim-lsp", lazy = true },

	-- Snippet Engine & VSCode snippets
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets" },
		event = "InsertEnter",
		config = function()
			local luasnip = require("luasnip")
			luasnip.config.setup({
				history = true,
				updateevents = "TextChanged,TextChangedI",
				enable_autosnippets = true,
			})
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	-- nvim-cmp
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-calc",
			"onsails/lspkind.nvim",
			"hrsh7th/cmp-omni",          -- проектные импорты
			"Exafunction/codeium.nvim",  -- AI suggestions через Codeium
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			local codeium = require("codeium")

			-- Инициализация Codeium
			codeium.setup()

			cmp.setup({
				snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
				window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
					{ name = "path", keyword_length = 2, priority = 500 },
					{ name = "omni", keyword_length = 2, priority = 500 },  -- project-wide import/require completion
					{ name = "codeium", priority = 1200 },                  -- AI suggestions выше всех
				}, {
					{ name = "calc", keyword_length = 2, priority = 300 },
					{ name = "buffer", keyword_length = 5, priority = 250, max_item_count = 10, option = { get_bufnrs = function() return vim.api.nvim_list_bufs() end } },
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
				experimental = { ghost_text = false },
				completion = { completeopt = "menu,menuone,noselect" },
				performance = { debounce = 50, throttle = 10, max_view_entries = 20 },
			})
		end,
	},
}

