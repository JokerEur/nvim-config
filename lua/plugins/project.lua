return {
  "ahmedkhalf/project.nvim",
  event = "BufReadPre",
  config = function()
    require("project_nvim").setup({
      detection_methods = { "lsp", "pattern" },

      patterns = {
        -- Git / generic
        ".git", ".hg", ".svn",

        -- Node / Web
        "package.json", "tsconfig.json", "vite.config.*", "nuxt.config.*",

        -- Python
        "pyproject.toml", "setup.py", "requirements.txt", ".python-version",

        -- Go
        "go.mod", "go.work",

        -- Rust
        "Cargo.toml",

        -- PHP
        "composer.json",

        -- C/C++
        "Makefile", "CMakeLists.txt", "compile_commands.json",

        -- Lua
        "init.lua",

        -- Protocol Buffers
        "buf.yaml", "buf.gen.yaml",

        -- Fallback
        ".root", -- custom marker if you want
      },

      -- Auto-change cwd
      manual_mode = false,
      silent_chdir = true,

      exclude_dirs = { "~/" },
    })

    pcall(require("telescope").load_extension, "projects")
  end,
}

