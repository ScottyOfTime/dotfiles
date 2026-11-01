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

    -- follow light/dark switches: the theme writes its mode to this file
    local mode_file = (vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")) .. "/theme-mode"
    local function mtime()
      local stat = vim.uv.fs_stat(mode_file)
      return stat and stat.mtime.sec * 1e9 + stat.mtime.nsec or 0
    end
    local seen = mtime()
    vim.uv.new_timer():start(2000, 2000, vim.schedule_wrap(function()
      if mtime() == seen then return end
      seen = mtime()
      if vim.fn.filereadable(theme .. "/theme.vim") == 1 then
        vim.cmd.source(theme .. "/theme.vim")
      end
      if vim.fn.exists(":AirlineRefresh") == 2 then vim.cmd("AirlineRefresh") end
    end))
  end,
}
