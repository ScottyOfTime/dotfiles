let g:ayucolor = trim(system('darkman get')) ==# 'light' ? 'light' : 'dark'
colorscheme ayu
hi Comment ctermfg=blue cterm=bold
hi String cterm=bold ctermfg=yellow
hi Constant term=underline cterm=bold ctermfg=5 gui=bold guifg=cyan
hi OverLength cterm=underline
