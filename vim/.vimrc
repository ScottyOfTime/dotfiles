"" vim-plug
call plug#begin()

Plug 'prabirshrestha/vim-lsp'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

Plug 'ayu-theme/ayu-vim'

Plug 'vim-airline/vim-airline'

Plug 'tpope/vim-fugitive'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } 
Plug 'junegunn/fzf.vim'

call plug#end()

" vim-lsp
augroup LspGo
  au!
  autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'gopls',
      \ 'cmd': {server_info->['gopls']},
      \ 'whitelist': ['go'],
      \ })
  autocmd FileType go setlocal omnifunc=lsp#complete
  autocmd FileType go nmap <buffer> gd <plug>(lsp-definition)
  autocmd FileType go nmap <buffer> ,n <plug>(lsp-next-error)
  autocmd FileType go nmap <buffer> ,p <plug>(lsp-previous-error)
augroup END

" vim-go
let g:go_def_mode = 'gopls'
let g:go_info_mode = 'gopls'
let go_imports_autosave = 0
let g:go_fmt_command = 'gofmt'
let g:go_fmt_autosave = 0
let g:go_recommended_style = 0

" colorscheme
if has('termguicolors')
    set termguicolors
endif
let ayucolor='dark'
colorscheme ayu
let &t_ut = ''

" fzf

nnoremap <C-a> :Ag<CR>

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
autocmd FileType cmake setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType scss setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType css setlocal tabstop=2 softtabstop=2 shiftwidth=2
