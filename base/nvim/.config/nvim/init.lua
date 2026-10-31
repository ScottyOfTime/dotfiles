vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.fixendofline = false

vim.opt.termguicolors = true
vim.opt.showmatch = true
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.autochdir = true
vim.opt.ttimeoutlen = 1

vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-blinkon500-blinkoff500,r-cr-o:hor20"

local ft = vim.api.nvim_create_augroup("filetypes", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = ft,
  pattern = { "*.yml*", "*Dockerfile*" },
  command = "set ft=yaml",
})
vim.api.nvim_create_autocmd("FileType", {
  group = ft,
  pattern = { "yaml", "json", "cmake", "html", "scss", "css", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- colorscheme overrides, reapplied whenever a colorscheme loads
-- (vim.cmd.highlight merges with the scheme, nvim_set_hl would replace it)
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("colorscheme_overrides", { clear = true }),
  callback = function()
    vim.cmd([[
      hi Normal guibg=NONE ctermbg=NONE
      hi Comment ctermfg=blue cterm=bold
      hi String cterm=bold ctermfg=yellow
      hi Constant term=underline cterm=bold ctermfg=5 gui=bold guifg=cyan
      hi OverLength cterm=underline
    ]])
  end,
})

require("config.lazy")
