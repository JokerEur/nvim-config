return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" }, -- Lazy load only when opening a file
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Install only the necessary parsers for performance
        ensure_installed = {
          "lua", "rust", "cpp", "go", "gomod", "gosum", "gowork",
          "toml", "python", "cmake", "proto"
        },
        auto_install = false,  -- Avoid unexpected installations
        sync_install = false,  -- Non-blocking installation

        -- Enable syntax highlighting
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false, -- Disable regex for better performance

          -- Disable for large files to prevent lag
          disable = function(lang, buf)
            local max_filesize = 256 * 1024 -- 256 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            return ok and stats and stats.size > max_filesize
          end,
        },

        -- Enable smart indentation
        indent = { enable = true },

        -- Enable rainbow parentheses for better readability
        rainbow = {
          enable = true,
          extended_mode = true, -- Highlight other delimiters like HTML tags
          max_file_lines = 1000, -- Disable in very large files for performance
        },
      })
    end,
  },
}

