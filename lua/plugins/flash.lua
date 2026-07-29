return {
	{
		-- Jump labels on search matches: type /foo, then press <Tab> to
		-- label every match and jump directly to it
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			search = {
				-- wrap around end of file
				wrap = true,
				-- multi-window search
				multi_window = false,
			},
			jump = {
				-- save location in jumplist so <C-o> works
				jumplist = true,
				-- restore cursor column after jump
				pos = "start",
			},
			label = {
				-- show labels after the match, not before
				after = true,
				before = false,
				-- uppercase labels for easier reading
				uppercase = false,
				-- rainbow colours for nested labels
				rainbow = { enabled = false },
			},
			modes = {
				-- Enhance / and ? with labels
				search = {
					enabled = true,
					-- press <Tab> while in search to show jump labels
					-- press <S-Tab> to go back
				},
				-- f/t/F/T jump with labels
				char = {
					enabled = false,
				},
			},
			-- don't create any default keymaps except what we define below
			keys = {},
		},
		keys = {
			-- Flash jump (like leap/hop)
			{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash jump" },
			{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash treesitter" },
			-- Remote flash: select target buffer text from anywhere
			{ "r",     mode = "o",                function() require("flash").remote() end,            desc = "Remote flash" },
			-- Toggle flash in active search
			{ "<C-s>", mode = { "c" },            function() require("flash").toggle() end,            desc = "Toggle flash search" },
		},
	},

	{
		-- Virtual text showing [current/total] next to cursor while searching
		"kevinhwang91/nvim-hlslens",
		event = "BufReadPost",
		config = function()
			require("hlslens").setup({
				calm_down = true,          -- clear lens when cursor moves away
				nearest_only = false,      -- show lens on all matches, not just nearest
				nearest_float_when = "never",
			})

			local map = vim.keymap.set
			local opts = { noremap = true, silent = true }

			-- Re-map n/N to keep the lens updated
			map("n", "n",
				[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
				opts)
			map("n", "N",
				[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
				opts)
			map("n", "*",  [[*<Cmd>lua require('hlslens').start()<CR>]],  opts)
			map("n", "#",  [[#<Cmd>lua require('hlslens').start()<CR>]],  opts)
			map("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
			map("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)

			-- Clear search highlight with Escape
			map("n", "<Esc>", "<Cmd>noh<CR><Esc>", opts)
		end,
	},
}