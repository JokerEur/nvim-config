return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
			"jay-babu/mason-nvim-dap.nvim",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Virtual text
			require("nvim-dap-virtual-text").setup({
				enabled = true,
				commented = true,
				virt_text_pos = "eol",
			})

			-- UI panels
			dapui.setup({
				layouts = {
					{
						elements = { "scopes", "breakpoints", "stacks", "watches" },
						size = 40,
						position = "left",
					},
					{
						elements = { "repl", "console" },
						size = 10,
						position = "bottom",
					},
				},
			})

			-- Auto open/close UI
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Mason DAP (adapters)
			require("mason-nvim-dap").setup({
				ensure_installed = {
					"codelldb", -- Rust / C++
					"python", -- Python
					"php", -- PHP
					"node2", -- Old Node adapter
					"js", -- Modern js-debug (better for Vue/React)
				},
				automatic_installation = true,
			})

			-------------------------------------------------------------------------
			-- LANGUAGE-SPECIFIC CONFIGS
			-------------------------------------------------------------------------

			-- Rust & C++ (via codelldb)
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
					args = { "--port", "${port}" },
				},
			}
			dap.configurations.cpp = {
				{
					name = "Launch C++ file",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					runInTerminal = true,
				},
			}
			dap.configurations.rust = dap.configurations.cpp

			-- Python (via debugpy)
			dap.adapters.python = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
				args = { "-m", "debugpy.adapter" },
			}
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = function()
						return vim.fn.exepath("python3") or "python"
					end,
				},
			}

			-- PHP (via php-debug)
			dap.adapters.php = {
				type = "executable",
				command = "node",
				args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
			}
			dap.configurations.php = {
				{
					type = "php",
					request = "launch",
					name = "Listen for Xdebug",
					port = 9003,
				},
			}

			-- Node.js / React / Vue (via js-debug)
			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			}

			-- Shared config for JS/TS (Node, React, Vue)
			local js_config = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach to process",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "launch",
					name = "Debug Jest Tests",
					runtimeExecutable = "node",
					runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest", "--runInBand" },
					rootPath = "${workspaceFolder}",
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					internalConsoleOptions = "neverOpen",
				},
			}

			dap.configurations.javascript = js_config
			dap.configurations.typescript = js_config
			dap.configurations.javascriptreact = js_config
			dap.configurations.typescriptreact = js_config
			dap.configurations.vue = js_config

			-------------------------------------------------------------------------
			-- KEYMAPS
			-------------------------------------------------------------------------
			vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
			vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>B", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "DAP Conditional Breakpoint" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP Open REPL" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP Run Last" })
			vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP Toggle UI" })
		end,
	},
}
