return {
	-- LSP Completion Source
	{
		"hrsh7th/cmp-nvim-lsp",
		lazy = true, -- Load only when required
	},

	-- Snippet Engine & Predefined Snippets
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",     -- Luasnip integration for cmp
			"rafamadriz/friendly-snippets", -- Predefined snippets
		},
		event = "InsertEnter",            -- Load when entering insert mode
		config = function()
			local luasnip = require("luasnip")
			luasnip.config.setup({
				history = true,                            -- Allow navigating previous snippets
				updateevents = "TextChanged,TextChangedI", -- Real-time updates
				enable_autosnippets = true,                -- Auto-expand snippets
			})

			-- Load VS Code-style snippets lazily
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	-- Auto-completion Engine (nvim-cmp) with Improved UI & Documentation
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",        -- Load only when entering insert mode
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",     -- LSP completion
			"L3MON4D3/LuaSnip",         -- Snippet expansion
			"saadparwaiz1/cmp_luasnip", -- Snippet support
			"hrsh7th/cmp-path",         -- File path completion
			"hrsh7th/cmp-buffer",       -- Buffer completion
			"hrsh7th/cmp-calc",         -- Math calculations
			"onsails/lspkind.nvim",     -- Adds icons to completion menu
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body) -- Snippet expansion
					end,
				},

				-- Enhanced UI for Completion and Documentation Windows
				window = {
					completion = cmp.config.window.bordered(),    -- Border around completion popup
					documentation = cmp.config.window.bordered(), -- Border around docs popup
				},

				-- Key mappings for better navigation
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),           -- Scroll documentation up
					["<C-f>"] = cmp.mapping.scroll_docs(4),            -- Scroll documentation down
					["<C-Space>"] = cmp.mapping.complete(),            -- Trigger completion
					["<C-e>"] = cmp.mapping.abort(),                   -- Cancel completion
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm selection
					-- ["<Tab>"] = cmp.mapping(function(fallback)
					--   if cmp.visible() then
					--     cmp.select_next_item() -- Next completion item
					--   elseif luasnip.expand_or_jumpable() then
					--     luasnip.expand_or_jump() -- Expand snippet
					--   else
					--     fallback()
					--   end
					-- end, { "i", "s" }),
					--
					-- ["<S-Tab>"] = cmp.mapping(function(fallback)
					--   if cmp.visible() then
					--     cmp.select_prev_item() -- Previous completion item
					--   elseif luasnip.jumpable(-1) then
					--     luasnip.jump(-1) -- Move back in snippet
					--   else
					--     fallback()
					--   end
					-- end, { "i", "s" }),
				}),

				-- Completion Sources with Priorities
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },                  -- Highest priority (LSP suggestions)
					{ name = "luasnip",  priority = 750 },                   -- Snippet expansion
				}, {
					{ name = "path",   keyword_length = 2, priority = 500 }, -- File path completion
					{ name = "calc",   keyword_length = 2, priority = 300 }, -- Math expressions
					{ name = "buffer", keyword_length = 5, priority = 250 }, -- Lower priority for buffer words
				}),

				-- Add icons to completion menu (via lspkind)
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",  -- Show icons + text
						maxwidth = 50,         -- Limit width of completion menu
						ellipsis_char = "...", -- Show ellipsis when truncated
					}),
				},

				experimental = {
					ghost_text = false, -- Preview selected completion
				},
			})
		end,
	},
}
