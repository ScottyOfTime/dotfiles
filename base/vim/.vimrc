call plug#begin()

Plug 'Luxed/ayu-vim'

Plug 'vim-airline/vim-airline'

Plug 'tpope/vim-fugitive'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } 
Plug 'junegunn/fzf.vim'

call plug#end()

if has('termguicolors')
    set termguicolors
endif
augroup transparent_bg
  autocmd!
  autocmd ColorScheme * hi Normal guibg=NONE ctermbg=NONE
augroup END
set runtimepath^=~/.config/vim-theme
if filereadable(expand('~/.config/vim-theme/theme.vim'))
  source ~/.config/vim-theme/theme.vim
else
  colorscheme ayu
endif
let &t_ut = ''

let g:airline_symbols_ascii = 1

function! ProjectRoot()
  let l:dir = expand('%:p:h')
  let l:root = get(systemlist('git -C ' . shellescape(l:dir) . ' rev-parse --show-toplevel'), 0, '')
  return v:shell_error ? l:dir : l:root
endfunction

command! -bang ProjectFiles call fzf#vim#files(ProjectRoot(), fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* ProjectAg call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'dir': ProjectRoot()}), <bang>0)

nnoremap <C-a> :ProjectAg<CR>
nnoremap <C-p> :ProjectFiles<CR>

filetype plugin indent on

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set history=1000    
set encoding=utf-8
set nofixendofline

autocmd VimLeave * silent !echo -ne "\e[5 q"
let &t_SI = "\e[5 q"
let &t_EI = "\e[2 q"
set ttimeout
set ttimeoutlen=1
set ttyfast

augroup CursorShapeStartup
  autocmd!
  autocmd VimEnter * call writefile(["\e[2 q"], "/dev/tty", "b")
augroup END

set autochdir


set ruler
set showmatch
set modeline
set ls=2
set hlsearch
set number
set relativenumber


syntax on
highlight Comment ctermfg=blue cterm=bold
highlight String cterm=bold ctermfg=yellow
highlight Constant term=underline cterm=bold ctermfg=5 gui=bold guifg=cyan
highlight OverLength cterm=underline

autocmd BufNewFile,BufRead *.yml* set ft=yaml
autocmd BufNewFile,BufRead *Dockerfile* set ft=yaml 
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType json setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType cmake setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType scss setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType css setlocal tabstop=2 softtabstop=2 shiftwidth=2
