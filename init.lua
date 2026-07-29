local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.loader.enable()

-- Shim deprecated vim.lsp.buf_get_clients() to avoid noisy warnings from plugins
if vim.lsp and not vim.lsp._buf_get_clients_shim_applied then
  vim.lsp._buf_get_clients_shim_applied = true
  if vim.lsp.get_clients and vim.lsp.buf_get_clients then
    vim.lsp.buf_get_clients = function(bufnr)
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      local map = {}
      for _, client in ipairs(clients) do
        map[client.id] = client
      end
      return map
    end
  end
end

vim.lsp.set_log_level("ERROR")

require("nvim-options")
require("lazy").setup({
	{ import = "plugins" },
	{ import = "colorschemes" },
})

-- Apply the user's persisted colorscheme (see lua/colorscheme.lua).
-- Colorscheme plugins in lua/colorschemes/ are loaded at startup (priority
-- 1000) and only register their schemes; the active one is chosen here.
require("colorscheme").apply()
