-- Reads ~/.config/theme/palette.env (single source of truth shared with
-- dot_config/theme/theme.sh) and exposes the current mode's colors to
-- Neovim, so the colorscheme (see lua/plugins/colorscheme.lua) stays in
-- sync with the terminal's background/foreground/16-color palette.

local M = {}

local function parse_env(path)
	local colors = {}
	local file = io.open(path, "r")
	if not file then
		return colors
	end
	for line in file:lines() do
		local key, value = line:match("^%s*([%w_]+)%s*=%s*(#%x+)%s*$")
		if key then
			colors[key] = value
		end
	end
	file:close()
	return colors
end

-- Prefers the live THEME_MODE env var (set by theme.sh in the shell that
-- launched nvim); falls back to the persisted state file so a light/dark
-- choice made in a previous shell still applies (e.g. nvim started by a
-- GUI or job runner without a full interactive shell).
local function read_mode()
	if vim.env.THEME_MODE == "light" or vim.env.THEME_MODE == "dark" then
		return vim.env.THEME_MODE
	end
	local ok, lines = pcall(vim.fn.readfile, vim.fn.expand("~/.cache/theme_mode"))
	if ok and lines[1] == "dark" then
		return "dark"
	end
	return "light"
end

function M.mode()
	return read_mode()
end

-- Returns a flat table for the current mode: { mode, bg, fg, accent1..3,
-- color0..color15 }, lower-cased and stripped of the LIGHT_/DARK_ prefix.
function M.colors()
	local all = parse_env(vim.fn.expand("~/.config/theme/palette.env"))
	local mode = M.mode()
	local prefix = mode == "dark" and "DARK_" or "LIGHT_"
	local out = { mode = mode }
	for key, value in pairs(all) do
		local name = key:match("^" .. prefix .. "(.+)$")
		if name then
			out[name:lower()] = value
		end
	end
	return out
end

return M
