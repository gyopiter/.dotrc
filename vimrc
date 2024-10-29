
"------ BEGIN Vundle ------
set nocompatible              " be iMproved, required filetype off
" required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"
"Plugin 'file:///home/gmarik/path/to/plugin'
"
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line

" User Set Plugin
Plugin 'vim-airline/vim-airline'
Plugin 'cocopon/iceberg.vim'
Plugin 'arcticicestudio/nord-vim'
Plugin 'vim-test/vim-test'
Plugin 'prettier/vim-prettier'
Plugin 'sheerun/vim-polyglot'
Plugin 'preservim/nerdtree'
Plugin 'vim-scripts/vim-auto-save'
Plugin 'xolox/vim-session'
Plugin 'xolox/vim-misc'
Plugin 'hrsh7th/vim-vsnip'
Plugin 'hrsh7th/vim-vsnip-integ'
Plugin 'godlygeek/tabular'
Plugin 'preservim/vim-markdown'
Plugin 'embear/vim-localvimrc'
Plugin 'jiangmiao/auto-pairs'


call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"
"------ END Vundle ------


"------ BEGIN vim-auto-save ------
let g:auto_save = 1
let g:auto_save_no_updatetime = 1
let g:auto_save_in_insert_mode = 0
let g:auto_save_silent = 1
"------ BEGIN vim-auto-save ------


"------ BEGIN vim-session ------
" 現在のディレクトリ直下の .vimsessions/ を取得
let s:local_session_directory = xolox#misc#path#merge(getcwd(), '.vimsessions')
" 存在すれば
if isdirectory(s:local_session_directory)
    " session保存ディレクトリをそのディレクトリの設定
    let g:session_directory = s:local_session_directory
    " vimを辞める時に自動保存
    let g:session_autosave = 'yes'
    " 引数なしでvimを起動した時にsession保存ディレクトリのdefault.vimを開く
    let g:session_autoload = 'yes'
    " 1分間に1回自動保存
    let g:session_autosave_periodic = 1
else
    let g:session_autosave = 'no'
    let g:session_autoload = 'no'
endif
unlet s:local_session_directory
"------ END vim-session ------


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
let g:vsnip_snippet_dir = '~/.vim/bundle/vim-vsnip/snippets'
"------ END vim-vsnip ------


"------ BEGIN vim-localvimrc ------
"let g:localvimrc_ask=0
let g:localvimrc_persistent=2
let g:localvimrc_persistent=1
"------ END vim-localvimrc ------


syntax enable


nnoremap <Down> gj
nnoremap <Up>   gk


nnoremap j gj
nnoremap k gk


inoremap <C-j> <C-o>gj
inoremap <C-k> <C-o>gk
inoremap <C-h> <Left>
inoremap <C-l> <Right>


vnoremap j gj
vnoremap k gk


"inoremap { {}<LEFT>
"inoremap {<Enter> {}<Left><CR><ESC><S-o>
"inoremap [ []<LEFT>
"inoremap ( ()<LEFT>
"inoremap (<Enter> ()<Left><CR><ESC><S-o>
"inoremap " ""<LEFT>
"inoremap ' ''<LEFT>


nnoremap <silent><C-k>e :NERDTreeToggle<CR>


set background=dark
set backspace=indent,eol,start
set clipboard+=unnamed
set colorcolumn=80
set cursorline
set expandtab
set fileencodings=utf-8
set number
set ruler
set showbreak=↪
set virtualedit=onemore
set whichwrap=b,s,h,l,<,>,[,]


" IME configuration
inoremap <silent> <ESC> <ESC>:set iminsert=2<CR>
set iminsert=2
set imsearch=0


autocmd BufRead,BufNewFile *.txt set spell spelllang=en_us formatoptions+=mM textwidth=80 nospell
autocmd BufRead,BufNewFile *.md  set spell spelllang=en_us formatoptions+=mM textwidth=80 nospell


if has("win32")
    set termguicolors
endif


colorscheme iceberg
