-- ========================================================-- =========================================================
-- Fast & deterministic project root detection
-- =========================================================

local ROOT_MARKERS = {
  ".git",
  "pyproject.toml",
  "go.mod",
  "Cargo.toml",
  "package.json",
  "requirements.txt",
  "mix.exs",
}

local function get_project_root(bufnr)
  bufnr = bufnr or 0
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then return vim.loop.cwd() end
  
  local found = vim.fs.find(ROOT_MARKERS, {
    path = vim.fs.dirname(name),
    upward = true,
    stop = vim.loop.os_homedir(),
  })[1]
  
  return found and vim.fs.dirname(found) or vim.loop.cwd()
end

-- =========================================================
-- Minimal LSP capabilities
-- =========================================================

local capabilities = vim.tbl_deep_extend("force", 
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities()
)

-- =========================================================
-- Fast floating window (no effects)
-- =========================================================

local function open_float(contents, filetype)
  local bufnr, win = vim.lsp.util.open_floating_preview(
    contents,
    filetype,
    {
      border = "single",
      focusable = false,
      max_width = 80,
      max_height = 15,
      close_events = { "CursorMoved", "CursorMovedI", "InsertEnter" },
    }
  )
  
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat,FloatBorder:FloatBorder")
  end
  
  return bufnr, win
end

-- =========================================================
-- Fast hover & signature (simplified, no timer issues)
-- =========================================================

local hover_win = nil
local hover_pending = false

local function hover()
  -- Close existing hover window
  if hover_win and vim.api.nvim_win_is_valid(hover_win) then
    vim.api.nvim_win_close(hover_win, true)
    hover_win = nil
  end
  
  -- Prevent multiple simultaneous requests
  if hover_pending then return end
  hover_pending = true
  
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/hover", params, function(_, result)
    hover_pending = false
    if not result or not result.contents then return end
    
    local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    if #lines == 0 then return end

    -- Limit hover size for speed and readability
    if #lines > 30 then
      local new_lines = {}
      for i = 1, 30 do
        new_lines[i] = lines[i]
      end
      new_lines[#new_lines + 1] = ""
      new_lines[#new_lines + 1] = "..." -- truncated
      lines = new_lines
    end
    
    local bufnr, win = open_float(lines, "markdown")
    hover_win = win
    
    -- Auto-close on cursor move
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
      once = true,
      callback = function()
        if hover_win and vim.api.nvim_win_is_valid(hover_win) then
          vim.api.nvim_win_close(hover_win, true)
          hover_win = nil
        end
      end
    })
  end)
end

local function signature()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(_, result)
    if not result or not result.signatures or #result.signatures == 0 then return end
    
    local lines = vim.lsp.util.convert_signature_help_to_markdown_lines(result)
    if #lines == 0 then return end

    -- Limit signature help size for speed and readability
    if #lines > 30 then
      local new_lines = {}
      for i = 1, 30 do
        new_lines[i] = lines[i]
      end
      new_lines[#new_lines + 1] = ""
      new_lines[#new_lines + 1] = "..." -- truncated
      lines = new_lines
    end
    
    open_float(lines, "markdown")
  end)
end

-- =========================================================
-- Efficient diagnostics
-- =========================================================

-- Show source and code when available for more informative messages
local function diagnostic_format(diagnostic)
  local code = diagnostic.code
  if not code and diagnostic.user_data and diagnostic.user_data.lsp then
    code = diagnostic.user_data.lsp.code
  end

  local source = diagnostic.source

  if code and source then
    return string.format("%s [%s:%s]", diagnostic.message, source, tostring(code))
  elseif code then
    return string.format("%s [%s]", diagnostic.message, tostring(code))
  elseif source then
    return string.format("%s [%s]", diagnostic.message, source)
  end

  return diagnostic.message
end

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
  signs = false, -- Remove signs for speed
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "single",
    source = "if_many",
    focusable = false,
    max_width = 80,
    format = diagnostic_format,
  },
})

-- =========================================================
-- Clean on_attach (no tracking overhead)
-- =========================================================

local function on_attach(client, bufnr)
  -- Disable formatting for specific servers
  local formatting_servers = {
    tsserver = true,
    ts_ls = true,
    vue_ls = true,
    volar = true,
    eslint = true,
  }
  
  if formatting_servers[client.name] then
    client.server_capabilities.documentFormattingProvider = false
  end
  
  -- Buffer-local keymaps
  local keymap_opts = { buffer = bufnr }
  vim.keymap.set("n", "K", hover, vim.tbl_extend("keep", { desc = "Hover" }, keymap_opts))
  vim.keymap.set("i", "<C-k>", signature, vim.tbl_extend("keep", { desc = "Signature" }, keymap_opts))
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("keep", { desc = "Definition" }, keymap_opts))
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("keep", { desc = "Declaration" }, keymap_opts))
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("keep", { desc = "Implementation" }, keymap_opts))
  vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("keep", { desc = "References" }, keymap_opts))
	vim.keymap.set("v","<leader>gf", vim.lsp.buf.format, vim.tbl_extend("keep", { desc = "Format" }, keymap_opts))
	vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, vim.tbl_extend("keep", { desc = "Format" }, keymap_opts))
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("keep", { desc = "Code Action" }, keymap_opts))
  vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, vim.tbl_extend("keep", { desc = "Rename" }, keymap_opts))
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, vim.tbl_extend("keep", { desc = "Diagnostics" }, keymap_opts))
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true, timeout_ms = 5000 })
  end, vim.tbl_extend("keep", { desc = "Format" }, keymap_opts))
end

-- =========================================================
-- Optimized LSP setup
-- =========================================================

return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ui = { border = "single" },
      max_concurrent_installers = 4,
    },
  },
  
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "clangd",
        "pyright",  -- Faster than pylsp
        "gopls",
        "ts_ls",
        "html",
        "cssls",
      },
      automatic_installation = true,
      handlers = {}, -- disable automatic lspconfig.setup; we configure servers manually below
    },
  },
  
  {
    "neovim/nvim-lspconfig",
    ft = {
      "lua",
      "python",
      "go",
      "c",
      "cpp",
      "rust",
      "html",
      "css",
      "javascript",
      "typescript",
      "typescriptreact",
      "javascriptreact",
      "vue",
      "cmake",
    },
    config = function()
      local lspconfig = require("lspconfig")
      
      local common = {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 150,
        },
        root_dir = function(fname)
          return get_project_root(vim.fn.bufnr(fname))
        end,
      }
      
      -- Lua
      lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", common, {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      }))
      
      -- TypeScript/JavaScript
      lspconfig.ts_ls.setup(vim.tbl_deep_extend("force", common, {
        init_options = {
          preferences = {
            includeCompletionsForImportStatements = true,
            includeCompletionsForModuleExports = false,
            includeAutomaticOptionalChainCompletions = true,
          },
        },
        settings = {
          typescript = {},
          javascript = {},
        },
      }))
      
      -- Python (using pyright for speed, but still informative)
      lspconfig.pyright.setup(vim.tbl_deep_extend("force", common, {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly", -- only open files for speed
              typeCheckingMode = "basic",        -- some type checking for better hints
              autoImportCompletions = true,       -- suggest imports in completion
            },
          },
        },
      }))
      
      -- Go
      lspconfig.gopls.setup(vim.tbl_deep_extend("force", common, {
        settings = {
          gopls = {
            usePlaceholders = true,
          },
        },
      }))
      
      -- C/C++
      -- Keep detailed completions, but drop clang-tidy (heavy) for faster feedback.
      -- If you want extra static analysis, you can add "--clang-tidy" back.
      lspconfig.clangd.setup(vim.tbl_deep_extend("force", common, {
        cmd = {
          "clangd",
          "--background-index",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
      }))
      
      -- Rust
      -- More informative (inlay hints + clippy) but tuned for decent performance.
      lspconfig.rust_analyzer.setup(vim.tbl_deep_extend("force", common, {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy", -- rich diagnostics on save
            },
            cargo = {
              allFeatures = false,               -- avoid building all features by default
              buildScripts = { enable = false }, -- speed up by skipping build scripts
            },
          },
        },
      }))
      
      -- Web
      lspconfig.html.setup(common)
      lspconfig.cssls.setup(common)
      
      -- CMake
      lspconfig.cmake.setup(common)
    end,
  },
}
