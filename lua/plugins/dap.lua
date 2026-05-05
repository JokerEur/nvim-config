return {
  -- Core DAP
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "theHamsta/nvim-dap-virtual-text",
      -- Language-specific
      "mfussenegger/nvim-dap-python",
      "leoluz/nvim-dap-go",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,            desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,                                             desc = "Continue" },
      { "<leader>dn", function() require("dap").step_over() end,                                            desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step into" },
      { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step out" },
      { "<leader>dr", function() require("dap").repl.open() end,                                            desc = "REPL" },
      { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run last" },
      { "<leader>dq", function() require("dap").terminate() end,                                            desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end,                                             desc = "Toggle UI" },
      { "<leader>de", function() require("dapui").eval() end,                                               desc = "Eval expr", mode = { "n", "v" } },
      { "<F5>",       function() require("dap").continue() end,                                             desc = "DAP Continue" },
      { "<F10>",      function() require("dap").step_over() end,                                            desc = "DAP Step over" },
      { "<F11>",      function() require("dap").step_into() end,                                            desc = "DAP Step into" },
      { "<F12>",      function() require("dap").step_out() end,                                             desc = "DAP Step out" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- ── UI ──────────────────────────────────────────────────────────────
      dapui.setup({
        icons = { expanded = "", collapsed = "", current_frame = "" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.35 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 12,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
          },
        },
        floating = { border = "rounded", mappings = { close = { "q", "<Esc>" } } },
      })

      -- Auto open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- ── Virtual text ─────────────────────────────────────────────────────
      require("nvim-dap-virtual-text").setup({
        commented = true,
        virt_text_pos = "eol",
      })

      -- ── Signs ────────────────────────────────────────────────────────────
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",          linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "●", texthl = "DapBreakpointRejected",  linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapLogPoint",            { text = "◉", texthl = "DapLogPoint",            linehl = "", numhl = "" })

      -- ── Python ───────────────────────────────────────────────────────────
      require("dap-python").setup(
        vim.fn.exepath("debugpy-adapter") ~= "" and vim.fn.exepath("debugpy-adapter")
        or (vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
      )

      -- ── Go ───────────────────────────────────────────────────────────────
      require("dap-go").setup({
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
        delve = { initialize_timeout_sec = 20, port = "${port}" },
      })

      -- ── C / C++ / Rust (codelldb) ─────────────────────────────────────
      local codelldb_path = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
      if vim.fn.executable(codelldb_path) == 1 then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = { command = codelldb_path, args = { "--port", "${port}" } },
        }
        for _, ft in ipairs({ "c", "cpp", "rust" }) do
          dap.configurations[ft] = {
            {
              name = "Launch file",
              type = "codelldb",
              request = "launch",
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
            },
          }
        end
      end

      -- ── JavaScript / TypeScript (js-debug-adapter) ───────────────────
      local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
      if vim.fn.filereadable(js_debug_path) == 1 then
        dap.adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = { js_debug_path, "${port}" },
          },
        }
        for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
          dap.configurations[ft] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
              sourceMaps = true,
            },
          }
        end
      end
    end,
  },

  -- Auto-install debug adapters via Mason
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "debugpy",    -- Python
        "delve",      -- Go
        "codelldb",   -- C/C++/Rust
        "js-debug-adapter", -- JS/TS
      },
      automatic_installation = true,
      handlers = {},
    },
  },
}