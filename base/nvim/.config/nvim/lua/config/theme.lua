-- the active dotfiles theme's colours (~/.config/vim-theme); after lazy,
-- which resets the runtimepath
local theme = vim.fn.expand("~/.config/vim-theme")
vim.opt.runtimepath:prepend(theme)
if vim.fn.filereadable(theme .. "/theme.vim") == 1 then
  vim.cmd.source(theme .. "/theme.vim")
end
-- :Theme picks up a light/dark switch made while nvim is open
vim.api.nvim_create_user_command("Theme", function()
  vim.cmd.source(theme .. "/theme.vim")
  vim.cmd("silent! AirlineRefresh")
end, {})
