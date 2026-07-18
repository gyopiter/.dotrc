
"------ BEGIN vim-plug ------
set nocompatible

" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

let s:plug_dir = has('nvim') ? stdpath('data') . '/plugged' : expand('~/.vim/plugged')
call plug#begin(s:plug_dir)

" Make sure you use single quotes.
Plug 'tpope/vim-fugitive'
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
Plug 'vim-airline/vim-airline'
Plug 'cocopon/iceberg.vim'
Plug 'sheerun/vim-polyglot'
Plug 'preservim/nerdtree'
Plug 'vim-scripts/vim-auto-save'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'

call plug#end()

" Plugin management commands:
" :PlugInstall  Install plugins that are not installed
" :PlugUpdate   Update installed plugins
" :PlugClean    Remove plugins no longer listed in this file
"------ END vim-plug ------

"------ BEGIN vim-auto-save ------
let g:auto_save = 1
let g:auto_save_no_updatetime = 1
let g:auto_save_in_insert_mode = 0
let g:auto_save_silent = 1
"------ END vim-auto-save ------

"------ BEGIN vim-vsnip ------
" NOTE: You can use other key to expand snippet.

" Expand
imap <expr> <C-y>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-y>'
smap <expr> <C-y>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-y>'

" Expand or jump
imap <expr> <C-i>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-i>'
smap <expr> <C-i>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-i>'

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
nmap        s   <Plug>(vsnip-select-text)
xmap        s   <Plug>(vsnip-select-text)
nmap        S   <Plug>(vsnip-cut-text)
xmap        S   <Plug>(vsnip-cut-text)

" If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']
let g:vsnip_snippet_dir = s:plug_dir . '/vim-vsnip/snippets'
"------ END vim-vsnip ------

nnoremap <Down> gj
nnoremap <Up>   gk

nnoremap j gj
nnoremap k gk

" Minimal Control-key bindings for insert mode and cursor navigation
nnoremap <C-i> i
nnoremap <C-h> h
nnoremap <C-j> gj
nnoremap <C-k> gk
nnoremap <C-l> l

inoremap <C-j> <C-o>gj
inoremap <C-k> <C-o>gk
inoremap <C-h> <Left>
inoremap <C-l> <Right>

vnoremap j gj
vnoremap k gk

nnoremap <silent><C-k>e :NERDTreeToggle<CR>

set background=dark
set backspace=indent,eol,start
set clipboard+=unnamed
set colorcolumn=80
set cursorline
set expandtab
set fileencodings=utf-8
set number
set mouse=a
set ruler
set showbreak=↪
set virtualedit=onemore
set whichwrap=b,s,h,l,<,>,[,]

" Cursor shape for terminal Vim: use a steady vertical bar in all modes.
if !has('gui_running')
  function! s:dotrc_set_cursor_shape(sequence) abort
    let &t_SI = a:sequence
    let &t_SR = a:sequence
    let &t_EI = a:sequence
    execute "normal! i\<Esc>"
  endfunction

  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[6 q"
  let &t_EI = "\<Esc>[6 q"

  augroup dotrc_cursor_shape
    autocmd!
    autocmd VimEnter * call <SID>dotrc_set_cursor_shape("\<Esc>[6 q")
    autocmd VimLeave * call <SID>dotrc_set_cursor_shape("\<Esc>[2 q")
  augroup END
endif

" IME configuration
" Apple IME itself is controlled by the OS. Keep Vim's own IME state reset
" when leaving insert or command-line mode so normal-mode mappings stay usable.
if has('macunix')
  inoremap <silent> <ESC> <ESC><Cmd>set iminsert=0 imsearch=0<CR>
  cnoremap <silent> <ESC> <ESC><Cmd>set iminsert=0 imsearch=0<CR>
  set iminsert=0
  set imsearch=0

  augroup dotrc_ime
    autocmd!
    autocmd InsertLeave,CmdlineLeave * set iminsert=0 imsearch=0
  augroup END
endif

augroup dotrc_filetype_settings
  autocmd!
  autocmd BufRead,BufNewFile *.txt setlocal spell spelllang=en_us formatoptions+=mM textwidth=80
  autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us formatoptions+=mM textwidth=80
augroup END

if has('termguicolors')
  set termguicolors
endif

colorscheme iceberg
