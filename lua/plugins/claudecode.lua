return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      focus_after_send = true,
      terminal = {
        split_side = "left",
        split_width_percentage = 0.35,
        auto_close = false,
        provider = "snacks",
      },
      diff_opts = {
        open_in_new_tab = true,
        keep_terminal_focus = false,
      },
    },
    config = function(_, opts)
      require("claudecode").setup(opts)

      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*claude*",
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = "no"
          vim.opt_local.statuscolumn = ""

          -- Close Claude terminal
          vim.keymap.set("t", "<C-q>", "<C-\\><C-n><cmd>close<cr>", { buffer = buf, desc = "Close Claude" })
          -- Exit to normal mode without closing (to scroll/copy output)
          vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = buf, desc = "Exit terminal mode" })
        end,
      })
    end,
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeSend",
      "ClaudeCodeAdd",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
    keys = {
      { "<leader>a",  nil,                            desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>",          desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",     desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },

      -- Context: add files
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      {
        "<leader>aB",
        function()
          local added = 0
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
              local name = vim.api.nvim_buf_get_name(buf)
              if name ~= "" and vim.fn.filereadable(name) == 1 then
                vim.cmd("ClaudeCodeAdd " .. vim.fn.fnameescape(name))
                added = added + 1
              end
            end
          end
          vim.notify(string.format("Added %d buffers to Claude", added), vim.log.levels.INFO)
        end,
        desc = "Add all open buffers",
      },
      {
        "<leader>ag",
        function()
          local diff = vim.fn.system("git diff HEAD")
          if diff == "" then diff = vim.fn.system("git diff --cached") end
          if diff == "" then
            vim.notify("No git diff found", vim.log.levels.WARN)
            return
          end
          local tmp = vim.fn.tempname() .. ".diff"
          vim.fn.writefile(vim.split(diff, "\n"), tmp)
          vim.cmd("ClaudeCodeAdd " .. tmp)
          vim.notify("Git diff added to Claude context", vim.log.levels.INFO)
        end,
        desc = "Add git diff to Claude",
      },

      -- Send selection
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },

      -- Diff review
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
  },
}
