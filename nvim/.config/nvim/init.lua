-- formatting
vim.opt.tabstop = 4         -- tab spacing
vim.opt.softtabstop = 4     -- unify
vim.opt.shiftwidth = 4      -- indentation size
vim.opt.expandtab = true    -- no tabs in whitespace
vim.opt.fixendofline = false

-- presentation
vim.opt.termguicolors = true
vim.opt.showmatch = true    -- show matching brackets
vim.opt.number = true
vim.opt.relativenumber = true

-- misc
vim.opt.autochdir = true
vim.opt.ttimeoutlen = 1

-- cursor: steady block in normal, blinking bar in insert
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-blinkon500-blinkoff500,r-cr-o:hor20"

-- set syntax based on filenaming and type
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
