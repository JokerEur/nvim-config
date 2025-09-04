return {
  "LuxVim/nvim-luxmotion",
  event = "VeryLazy",
  config = function()
    require("luxmotion").setup({
      cursor = {
        enabled = true,
        duration = 180,        -- faster, feels snappy
        easing = "ease-out",   -- smooth slowdown
      },
      scroll = {
        enabled = true,
        duration = 250,        -- balanced: not too fast, not too floaty
        easing = "ease-out",   -- natural feeling
        hide_cursor = true,
      },
      performance = {
        enabled = true,
        debounce = 10,         -- throttle updates (lower = smoother, higher = lighter)
      },
    })
  end,
}
