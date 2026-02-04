return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function(_, opts)
    -- Custom highlight groups for better visibility
    local function set_highlights()
      -- Sign column colors
      vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#98c379", bold = true })
      vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e5c07b", bold = true })
      vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#e06c75", bold = true })
      vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = "#7c8f8f" })

      -- Line number colors (when numhl is enabled)
      vim.api.nvim_set_hl(0, "GitSignsAddNr", { fg = "#98c379" })
      vim.api.nvim_set_hl(0, "GitSignsChangeNr", { fg = "#e5c07b" })
      vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { fg = "#e06c75" })

      -- Staged signs (slightly dimmer)
      vim.api.nvim_set_hl(0, "GitSignsStagedAdd", { fg = "#6a9955" })
      vim.api.nvim_set_hl(0, "GitSignsStagedChange", { fg = "#b8993e" })
      vim.api.nvim_set_hl(0, "GitSignsStagedDelete", { fg = "#b05561" })

      -- Blame virtual text
      vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#5c6370", italic = true })
    end

    set_highlights()

    -- Reapply highlights when colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = set_highlights,
    })

    require("gitsigns").setup(opts)
  end,
  opts = {
    signs = {
      add          = { text = "│" },
      change       = { text = "│" },
      delete       = { text = "󰍵" },
      topdelete    = { text = "󰍴" },
      changedelete = { text = "󰏫" },
      untracked    = { text = "┆" },
    },
    signs_staged = {
      add          = { text = "┃" },
      change       = { text = "┃" },
      delete       = { text = "󰍵" },
      topdelete    = { text = "󰍴" },
      changedelete = { text = "󰏫" },
    },
    signcolumn = true,
    numhl      = true,  -- Highlight line numbers for changed lines
    linehl     = false,
    word_diff  = false,
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with <leader>tb
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 300,
      ignore_whitespace = false,
      virt_text_priority = 100,
    },
    current_line_blame_formatter = "  <author> • <author_time:%R> • <summary>",
    current_line_blame_formatter_nc = "  Not Committed Yet",
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
    max_file_length = 20000,
    preview_config = {
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    -- Buffer-local keymaps for common Git workflows.
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Navigation (works in diff mode too)
      vim.keymap.set("n", "]h", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.nav_hunk("next") end)
        return "<Ignore>"
      end, { buffer = bufnr, expr = true, desc = "Next git hunk" })
      vim.keymap.set("n", "[h", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.nav_hunk("prev") end)
        return "<Ignore>"
      end, { buffer = bufnr, expr = true, desc = "Previous git hunk" })

      -- Actions
      map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
      map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
      map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
      map("n", "<leader>hp", gs.preview_hunk_inline, "Preview hunk inline")
      map("n", "<leader>hP", gs.preview_hunk, "Preview hunk popup")
      map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, "Blame line (full)")
      map("n", "<leader>hB", function()
        gs.blame()
      end, "Blame buffer")
      map("n", "<leader>hd", gs.diffthis, "Diff this")
      map("n", "<leader>hD", function()
        gs.diffthis("~")
      end, "Diff against last commit")

      -- Toggles
      map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
      map("n", "<leader>td", gs.toggle_deleted, "Toggle deleted lines")
      map("n", "<leader>tw", gs.toggle_word_diff, "Toggle word diff")
      map("n", "<leader>tl", gs.toggle_linehl, "Toggle line highlight")

      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
    end,
  },
}

