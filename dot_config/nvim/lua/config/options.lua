vim.g.snacks_animate = false
vim.g.lazyvim_check_order = false

-- Indentation: 4 spaces, expand tabs. Set explicitly so filetype/plugin
-- defaults (some of which are 8) can't override this.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.scrolloff = 8

-- LazyVim already enables this by default; set explicitly so exact
-- palette hexes (see ~/.config/theme/palette.env) render without being
-- rounded to a 256-color approximation, regardless of upstream defaults.
vim.opt.termguicolors = true

-- Don't fill the whole current line with a background color. Keep the
-- cursor-line indicator (a thick underline, styled in
-- lua/plugins/colorscheme.lua so it follows the theme) instead.
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line"
