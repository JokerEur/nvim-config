return {
  -- Enhanced snippet engine (optimized)
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    config = function()
      require("luasnip").config.setup({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        region_check_events = "InsertEnter",
        delete_check_events = "InsertLeave",
      })

      -- Load snippets efficiently
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = {
        vim.fn.stdpath("config") .. "/snippets",
      }})
    end,
  },

  -- Main completion engine with optimized performance
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "onsails/lspkind.nvim",
      "tzachar/cmp-tabnine",
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      local luasnip = require("luasnip")

      -- Precompute lspkind formatter for better performance
      local lspkind_format = lspkind.cmp_format({
        mode = "symbol_text",
        maxwidth = 40,
        ellipsis_char = "...",
        menu = {
          nvim_lsp = "LSP",
          cmp_tabnine = "AI",
          luasnip = "Snip",
          buffer = "Buf",
          path = "Path",
        },
      })

      -- Clean border style
      local border_opts = {
        border = "single",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel",
      }

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        window = {
          completion = {
            border = border_opts.border,
            winhighlight = border_opts.winhighlight,
            scrollbar = false,
            col_offset = -3,
            side_padding = 0,
          },
          documentation = {
            border = border_opts.border,
            winhighlight = border_opts.winhighlight,
            max_width = 60,
            max_height = 15,
          },
        },

        -- Smart mappings - FIXED: Added C-n/C-p mappings
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({
            select = true,
            behavior = cmp.ConfirmBehavior.Replace,
          }),
          -- Faster navigation in the completion menu
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          -- Scroll documentation without leaving insert mode
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        }),

        -- Prioritized sources with limits
        sources = {
          { name = "nvim_lsp", priority = 1000, max_item_count = 12 },
          { name = "cmp_tabnine", priority = 950, max_item_count = 3 },
          { name = "luasnip", priority = 750, max_item_count = 3 },
          { name = "path", priority = 500 },
          { 
            name = "buffer", 
            priority = 250,
            max_item_count = 5,
            option = {
              get_bufnrs = function()
                -- Only consider visible buffers
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end
            }
          },
        },

        -- Fast but simple formatting (no signature in menu)
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            return lspkind_format(entry, vim_item)
          end,
        },

        -- Performance optimizations
        performance = {
          debounce = 20,
          throttle = 40,
          max_view_entries = 12,
          fetching_timeout = 75,
        },

        -- Completion behavior - IMPORTANT: Remove autocomplete triggers
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
          keyword_length = 2,
          -- Default includes InsertEnter + TextChanged; InsertEnter can feel like a freeze in big projects
          -- (especially with AI sources). Keep auto-complete while typing only.
          autocomplete = {
            cmp.TriggerEvent.TextChanged,
          },
        },

        experimental = {
          native_menu = false,
        },

        view = {
          entries = {
            name = "custom",
            selection_order = "near_cursor",
          },
        },

        -- Disable completion in huge or special buffers to keep things snappy
        enabled = function()
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
          if ok and stats and stats.size and stats.size > 512 * 1024 then -- > 512KB
            return false
          end

          local ok_lines, line_count = pcall(vim.api.nvim_buf_line_count, 0)
          if ok_lines and line_count and line_count > 10000 then
            return false
          end

          local buftype = vim.api.nvim_buf_get_option(0, "buftype")
          if buftype == "prompt" then
            return false
          end

          return true
        end,
      })

      -- Filetype-specific settings
      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "buffer" },
        })
      })

      cmp.setup.filetype("markdown", {
        sources = cmp.config.sources({
          { name = "path" },
          { name = "buffer" },
        })
      })

      -- Global optimizations
      vim.o.completeopt = "menu,menuone,noselect,noinsert"
      vim.o.pumheight = 10
      vim.o.pumblend = 0  -- Disable transparency for speed
      vim.o.updatetime = 100  -- Faster completion triggers
      
      -- Disable Neovim's native completion menu style
      vim.cmd([[
        augroup CmpStyles
          autocmd!
          autocmd VimEnter * set completeopt=menu,menuone,noselect,noinsert
          autocmd FileType * set completeopt=menu,menuone,noselect,noinsert
        augroup END
      ]])

      -- Make completion source/signature column less prominent than main text
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- `CmpItemMenu` is used for the right-hand column (e.g. "LSP · fn(K, V)")
          vim.api.nvim_set_hl(0, "CmpItemMenu", { link = "Comment" })
        end,
      })

      -- Apply highlight immediately on startup
      vim.schedule(function()
        vim.api.nvim_set_hl(0, "CmpItemMenu", { link = "Comment" })
      end)
    end,
  },
}
