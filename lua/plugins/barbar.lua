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
        buffer_number = false,       -- hide buffer index/number
        button = false,              -- hide the close (x) button
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
        ["neo-tree"] = { event = "BufWipeout" },
        outline = true,
      },

      -- Length & padding
      maximum_length = 30,
      minimum_padding = 1,
      maximum_padding = 3,

      -- Label for unnamed buffers (more informative than just "[No Name]")
      no_name_title = "[Scratch]",
    })

    -- =====================================================================
    -- Follow the active colorscheme.
    --
    -- barbar derives its tabline colors from highlight groups, but schemes
    -- like moonfly ship no barbar-specific groups, so the tabline ends up
    -- mismatched. We derive a consistent set from standard groups (Normal,
    -- Comment, Function, …) that every scheme defines and re-apply it on
    -- every ColorScheme (loading a scheme wipes custom highlights first).
    -- =====================================================================
    local function hl(name, attr)
      local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
      if not ok or not h then return nil end
      local v = h[attr]
      if type(v) ~= "number" then return nil end
      return string.format("#%06x", v)
    end

    local function pick(attr, groups, fallback)
      for _, g in ipairs(groups) do
        local c = hl(g, attr)
        if c then return c end
      end
      return fallback
    end

    local function apply_barbar_highlights()
      local fg      = pick("fg", { "Normal" }, "#DCD7BA")
      local bg      = pick("bg", { "Normal" }, "#1F1F28")
      local dim     = pick("fg", { "Comment", "NonText" }, "#727169")
      local fill_bg = pick("bg", { "TabLineFill", "StatusLineNC", "CursorLine" }, bg)
      local inact_bg = pick("bg", { "TabLine", "CursorLine" }, fill_bg)
      local accent  = pick("fg", { "Function" }, "#7E9CD8")
      local mod     = pick("fg", { "DiagnosticWarn", "WarningMsg" }, "#E6C384")
      local err     = pick("fg", { "DiagnosticError", "ErrorMsg" }, "#E46876")
      local git_add = pick("fg", { "GitSignsAdd", "diffAdded", "Added" }, "#76946A")
      local git_chg = pick("fg", { "GitSignsChange", "diffChanged", "Changed" }, "#DCA561")
      local git_del = pick("fg", { "GitSignsDelete", "diffRemoved", "Removed" }, "#C34043")

      local function set(group, spec)
        vim.api.nvim_set_hl(0, group, spec)
      end

      -- Filler / offset
      set("BufferTabpageFill", { fg = dim, bg = fill_bg })
      set("BufferOffset", { fg = dim, bg = fill_bg })

      -- Current buffer
      set("BufferCurrent", { fg = fg, bg = bg, bold = true })
      set("BufferCurrentIndex", { fg = accent, bg = bg })
      set("BufferCurrentNumber", { fg = accent, bg = bg })
      set("BufferCurrentMod", { fg = mod, bg = bg, bold = true })
      set("BufferCurrentSign", { fg = accent, bg = bg })
      set("BufferCurrentTarget", { fg = err, bg = bg, bold = true })
      set("BufferCurrentERROR", { fg = err, bg = bg })
      set("BufferCurrentWARN", { fg = mod, bg = bg })
      set("BufferCurrentADDED", { fg = git_add, bg = bg })
      set("BufferCurrentCHANGED", { fg = git_chg, bg = bg })
      set("BufferCurrentDELETED", { fg = git_del, bg = bg })

      -- Visible (open in another window, not focused)
      set("BufferVisible", { fg = fg, bg = inact_bg })
      set("BufferVisibleIndex", { fg = fg, bg = inact_bg })
      set("BufferVisibleNumber", { fg = fg, bg = inact_bg })
      set("BufferVisibleMod", { fg = mod, bg = inact_bg })
      set("BufferVisibleSign", { fg = dim, bg = inact_bg })
      set("BufferVisibleTarget", { fg = err, bg = inact_bg, bold = true })
      set("BufferVisibleADDED", { fg = git_add, bg = inact_bg })
      set("BufferVisibleCHANGED", { fg = git_chg, bg = inact_bg })
      set("BufferVisibleDELETED", { fg = git_del, bg = inact_bg })

      -- Inactive buffers
      set("BufferInactive", { fg = dim, bg = inact_bg })
      set("BufferInactiveIndex", { fg = dim, bg = inact_bg })
      set("BufferInactiveNumber", { fg = dim, bg = inact_bg })
      set("BufferInactiveMod", { fg = mod, bg = inact_bg })
      set("BufferInactiveSign", { fg = dim, bg = inact_bg })
      set("BufferInactiveTarget", { fg = err, bg = inact_bg, bold = true })
      set("BufferInactiveADDED", { fg = git_add, bg = inact_bg })
      set("BufferInactiveCHANGED", { fg = git_chg, bg = inact_bg })
      set("BufferInactiveDELETED", { fg = git_del, bg = inact_bg })

      -- Re-generate the per-filetype icon highlight groups. barbar derives each
      -- icon group's background from Buffer{Current,Visible,Inactive} and caches
      -- it once (guarded by hlexists), so after we change those backgrounds above
      -- the icon groups keep their stale bg -- showing a bright mismatched square
      -- around the file icon. set_highlights() drops barbar's hl cache and
      -- rebuilds the icon groups with the backgrounds we just set.
      local ok_icons, barbar_icons = pcall(require, "barbar.icons")
      if ok_icons then
        barbar_icons.set_highlights()
      end
    end

    -- Schedule so our groups land AFTER the scheme's own barbar highlights and
    -- barbar's internal per-render setup (both run synchronously during the
    -- ColorScheme event); otherwise the active-buffer groups get reverted.
    local function schedule_barbar_highlights()
      vim.schedule(apply_barbar_highlights)
    end

    schedule_barbar_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("barbar_follow_colorscheme", { clear = true }),
      callback = schedule_barbar_highlights,
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
