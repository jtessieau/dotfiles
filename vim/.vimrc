" ============================================================
"  ~/.vimrc
"  Simple, clean and fancy Vim configuration
" ============================================================

" ------------------------------------------------------------
" General
" ------------------------------------------------------------

set encoding=utf-8

" Syntax highlighting
syntax on
filetype plugin indent on

" Use terminal colors when available
if has('termguicolors')
    set termguicolors
endif

" Dark background
set background=dark


" ------------------------------------------------------------
" Appearance
" ------------------------------------------------------------

" Line numbers
set number
"set relativenumber

" Highlight the current line
set cursorline

" Highlight the current column
" set cursorcolumn

" Always show the status line
set laststatus=2

" Show cursor position
set ruler

" Show the current mode
set showmode

" Show partially typed commands
set showcmd

" Better command completion
set wildmenu
set wildmode=longest:full,full

" Don't wrap long lines
set nowrap

" Keep some space around the cursor
set scrolloff=5
set sidescrolloff=5

" Better split behaviour
set splitbelow
set splitright

" Enable mouse
set mouse=a


" ------------------------------------------------------------
" Colors
" ------------------------------------------------------------

" Built-in color schemes only
colorscheme habamax

" A little more contrast for the current line
highlight CursorLineNr term=bold cterm=bold gui=bold

" Make comments slightly softer
highlight Comment cterm=italic gui=italic

" Make the status line stand out
highlight StatusLine term=bold cterm=bold gui=bold
highlight StatusLineNC term=NONE cterm=NONE gui=NONE


" ------------------------------------------------------------
" Indentation
" ------------------------------------------------------------

" Tabs are 4 spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Use spaces instead of tabs
set expandtab

" Smart indentation
set autoindent
set smartindent


" ------------------------------------------------------------
" Searching
" ------------------------------------------------------------

" Ignore case unless uppercase is used
set ignorecase
set smartcase

" Highlight matches
set hlsearch

" Search while typing
set incsearch

" Clear search highlighting with Escape
nnoremap <Esc> :nohlsearch<CR>


" ------------------------------------------------------------
" Editing
" ------------------------------------------------------------

" Better backspace behaviour
set backspace=indent,eol,start

" Keep undo history between sessions, stored in one dedicated folder
" instead of scattered next to whatever file you're editing.
if !isdirectory($HOME . "/.vim/undo")
    call mkdir($HOME . "/.vim/undo", "p")
endif
set undodir=~/.vim/undo
set undofile

" Don't create backup/swap files
set nobackup
set nowritebackup
set noswapfile


" ------------------------------------------------------------
" Clipboard
" ------------------------------------------------------------

" Use system clipboard if supported
if has('clipboard')
    set clipboard=unnamedplus
endif


" ============================================================
" End of ~/.vimrc
" ============================================================
