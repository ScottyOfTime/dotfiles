let s:file = expand((empty($XDG_STATE_HOME) ? '~/.local/state' : $XDG_STATE_HOME) . '/theme-mode')
let g:ayucolor = filereadable(s:file) && get(readfile(s:file, '', 1), 0, '') ==# 'light' ? 'light' : 'dark'
colorscheme ayu
hi Comment ctermfg=blue cterm=bold
hi String cterm=bold ctermfg=yellow
hi Constant term=underline cterm=bold ctermfg=5 gui=bold guifg=cyan
hi OverLength cterm=underline
