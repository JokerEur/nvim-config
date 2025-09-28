return {
	"luxvim/nvim-luxterm",
	config = function()
		require("luxterm").setup({
			manager_width = 0.8, -- 80% of screen width
			manager_height = 0.8, -- 80% of screen height

			preview_enabled = true,

			focus_on_create = false,

			auto_hide = true,

			keymaps = {
				toggle_manager = "<C-/>", -- Toggle session manager
				next_session = "<C-k>", -- Next session keybinding
				prev_session = "<C-j>", -- Previous session keybinding
				global_session_nav = false, -- Enable global session navigation
			},
		})
	end,
}
