return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({
      check_ts = true,           -- use treesitter to avoid pairing inside strings/comments
      ts_config = {
        lua  = { "string" },
        javascript = { "template_string" },
      },
      fast_wrap = {
        map            = "<M-e>",  -- Alt+e wraps the next word in a pair
        chars          = { "{", "[", "(", '"', "'" },
        pattern        = [=[[%'%"%>%]%)%}%,]]=],
        end_key        = "$",
        before_key     = "p",
        after_key      = "n",
        cursor_pos_before = true,
        keys           = "qwertyuiopzxcvbnmasdfghjkl",
        manual_position = true,
        highlight      = "Search",
        highlight_grey = "Comment",
      },
      disable_filetype = { "TelescopePrompt", "vim" },
    })

    -- Connect autopairs to cmp: insert pair on <CR> confirm
    local ok, cmp = pcall(require, "cmp")
    if ok then
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end,
}
