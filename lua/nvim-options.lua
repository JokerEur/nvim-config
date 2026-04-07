---FOR WORK---
vim.cmd("set shiftwidth=4")
vim.cmd("set tabstop=4")

---FOR PERSONAL---
-- vim.cmd("set shiftwidth=2")
-- vim.cmd("set tabstop=2")

vim.cmd("set relativenumber")
vim.cmd("set nu rnu")
vim.g.mapleader = " "

-- Editing comfort
vim.opt.scrolloff      = 8
vim.opt.sidescrolloff  = 8
vim.opt.splitbelow     = true
vim.opt.splitright     = true
vim.opt.wrap           = false
vim.opt.cursorline     = true
vim.opt.cursorlineopt  = "number"   -- highlight only the line number, not the full line
vim.opt.termguicolors  = true
vim.opt.signcolumn     = "yes"
vim.opt.expandtab      = true
vim.opt.smartindent    = true
vim.opt.pumblend       = 10         -- subtle transparency for completion popup
vim.opt.winblend       = 10         -- subtle transparency for floating windows

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase  = true
vim.opt.hlsearch   = true

-- Persistence
vim.opt.undofile  = true
vim.opt.autowrite = true
vim.opt.swapfile  = false  -- swap causes disk I/O on every write

-- Rendering performance
vim.opt.synmaxcol  = 240   -- stop syntax on very long lines
vim.opt.redrawtime = 1500  -- give more time before disabling syntax

-- Informative UI
vim.opt.list        = true
vim.opt.listchars   = {
  trail   = "·",   -- trailing spaces
  tab     = "→ ",  -- tabs
  nbsp    = "␣",   -- non-breaking space
}
vim.opt.fillchars = {
  eob  = " ",    -- hide ~ at end of buffer
  fold = " ",
}

-- System clipboard
vim.opt.clipboard = "unnamedplus"

-- UX quality of life
vim.opt.cmdheight   = 0           -- hide cmdline when not typing a command
vim.opt.inccommand  = "split"     -- live preview of :s/foo/bar in a split
vim.opt.confirm     = true        -- ask to save instead of failing on :q
vim.opt.title       = true        -- show filename in terminal title bar
vim.opt.titlestring = "%t – nvim" -- short filename, not full path

-- ── Keymaps ──────────────────────────────────────────────────────────────
vim.keymap.set("i", "jk", "<Esc>")

-- Save from any mode
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Stay in indent mode after shifting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Move lines up/down
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Better scroll — keep cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next match (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
