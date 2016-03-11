"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"  .bashrc -- my personal VIM configuration
"             see https://github.com/ULHPC/dotfiles
"                                _
"                         __   _(_)_ __ ___  _ __ ___
"                         \ \ / / | '_ ` _ \| '__/ __|
"                          \ V /| | | | | | | | | (__
"                         (_)_/ |_|_| |_| |_|_|  \___|
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Resources:
" * https://github.com/Falkor/dotfiles/blob/master/vim/.vimrc
" * https://github.com/hcartiaux/dotfiles/blob/master/vim/vimrc
" * https://github.com/shingara/vim-conf/blob/master/vimrc
" * http://vim.wikia.com/wiki/Configuring_the_cursor
" * http://ftp.vim.org/pub/vim/runtime/spell/
" * http://stackoverflow.com/questions/6496778/vim-run-autocmd-on-all-filetypes-except
" * http://vim.wikia.com/wiki/Omni_completion
" * http://amix.dk/vim/vimrc.html

set nocompatible

""""""""""""
" => General
""""""""""""

set history=1000
filetype on
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

""""""""""""""""""""""""
" => VIM user interface
""""""""""""""""""""""""

" Turn on the WiLd menu
set wildmenu
set wildmode=list:longest,full

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*.obj,.git,*.rbc

" Use the mouse
" set mouse=a

" Always show current position
set ruler

" A buffer becomes hidden when it is abandoned
set hid

" Show line numbers
" set number

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Keep 1 line when scrolling
set scrolloff=1

" Try to preserve column where cursor is positioned during motion commands
set nostartofline

" Displaying status line always
set laststatus=2

" Set the status line format
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)


" Show information about the current command going on
set showcmd


""""""""""""""""""""""
" => Colors and Fonts
""""""""""""""""""""""
colorscheme default
" set background=dark

" Set utf8 as standard encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Enable syntax highlighting
syntax enable

set cursorline
hi CursorLine term=bold cterm=bold ctermbg=blue ctermfg=white

if &term =~ '256color'
  set t_ut=
endif

"""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""

set nobackup
set noswapfile

""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
""""""""""""""""""""""""""""""""""

" Indent
set cindent

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab = 4 spaces
set shiftwidth=4
set softtabstop=4
set tabstop=4

" Use tab when editing Makefiles
autocmd FileType make set noexpandtab

" Linebreak on 500 characters
set lbr
set textwidth=200

"" Use modeline overrides (file specific configuration)
set modeline
set modelines=10

"===========================================================================
"" Mappings
"===========================================================================

map <F4> <Esc>:set paste<CR>

"" Copy/Paste/Cut
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
endif

"" Include user's local vim config
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

