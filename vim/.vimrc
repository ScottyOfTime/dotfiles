"" vim-plug
call plug#begin()

Plug 'Luxed/ayu-vim'

Plug 'vim-airline/vim-airline'

Plug 'tpope/vim-fugitive'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } 
Plug 'junegunn/fzf.vim'

call plug#end()

" colorscheme
if has('termguicolors')
    set termguicolors
endif
let ayucolor = trim(system('darkman get')) ==# 'light' ? 'light' : 'dark'
augroup transparent_bg
  autocmd!
  autocmd ColorScheme * hi Normal guibg=NONE ctermbg=NONE
augroup END
colorscheme ayu
let &t_ut = ''

" fzf

" search from the git root of the current file, else its directory
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

" formatting
set tabstop=4           " tab spacing (setting below is just to unify it)
set softtabstop=4       " unify
set shiftwidth=4        " indentation size
set expandtab           " no tabs in whitespace
set history=1000    
set encoding=utf-8
set nofixendofline

" cursor
autocmd VimEnter * call system('echo -ne "\e[2 q"')
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

" tab complete
set autochdir


" presentation
set ruler        " show the cursor position all the time
set showmatch       " show matching brackets
set modeline        " enable modeline
set ls=2            " always show status line
set hlsearch        " highlight search results
set number
set relativenumber


" Syntax Highlighting
syntax on
"setf cpp
highlight Comment ctermfg=blue cterm=bold
highlight String cterm=bold ctermfg=yellow
highlight Constant term=underline cterm=bold ctermfg=5 gui=bold guifg=cyan
highlight OverLength cterm=underline

" set syntax based on filenaming and type
autocmd BufNewFile,BufRead *.yml* set ft=yaml
autocmd BufNewFile,BufRead *Dockerfile* set ft=yaml 
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType json setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType cmake setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType scss setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType css setlocal tabstop=2 softtabstop=2 shiftwidth=2
