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
  if fname == "" then return vim.uv.cwd() end

  local dir = vim.fs.dirname(fname)
  local found = vim.fs.find(ROOT_MARKERS, {
    path = dir,
    upward = true,
    stop = vim.uv.os_homedir(),
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
    "neovim/nvim-lspconfig",
    -- Load before any buffer is read so vim.lsp.config() is registered
    -- before mason-lspconfig or any FileType autocmd can start servers.
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {
            "lua_ls",
            "rust_analyzer",
            "clangd",
            "pyright",
            "gopls",
            "ts_ls",
            "html",
            "cssls",
          },
          -- Do NOT auto-enable servers — we call vim.lsp.enable() manually
          -- below after configs are registered.
          automatic_installation = false,
          handlers = {},
        },
      },
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
      -- Disable file watching to reduce LSP overhead
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      -- =========================================================
      -- Hover options (passed directly via 0.11+ API in the keymap below)
      -- =========================================================
      local hover_opts = {
        border = "single",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        max_width = 80,
        max_height = 25,
        focusable = true,
      }

      local sig_win = nil

      local function close_sig_win()
        if sig_win and vim.api.nvim_win_is_valid(sig_win) then
          vim.api.nvim_win_close(sig_win, true)
          sig_win = nil
        end
      end

      local function signature()
        close_sig_win()
        local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/signatureHelp" })
        local encoding = clients[1] and clients[1].offset_encoding or "utf-16"
        local params = vim.lsp.util.make_position_params(0, encoding)
        vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(_, result)
          if not result or not result.signatures or #result.signatures == 0 then return end

          local idx = (result.activeSignature or 0) + 1
          local sig = result.signatures[idx] or result.signatures[1]
          if not sig then return end

          local ft = vim.bo.filetype
          local lines = {}

          -- Signature with syntax highlighting
          table.insert(lines, "```" .. ft)
          table.insert(lines, sig.label)
          table.insert(lines, "```")

          -- Active parameter documentation
          local active_idx = result.activeParameter
          if active_idx == nil then active_idx = sig.activeParameter end
          local param = active_idx ~= nil and sig.parameters and sig.parameters[active_idx + 1]
          if param and param.documentation then
            local pdoc = type(param.documentation) == "table" and param.documentation.value or param.documentation
            if pdoc and pdoc ~= "" then
              local plabel = type(param.label) == "string" and param.label or ""
              table.insert(lines, "")
              table.insert(lines, (plabel ~= "" and ("**" .. plabel .. "**: ") or "") .. pdoc)
            end
          end

          -- Brief signature documentation
          if sig.documentation then
            local doc = type(sig.documentation) == "table" and sig.documentation.value or sig.documentation
            if doc and doc ~= "" then
              table.insert(lines, "")
              local doc_lines = vim.split(doc, "\n", { plain = true })
              for i, l in ipairs(doc_lines) do
                if i > 6 then
                  table.insert(lines, "...")
                  break
                end
                table.insert(lines, l)
              end
            end
          end

          local _, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
            border = "single",
            focusable = false,
            max_width = 80,
            max_height = 15,
            close_events = { "CursorMoved", "InsertLeave" },
            anchor_bias = "above",
          })
          sig_win = win
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

      -- Icons kept in sync with the lualine diagnostics segment.
      local diagnostic_icons = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN]  = " ",
        [vim.diagnostic.severity.INFO]  = " ",
        [vim.diagnostic.severity.HINT]  = " ",
      }

      -- Just a colored dot on every diagnostic line EXCEPT the current one — no
      -- inline message text. One dot per diagnostic, tinted by severity. The
      -- current line instead gets the full multiline `virtual_lines` tree below.
      local virt_text_opts = {
        current_line = false,
        prefix = "●",
        spacing = 1,
        -- Empty message: only the dot renders (still severity-highlighted).
        format = function() return "" end,
      }

      -- Full multiline "tree" for the current line — but managed manually via a
      -- dedicated namespace instead of Neovim's native
      -- `virtual_lines = { current_line = true }`. The native handler also renders
      -- a diagnostic whenever the cursor is anywhere inside its (often multi-line)
      -- range, drawing the tree at the range's *start* — so a wide rust-analyzer
      -- macro error would show its tree many lines away from the cursor. We instead
      -- render only diagnostics that *start* on the cursor's exact line (i.e. the
      -- lines that carry a dot), so the tree always sits right under the cursor.
      local vl_ns = vim.api.nvim_create_namespace("nvim.diagnostic.current_line_lines")
      -- This namespace draws ONLY the tree; signs/dots/underline stay on the main
      -- (LSP) namespace so nothing is duplicated.
      vim.diagnostic.config({
        virtual_lines = { current_line = false, format = diagnostic_format },
        virtual_text = false,
        signs = false,
        underline = false,
      }, vl_ns)

      local vl_enabled = true
      local vl_last_line = -1

      local function refresh_current_line_lines(force)
        local bufnr = vim.api.nvim_get_current_buf()
        if not vl_enabled then
          vim.diagnostic.hide(vl_ns, bufnr)
          return
        end
        local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
        if not force and lnum == vl_last_line then return end
        vl_last_line = lnum
        -- Only diagnostics that START on this line — not ones whose range merely
        -- spans it (that is what caused the tree to "stick" far from the cursor).
        local diags = vim.tbl_filter(function(d)
          return d.lnum == lnum
        end, vim.diagnostic.get(bufnr))
        -- Empty list still clears the namespace (show() hides first), so the tree
        -- disappears the moment the cursor leaves a diagnostic line.
        vim.diagnostic.show(vl_ns, bufnr, diags)
      end

      vim.diagnostic.config({
        virtual_text = virt_text_opts,
        virtual_lines = false,
        signs = {
          text = diagnostic_icons,
          numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
          },
        },
        underline = {
          -- Only underline warnings/errors; skip the noisy rust-analyzer Hint
          -- diagnostics that otherwise underline nearly the whole buffer.
          severity = { min = vim.diagnostic.severity.WARN },
        },
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

      -- Drive the current-line tree: follow the cursor (line changes only) and
      -- re-render when diagnostics update or we switch buffer/window.
      local vl_group = vim.api.nvim_create_augroup("diagnostic_current_line_lines", { clear = true })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = vl_group,
        callback = function() refresh_current_line_lines(false) end,
      })
      vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufEnter", "WinEnter" }, {
        group = vl_group,
        callback = function() refresh_current_line_lines(true) end,
      })

      -- =========================================================
      -- Diagnostic navigation (global — always available)
      -- =========================================================
      -- Landing on a diagnostic line surfaces the full `virtual_lines` message,
      -- so no jump-float is needed here.
      local function jump(count, severity)
        return function()
          vim.diagnostic.jump({ count = count, severity = severity, float = false })
        end
      end

      local sev = vim.diagnostic.severity
      vim.keymap.set("n", "]d", jump(1),  { desc = "Next diagnostic" })
      vim.keymap.set("n", "[d", jump(-1), { desc = "Prev diagnostic" })
      vim.keymap.set("n", "]e", jump(1, sev.ERROR),  { desc = "Next error" })
      vim.keymap.set("n", "[e", jump(-1, sev.ERROR), { desc = "Prev error" })
      vim.keymap.set("n", "]w", jump(1, sev.WARN),  { desc = "Next warning" })
      vim.keymap.set("n", "[w", jump(-1, sev.WARN), { desc = "Prev warning" })

      -- =========================================================
      -- Diagnostic display toggles (under <leader>u = UI/Toggle)
      -- =========================================================
      vim.keymap.set("n", "<leader>ux", function()
        vl_enabled = not vl_enabled
        refresh_current_line_lines(true)
        vim.notify("Diagnostic lines " .. (vl_enabled and "on" or "off"), vim.log.levels.INFO)
      end, { desc = "Toggle diagnostic virtual lines" })

      vim.keymap.set("n", "<leader>uv", function()
        local on = vim.diagnostic.config().virtual_text ~= false
        vim.diagnostic.config({ virtual_text = on and false or virt_text_opts })
        vim.notify("Diagnostic virtual text " .. (on and "off" or "on"), vim.log.levels.INFO)
      end, { desc = "Toggle diagnostic virtual text" })

      vim.keymap.set("n", "<leader>ud", function()
        local on = vim.diagnostic.is_enabled()
        vim.diagnostic.enable(not on)
        vim.notify("Diagnostics " .. (on and "off" or "on"), vim.log.levels.INFO)
      end, { desc = "Toggle diagnostics" })

      -- =========================================================
      -- LspAttach: keymaps and per-client tweaks (replacement for on_attach)
      -- =========================================================
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          -- Remove Neovim 0.11 built-in gr* mappings so our buffer-local `gr`
          -- (references) isn't treated as a prefix and fires immediately.
          for _, k in ipairs({ "grn", "gra", "gri", "grr", "grt" }) do
            pcall(vim.keymap.del, "n", k)
          end
          pcall(vim.keymap.del, "x", "gra")

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

          if client.supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          vim.keymap.set("n", "K", function() vim.lsp.buf.hover(hover_opts) end, vim.tbl_extend("keep", { desc = "Hover" }, keymap_opts))
          vim.keymap.set("i", "<C-k>", signature, vim.tbl_extend("keep", { desc = "Signature" }, keymap_opts))

          vim.api.nvim_create_autocmd({ "InsertLeave", "CursorMoved" }, {
            buffer = bufnr,
            callback = close_sig_win,
          })
          vim.keymap.set("n", "gd", function()
            require("telescope.builtin").lsp_definitions({ reuse_win = true, initial_mode = "normal" })
          end, vim.tbl_extend("keep", { desc = "Definition" }, keymap_opts))
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("keep", { desc = "Declaration" }, keymap_opts))
          vim.keymap.set("n", "gi", function()
            require("telescope.builtin").lsp_implementations({ reuse_win = true, initial_mode = "normal" })
          end, vim.tbl_extend("keep", { desc = "Implementation" }, keymap_opts))
          vim.keymap.set("n", "gr", function()
            require("telescope.builtin").lsp_references({ include_declaration = false, initial_mode = "normal" })
          end, vim.tbl_extend("keep", { desc = "References" }, keymap_opts))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("keep", { desc = "Code Action" }, keymap_opts))
          vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, vim.tbl_extend("keep", { desc = "Rename" }, keymap_opts))
          vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("keep", { desc = "Diagnostics float" }, keymap_opts))
          vim.keymap.set({ "n", "v" }, "<leader>lf", function()
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
              library = { vim.env.VIMRUNTIME },
              checkThirdParty = false,
              maxPreload = 2000,
              preloadFileSize = 1000,
            },
            telemetry = { enable = false },
            hint = {
              enable = true,
              arrayIndex = "Disable",
              await = true,
              paramName = "All",
              paramType = true,
              semicolon = "Disable",
              setType = true,
            },
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
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
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
              inlayHints = {
                variableTypes = true,
                functionReturnTypes = true,
                callArgumentNames = true,
                pytestParameters = true,
              },
            },
          },
        },
      }))

      vim.lsp.config("gopls", vim.tbl_deep_extend("force", common, {
        settings = {
          gopls = {
            usePlaceholders = true,
            deepCompletion = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      }))

      vim.lsp.config("clangd", vim.tbl_deep_extend("force", common, {
        cmd = {
          "clangd",
          -- Parallelise background indexing across cores (leave a few free).
          "-j=" .. math.max(2, math.floor((vim.uv.available_parallelism() or 4) * 0.6)),
          -- Persist the index to .cache/clangd/ so reopening a project skips
          -- re-indexing. On by default, but make the intent explicit.
          "--background-index",
          "--background-index-priority=low",
          -- Keep precompiled headers in RAM instead of on disk (faster
          -- completions/diagnostics; costs memory on big TUs).
          "--pch-storage=memory",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
      }))

      vim.lsp.config("rust_analyzer", vim.tbl_deep_extend("force", common, {
        -- Prefer the rustup proxy at ~/.cargo/bin/rust-analyzer: it honours the
        -- project's rust-toolchain.toml (per-project pin) and gives sysroot
        -- access for stdlib docs. Do NOT hardcode `rustup run stable` — that
        -- overrides rust-toolchain.toml and can pin an outdated `stable`.
        -- Falls back to PATH (Mason standalone) if the proxy is unavailable.
        cmd = (function()
          local proxy = vim.fn.expand("~/.cargo/bin/rust-analyzer")
          if vim.fn.executable(proxy) == 1 then
            return { proxy }
          end
          return { "rust-analyzer" }
        end)(),
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = true,
            check = {
              command = "clippy",
              -- Speed: don't compile tests/benches/examples on every save,
              -- and use a separate target dir so the on-save check never
              -- blocks on the file lock held by a manual `cargo build`.
              allTargets = false,
              extraArgs = { "--target-dir", "target/rust-analyzer" },
              -- Cache rustc invocations from the on-save clippy run. Big win on
              -- dependencies and cold `target-dir` starts. Only applies if
              -- `sccache` is on PATH — otherwise this env var is ignored and
              -- compilation falls back to plain rustc.
              extraEnv = vim.fn.executable("sccache") == 1
                and { RUSTC_WRAPPER = "sccache" }
                or nil,
            },
            cargo = {
              allFeatures = true,
              buildScripts = { enable = true },
              sysroot = "discover",
            },
            rustc = {
              source = "discover",
            },
            procMacro = {
              enable = true,
            },
            -- Ensure stdlib hover docs (Vec, Option, etc.) are rendered
            hover = {
              documentation = {
                enable = true,
                keywords = { enable = true },
              },
              links = { enable = true },
            },
            inlayHints = {
              bindingModeHints = { enable = true },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "always" },
              parameterHints = { enable = true },
              typeHints = { enable = true },
              reborrowHints = { enable = "never" },
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
