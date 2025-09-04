return {
  "rbong/vim-flog",
  lazy = true,
  cmd = { "Flog", "Flogsplit", "Floggit" },
  dependencies = {
    "tpope/vim-fugitive",
  },
  init = function()
    vim.api.nvim_create_user_command("GitLog", "Flog", {})
		vim.keymap.set("n", "<leader>gl", ":Flog<CR>", { desc = "Git Log (Flog)" })
  end,
  config = function()
    vim.g.flog_default_format = "%h %s"
    vim.g.flog_default_date = "relative"
    vim.g.flog_default_sort = "date"
    vim.g.flog_git_commit_vertical_split = true

    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "floggraph",
      callback = function()
        vim.bo.buflisted = false
      end,
    })
  end,
}

