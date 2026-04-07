return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    { "<leader>gg", function() Snacks.lazygit() end,                          desc = "Lazygit" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end,                 desc = "Lazygit file log" },
    { "<leader>gl", function() Snacks.lazygit.log() end,                      desc = "Lazygit log" },
    { "<leader>gB", function() Snacks.gitbrowse() end,                        desc = "Open in browser (git)" },
    { "<leader>uz", function() Snacks.zen() end,                              desc = "Toggle zen mode" },
    { "<leader>uZ", function() Snacks.zen.zoom() end,                         desc = "Toggle zoom" },
  },
  opts = {
    -- Disable snacks notifier so fidget.nvim handles all vim.notify calls
    notifier = { enabled = false },

    -- Auto-disable heavy features on large files
    bigfile = { enabled = true },

    -- Smooth scrolling
    scroll = { enabled = true },

    -- Lazygit integration
    lazygit = { enabled = true },

    -- Open file in browser (GitHub / GitLab / Bitbucket)
    gitbrowse = { enabled = true },

    -- Focus / zen mode
    zen = {
      enabled = true,
      toggles = { diagnostics = false },
      show = { statusline = false, tabline = false },
    },

    -- Dim code outside of current scope
    dim = { enabled = true },

    -- Startup dashboard
    dashboard = {
      enabled = true,
      preset = {
        header = [[
  ██╗  ██╗ █████╗ ███╗   ██╗ █████╗  ██████╗  █████╗ ██╗    ██╗ █████╗
  ██║ ██╔╝██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔══██╗██║    ██║██╔══██╗
  █████╔╝ ███████║██╔██╗ ██║███████║██║  ███╗███████║██║ █╗ ██║███████║
  ██╔═██╗ ██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══██║██║███╗██║██╔══██║
  ██║  ██╗██║  ██║██║ ╚████║██║  ██║╚██████╔╝██║  ██║╚███╔███╔╝██║  ██║
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝]],
        keys = {
          { icon = " ", key = "f", desc = "Find File",    action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "g", desc = "Live Grep",    action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config",       action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = "󰒲 ", key = "L", desc = "Lazy",        action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit",         action = ":qa" },
        },
      },
    },
  },
}
