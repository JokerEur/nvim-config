-- Central colorscheme manager.
--
-- Responsibilities:
--   * remember the user's chosen colorscheme across sessions (persisted to disk)
--   * apply the saved scheme on startup
--   * expose a picker (with live preview) to switch scheme at runtime
--
-- All colorscheme plugin specs live in lua/colorschemes/.
local M = {}

-- Fallback used when nothing is saved yet or a saved scheme fails to load.
M.default = "kanagawa-dragon"

-- Curated list shown in the fallback picker (vim.ui.select).
-- The Snacks picker below discovers every installed scheme automatically.
M.schemes = {
	"kanagawa-dragon",
	"kanagawa-wave",
	"kanagawa-lotus",
	"moonfly",
}

-- Where the chosen scheme is persisted.
M.file = vim.fn.stdpath("data") .. "/colorscheme"

function M.load()
	local f = io.open(M.file, "r")
	if f then
		local name = vim.trim(f:read("*a") or "")
		f:close()
		if name ~= "" then
			return name
		end
	end
	return M.default
end

function M.save(name)
	local f = io.open(M.file, "w")
	if f then
		f:write(name)
		f:close()
	end
end

-- Apply a scheme and persist the choice. Returns true on success.
function M.set(name)
	local ok = pcall(vim.cmd.colorscheme, name)
	if not ok then
		vim.notify("Colorscheme not found: " .. tostring(name), vim.log.levels.ERROR)
		return false
	end
	M.save(name)
	vim.notify("Colorscheme: " .. name, vim.log.levels.INFO)
	return true
end

-- Apply the persisted scheme (used on startup). Falls back to the default.
function M.apply()
	local name = M.load()
	if not pcall(vim.cmd.colorscheme, name) then
		pcall(vim.cmd.colorscheme, M.default)
	end
end

-- Open an interactive picker to switch and persist the colorscheme.
function M.pick()
	-- Preferred: Snacks picker with live preview + revert-on-cancel.
	if Snacks and Snacks.picker and Snacks.picker.colorschemes then
		Snacks.picker.colorschemes({
			confirm = function(picker, item)
				picker:close()
				if item then
					M.set(item.text)
				end
			end,
		})
		return
	end

	-- Fallback: vim.ui.select (routed through dressing/telescope-ui-select).
	local current = vim.g.colors_name
	vim.ui.select(M.schemes, {
		prompt = "Colorscheme:",
		format_item = function(item)
			return item == current and (item .. "  (current)") or item
		end,
	}, function(choice)
		if choice then
			M.set(choice)
		end
	end)
end

-- Tame LSP inlay hints (`: string`, `msg:`, `arg1:` …). Some schemes (e.g.
-- moonfly) give LspInlayHint a solid background that reads as gray boxes. Link
-- it to Comment and drop any background so hints sit quietly inline, matching
-- whatever scheme is active. Loading a scheme resets highlights, so re-apply on
-- every ColorScheme (and once now for the current scheme).
local function fix_inlay_hint()
	local ok, comment = pcall(vim.api.nvim_get_hl, 0, { name = "Comment", link = false })
	local spec = { italic = true, bg = "NONE" }
	if ok and comment and type(comment.fg) == "number" then
		spec.fg = string.format("#%06x", comment.fg)
	end
	vim.api.nvim_set_hl(0, "LspInlayHint", spec)
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("inlay_hint_follow_colorscheme", { clear = true }),
	callback = fix_inlay_hint,
})
fix_inlay_hint()

-- :Colorscheme user command as another entry point.
vim.api.nvim_create_user_command("ColorschemePick", M.pick, {
	desc = "Pick and persist a colorscheme",
})

return M
