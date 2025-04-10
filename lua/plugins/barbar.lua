return {
  'romgrk/barbar.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',  -- Optional for file icons
    'lewis6991/gitsigns.nvim',      -- Optional for git status
  },
  config = function()
    -- Disable auto setup for custom configuration
    vim.g.barbar_auto_setup = false

    -- Ensure Gruvbox is loaded first
    vim.cmd.colorscheme("gruvbox")

    -- Custom Gruvbox-themed highlights
    vim.api.nvim_set_hl(0, "BufferCurrent",      { bg = "#504945", fg = "#ebdbb2", bold = true }) -- Active buffer
    vim.api.nvim_set_hl(0, "BufferCurrentMod",   { bg = "#504945", fg = "#fabd2f", bold = true }) -- Modified active buffer
    vim.api.nvim_set_hl(0, "BufferInactive",     { bg = "#3c3836", fg = "#928374" }) -- Inactive buffers
    vim.api.nvim_set_hl(0, "BufferInactiveMod",  { bg = "#3c3836", fg = "#d79921" }) -- Modified inactive buffer
    vim.api.nvim_set_hl(0, "BufferVisible",      { bg = "#282828", fg = "#ebdbb2" }) -- Visible but not focused buffer
    vim.api.nvim_set_hl(0, "BufferVisibleMod",   { bg = "#282828", fg = "#fabd2f" }) -- Visible modified buffer
    vim.api.nvim_set_hl(0, "BufferTabpages",     { bg = "#282828", fg = "#fe8019", bold = true }) -- Tab pages indicator

    -- Enable default behavior
    vim.cmd [[
      set showtabline=2
    ]]

    -- Optional: Setup file icons (using nvim-web-devicons)
    local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
    if devicons_ok then
      devicons.setup()
    end

    -- Optional: Setup git status indicators (using gitsigns)
    local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
    if gitsigns_ok then
      gitsigns.setup({
        signs = {
          add = { text = '│' },
          change = { text = '│' },
          delete = { text = '' },
        }
      })
    end

    -- Basic keybindings for buffer navigation
    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }

    map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
    map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)
    map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
    map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
    map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
    map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
    map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
    map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', opts)
    map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', opts)
    map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', opts)
    map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', opts)
    map('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)
    map('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)
    map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
  end
}

