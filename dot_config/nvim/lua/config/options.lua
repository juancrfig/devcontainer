vim.g.snacks_animate = false
vim.g.lazyvim_check_order = false
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.scrolloff = 8

-- LazyVim already enables this by default; set explicitly so exact
-- palette hexes (see ~/.config/theme/palette.env) render without being
-- rounded to a 256-color approximation, regardless of upstream defaults.
vim.opt.termguicolors = true
