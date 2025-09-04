return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = "│" },
      change       = { text = "│" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
      untracked    = { text = "┆" },
    },
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 500,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000,
    preview_config = {
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    yadm = {
      enable = false,
    },
  },
  keys = {
    -- { "]c", function() require("gitsigns").next_hunk() end, desc = "Next Git hunk" },
    -- { "[c", function() require("gitsigns").prev_hunk() end, desc = "Previous Git hunk" },
    -- { "<leader>gq", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
    -- { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
    -- { "<leader>gS", function() require("gitsigns").stage_buffer() end, desc = "Stage buffer" },
    -- { "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo stage hunk" },
    -- { "<leader>gR", function() require("gitsigns").reset_buffer() end, desc = "Reset buffer" },
    -- { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
    -- { "<leader>gb", function() require("gitsigns").blame_line() end, desc = "Blame line" },
    -- { "<leader>gd", function() require("gitsigns").diffthis() end, desc = "Diff this" },
    -- { "<leader>gD", function() require("gitsigns").diffthis("~") end, desc = "Diff against last commit" },
    -- { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "Select hunk" },
  },
}

