-- Configures tokyonight.nvim (LazyVim's default colorscheme, already
-- bundled) with the palette from ~/.config/theme/palette.env instead of
-- its stock colors. Mode (light/dark) follows THEME_MODE from the shell
-- that launched nvim; see lua/config/theme_palette.lua.
--
-- :ThemeLight / :ThemeDark / :ThemeToggle switch it live, mirroring the
-- shell's `theme` command.

local palette = require("config.theme_palette")

-- Maps our palette onto tokyonight's color fields. Several accents reuse
-- your exact hexes directly (green/yellow/orange in light mode; blue/cyan
-- in dark mode); the rest were chosen to match in the 16-color step.
local function on_colors(p)
	return function(colors)
		colors.bg = p.bg
		colors.bg_dark = p.bg
		colors.bg_highlight = p.color8
		colors.bg_visual = p.color8
		colors.fg = p.fg
		colors.fg_dark = p.color8
		colors.comment = p.mode == "dark" and p.accent3 or p.color8
		colors.red = p.color1
		colors.orange = p.color11
		colors.yellow = p.color3
		colors.green = p.color2
		colors.green1 = p.color10
		colors.cyan = p.color6
		colors.blue = p.color4
		colors.blue1 = p.color12
		colors.purple = p.color5
		colors.magenta = p.color5
		colors.magenta2 = p.color13
		colors.teal = p.color14
	end
end

local function tokyonight_opts()
	local p = palette.colors()
	return {
		style = p.mode == "dark" and "night" or "day",
		on_colors = on_colors(p),
	}
end

local function set_theme(mode)
	vim.fn.setenv("THEME_MODE", mode)
	require("tokyonight").setup(tokyonight_opts())
	vim.cmd.colorscheme("tokyonight")
end

vim.api.nvim_create_user_command("ThemeLight", function()
	set_theme("light")
end, {})
vim.api.nvim_create_user_command("ThemeDark", function()
	set_theme("dark")
end, {})
vim.api.nvim_create_user_command("ThemeToggle", function()
	set_theme(palette.mode() == "dark" and "light" or "dark")
end, {})

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = tokyonight_opts,
	},
	{ "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
}
