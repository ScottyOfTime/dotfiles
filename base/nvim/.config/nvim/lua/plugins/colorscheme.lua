return {
  "Luxed/ayu-vim",
  lazy = false,
  priority = 1000,
  config = function()
    -- the active theme's vim-theme picks the colorscheme (ayu-vim stays
    -- installed for themes that use it)
    local theme = vim.fn.expand("~/.config/vim-theme")
    vim.opt.runtimepath:prepend(theme)
    if vim.fn.filereadable(theme .. "/theme.vim") == 1 then
      vim.cmd.source(theme .. "/theme.vim")
    else
      vim.cmd.colorscheme("ayu")
    end
    -- :Theme picks up a light/dark switch made while nvim is open
    vim.api.nvim_create_user_command("Theme", function()
      vim.cmd.source(theme .. "/theme.vim")
      vim.cmd("silent! AirlineRefresh")
    end, {})
  end,
}
