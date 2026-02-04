return {
  'romgrk/barbar.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'lewis6991/gitsigns.nvim',
  },
  init = function()
    -- Prevent barbar from doing its own auto-setup (we configure it manually)
    vim.g.barbar_auto_setup = false
    -- Set background early to prevent flash
    vim.opt.background = "dark"
  end,
  config = function()
    -- Enable tabline
    vim.opt.showtabline = 2

    -- Configure Barbar
    require('barbar').setup({
      -- Performance-oriented behavior
      animation = false,             -- disable tab animations for faster redraws
      auto_hide = false,             -- always show tabline so buffers are visible
      tabpages = false,              -- skip tabpage indicator to reduce clutter
      clickable = true,

      -- Show inactive buffers so multiple tabs are visible
      hide = {
        inactive = false,
      },
      -- Icons and styling
      icons = {
        buffer_index = false,
        buffer_number = true,        -- show :bnumber for quick jumps
        button = '',
        inactive = { separator = { left = '▎', right = '' } },
        current = { separator = { left = '▎', right = '' } },
        pinned = { button = '車', filename = true, separator = { right = '' } },

        -- Diagnostics per buffer (more informative for dev work)
        diagnostics = {
          [vim.diagnostic.severity.ERROR] = { enabled = true,  icon = ' ' },
          [vim.diagnostic.severity.WARN]  = { enabled = true,  icon = ' ' },
          [vim.diagnostic.severity.INFO]  = { enabled = false },
          [vim.diagnostic.severity.HINT]  = { enabled = false },
        },

        -- Pretty separators
        separator = { left = '▎', right = '' },
        modified = { button = '●' },

        -- Filetype icons
        filetype = {
          enabled = true,
          custom_colors = false,
        },

        -- Git status indicators
        gitsigns = {
          added = { enabled = true,  icon = '+' },
          changed = { enabled = true,  icon = '~' },
          deleted = { enabled = true,  icon = '-' },
        },
      },

      -- Visual styling
      highlight_visible = true,
      highlight_inactive_file_icons = false,

      -- Sidebar integration
      sidebar_filetypes = {
        NvimTree = true,
        outline = true,
      },

      -- Length & padding
      maximum_length = 30,
      minimum_padding = 1,
      maximum_padding = 3,

      -- Label for unnamed buffers (more informative than just "[No Name]")
      no_name_title = "[Scratch]",
    })

    -- Enhanced keybindings with better ergonomics
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Buffer navigation
    map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
    map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)
    
    -- Quick buffer switching (Alt+Number)
    for i = 1, 9 do
      map('n', '<A-'..i..'>', '<Cmd>BufferGoto '..i..'<CR>', opts)
    end
    map('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)

    -- Buffer management
    map('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)
    map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
    map('n', '<A-x>', '<Cmd>BufferClose!<CR>', opts) -- Force close
    
    -- Buffer ordering
    map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
    map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)

    -- Pick buffers visually
    map('n', '<A-b>', '<Cmd>BufferPick<CR>', opts)

    -- Close all but current/pinned
    map('n', '<A-C-a>', '<Cmd>BufferCloseAllButCurrentOrPinned<CR>', opts)
  end,
  
  -- Lazy loading optimization: only load barbar when we actually enter a buffer
  event = { "BufReadPre", "BufNewFile" },
}
