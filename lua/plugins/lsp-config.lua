-- LSP setup (optimized)
-- NOTE: lazy.nvim evaluates all files under `lua/plugins/*` at startup to collect specs.
-- Keep heavy work (vim.lsp, cmp_nvim_lsp, diagnostic config, etc.) inside plugin `config`.

local ROOT_MARKERS = {
  ".git",
  "pyproject.toml",
  "go.mod",
  "Cargo.toml",
  "package.json",
  "requirements.txt",
  "mix.exs",
}

local function get_project_root(fname)
  fname = fname or vim.api.nvim_buf_get_name(0)
  if fname == "" then return vim.loop.cwd() end

  local dir = vim.fs.dirname(fname)
  local found = vim.fs.find(ROOT_MARKERS, {
    path = dir,
    upward = true,
    stop = vim.loop.os_homedir(),
  })[1]

  -- Fall back to the file's directory (better for single-file projects)
  return found and vim.fs.dirname(found) or dir
end

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
        "pyright", -- Faster than pylsp
        "gopls",
        "ts_ls",
        "html",
        "cssls",
      },
      automatic_installation = true,
      handlers = {}, -- we configure servers manually below
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
      -- Use Neovim 0.11+ native API: vim.lsp.config + vim.lsp.enable
      -- This avoids the deprecated nvim-lspconfig "framework" API.

      -- =========================================================
      -- Capabilities
      -- =========================================================
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      do
        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok and cmp_lsp and cmp_lsp.default_capabilities then
          capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
        end
      end

      -- =========================================================
      -- Fast floating window helpers
      -- =========================================================
      local function open_float(contents, filetype)
        local _, win = vim.lsp.util.open_floating_preview(contents, filetype, {
          border = "single",
          focusable = false,
          max_width = 80,
          max_height = 15,
          close_events = { "CursorMoved", "CursorMovedI", "InsertEnter" },
        })

        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat,FloatBorder:FloatBorder")
        end
      end

      local hover_win = nil
      local hover_pending = false

      local function hover()
        if hover_win and vim.api.nvim_win_is_valid(hover_win) then
          vim.api.nvim_win_close(hover_win, true)
          hover_win = nil
        end
        if hover_pending then return end
        hover_pending = true

        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, "textDocument/hover", params, function(_, result)
          hover_pending = false
          if not result or not result.contents then return end

          local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
          if #lines == 0 then return end

          if #lines > 30 then
            local new_lines = {}
            for i = 1, 30 do
              new_lines[i] = lines[i]
            end
            new_lines[#new_lines + 1] = ""
            new_lines[#new_lines + 1] = "..." -- truncated
            lines = new_lines
          end

          local _, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
            border = "single",
            focusable = false,
            max_width = 80,
            max_height = 15,
            close_events = { "CursorMoved", "CursorMovedI", "InsertEnter" },
          })
          hover_win = win

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
            once = true,
            callback = function()
              if hover_win and vim.api.nvim_win_is_valid(hover_win) then
                vim.api.nvim_win_close(hover_win, true)
                hover_win = nil
              end
            end,
          })
        end)
      end

      local function signature()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(_, result)
          if not result or not result.signatures or #result.signatures == 0 then return end

          local lines = vim.lsp.util.convert_signature_help_to_markdown_lines(result)
          if #lines == 0 then return end

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
      -- Diagnostics
      -- =========================================================
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
        signs = false,
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
      -- LspAttach: keymaps and per-client tweaks (replacement for on_attach)
      -- =========================================================
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

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

          local bufnr = args.buf
          local keymap_opts = { buffer = bufnr }
          vim.keymap.set("n", "K", hover, vim.tbl_extend("keep", { desc = "Hover" }, keymap_opts))
          vim.keymap.set("i", "<C-k>", signature, vim.tbl_extend("keep", { desc = "Signature" }, keymap_opts))
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("keep", { desc = "Definition" }, keymap_opts))
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("keep", { desc = "Declaration" }, keymap_opts))
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("keep", { desc = "Implementation" }, keymap_opts))
          vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("keep", { desc = "References" }, keymap_opts))
          vim.keymap.set("v", "<leader>gf", vim.lsp.buf.format, vim.tbl_extend("keep", { desc = "Format" }, keymap_opts))
          vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, vim.tbl_extend("keep", { desc = "Format" }, keymap_opts))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("keep", { desc = "Code Action" }, keymap_opts))
          vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, vim.tbl_extend("keep", { desc = "Rename" }, keymap_opts))
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, vim.tbl_extend("keep", { desc = "Diagnostics" }, keymap_opts))
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true, timeout_ms = 5000 })
          end, vim.tbl_extend("keep", { desc = "Format" }, keymap_opts))
        end,
      })

      -- =========================================================
      -- Common server options
      -- =========================================================
      local common = {
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 150,
        },
        root_markers = ROOT_MARKERS,
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(get_project_root(fname))
        end,
      }

      -- =========================================================
      -- Servers
      -- =========================================================
      vim.lsp.config("lua_ls", vim.tbl_deep_extend("force", common, {
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

      vim.lsp.config("ts_ls", vim.tbl_deep_extend("force", common, {
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

      vim.lsp.config("pyright", vim.tbl_deep_extend("force", common, {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "basic",
              autoImportCompletions = true,
            },
          },
        },
      }))

      vim.lsp.config("gopls", vim.tbl_deep_extend("force", common, {
        settings = {
          gopls = {
            usePlaceholders = true,
          },
        },
      }))

      vim.lsp.config("clangd", vim.tbl_deep_extend("force", common, {
        cmd = {
          "clangd",
          "--background-index",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
      }))

      vim.lsp.config("rust_analyzer", vim.tbl_deep_extend("force", common, {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
            cargo = {
              allFeatures = false,
              buildScripts = { enable = false },
            },
          },
        },
      }))

      vim.lsp.config("html", common)
      vim.lsp.config("cssls", common)
      vim.lsp.config("cmake", common)

      vim.lsp.enable({
        "lua_ls",
        "ts_ls",
        "pyright",
        "gopls",
        "clangd",
        "rust_analyzer",
        "html",
        "cssls",
        "cmake",
      })
    end,
  },
}
