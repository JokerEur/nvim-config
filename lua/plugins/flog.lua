return {
	"rbong/vim-flog",
	lazy = true,
	cmd = { "Flog", "Flogsplit", "Floggit" },
	dependencies = {
		"tpope/vim-fugitive",
	},
	keys = {
		{ "<leader>gl", "<cmd>Flog -all<cr>", desc = "Git Log (all branches)" },
		{ "<leader>gL", "<cmd>Flog -path=%<cr>", desc = "Git Log (current file)" },
		{ "<leader>gb", "<cmd>Flog -all -max-count=100<cr>", desc = "Git Branches" },
	},
	config = function()
		-- Performance: limit initial load
		vim.g.flog_default_opts = {
			max_count = 500,
		}

		-- Informative format: hash, author, date, subject
		vim.g.flog_default_format = "[%h] %s %C(dim)(%ar by %an)%C(reset)"
		vim.g.flog_default_date = "short"

		-- Better display
		vim.g.flog_permanent_default_opts = {
			date = "short",
		}

		-- Flog buffer settings
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "floggraph",
			callback = function()
				local opts = { buffer = true, silent = true }

				-- Quick actions
				vim.keymap.set("n", "<CR>", "<Plug>(FlogVSplitCommitRight)", opts)
				vim.keymap.set("n", "o", "<Plug>(FlogSplitCommitPathsRight)", opts)
				vim.keymap.set("n", "<Tab>", "<Plug>(FlogVDiffSplitRight)", opts)

				-- Navigation
				vim.keymap.set("n", "]", "<Plug>(FlogSkipAhead)", opts)
				vim.keymap.set("n", "[", "<Plug>(FlogSkipBack)", opts)
				vim.keymap.set("n", "gg", "<Plug>(FlogJumpToNewest)", opts)
				vim.keymap.set("n", "G", "<Plug>(FlogJumpToOldest)", opts)

				-- Git operations
				vim.keymap.set("n", "co", "<Plug>(FlogCheckout)", opts)
				vim.keymap.set("n", "cb", "<Plug>(FlogCheckoutBranch)", opts)
				vim.keymap.set("n", "cp", "<Plug>(FlogCherryPick)", opts)
				vim.keymap.set("n", "rv", "<Plug>(FlogRevert)", opts)
				vim.keymap.set("n", "rb", "<Plug>(FlogRebaseInteractive)", opts)
				vim.keymap.set("n", "m", "<Plug>(FlogMerge)", opts)

				-- Marking for diff
				vim.keymap.set("n", "<Space>", "<Plug>(FlogSetCommitMark)", opts)
				vim.keymap.set("n", "dm", "<Plug>(FlogVDiffSplitMarked)", opts)

				-- View toggles
				vim.keymap.set("n", "a", "<Plug>(FlogToggleAll)", opts)
				vim.keymap.set("n", "gb", "<Plug>(FlogToggleBisect)", opts)
				vim.keymap.set("n", "gm", "<Plug>(FlogToggleMerges)", opts)
				vim.keymap.set("n", "gr", "<Plug>(FlogToggleReflog)", opts)
				vim.keymap.set("n", "gp", "<Plug>(FlogToggleGraph)", opts)
				vim.keymap.set("n", "gP", "<Plug>(FlogTogglePatch)", opts)

				-- Refresh
				vim.keymap.set("n", "R", "<Plug>(FlogUpdate)", opts)
				vim.keymap.set("n", "q", "<cmd>bdelete<cr>", opts)

				-- Telescope integration: search commits
				vim.keymap.set("n", "/", function()
					require("telescope.builtin").git_commits({
						layout_strategy = "vertical",
						layout_config = { width = 0.8, height = 0.9 },
					})
				end, { buffer = true, desc = "Search commits (Telescope)" })

				vim.keymap.set("n", "?", function()
					require("telescope.builtin").git_bcommits({
						layout_strategy = "vertical",
						layout_config = { width = 0.8, height = 0.9 },
					})
				end, { buffer = true, desc = "Search buffer commits" })

				-- Copy commit hash
				vim.keymap.set("n", "yy", function()
					local hash = vim.fn["flog#get_commit_data"]({}).short_commit_hash
					if hash then
						vim.fn.setreg("+", hash)
						vim.notify("Copied: " .. hash, vim.log.levels.INFO)
					end
				end, { buffer = true, desc = "Copy commit hash" })

				-- Buffer options
				vim.opt_local.number = false
				vim.opt_local.relativenumber = false
				vim.opt_local.signcolumn = "no"
				vim.opt_local.cursorline = true
			end,
		})

		-- Nice highlights
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = function()
				vim.api.nvim_set_hl(0, "flogBranch0", { fg = "#7aa2f7", bold = true })
				vim.api.nvim_set_hl(0, "flogBranch1", { fg = "#9ece6a", bold = true })
				vim.api.nvim_set_hl(0, "flogBranch2", { fg = "#e0af68", bold = true })
				vim.api.nvim_set_hl(0, "flogBranch3", { fg = "#bb9af7", bold = true })
				vim.api.nvim_set_hl(0, "flogBranch4", { fg = "#f7768e", bold = true })
				vim.api.nvim_set_hl(0, "flogBranch5", { fg = "#7dcfff", bold = true })
			end,
		})
	end,
}

