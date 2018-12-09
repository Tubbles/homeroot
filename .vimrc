
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2017 Sep 20
"
" To use it, copy it to
"     for Unix and OS/2:  $HOME/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
"  set backup		" keep a backup file (restore to previous version)
"  set backupdir=$HOME/bkp/vim,.
"  set directory=$HOME/bkp/vim,.
"  if has('persistent_undo')
"    set undofile	" keep an undo file (undo changes after closing)
"  endif

  " Save your backup files to a less annoying place than the current directory.
  " If you have .vim-backup in the current directory, it'll use that.
  " Otherwise it saves it to $HOME/.vim/backup or .
  if isdirectory($HOME . '/.vim/backup') == 0
    :silent !mkdir -p $HOME/.vim/backup >/dev/null 2>&1
  endif
  set backupdir-=.
  set backupdir+=.
  set backupdir-=$HOME/
  set backupdir^=$HOME/.vim/backup/
  set backupdir^=./.vim-backup/
  set backup

  " Save your swap files to a less annoying place than the current directory.
  " If you have .vim-swap in the current directory, it'll use that.
  " Otherwise it saves it to $HOME/.vim/swap, $HOME/tmp or .
  if isdirectory($HOME . '/.vim/swap') == 0
    :silent !mkdir -p $HOME/.vim/swap >/dev/null 2>&1
  endif
  set directory=./.vim-swap//
  set directory+=$HOME/.vim/swap//
  set directory+=$HOME/tmp//
  set directory+=.

  " viminfo stores the the state of your previous editing session
  set viminfo+=n$HOME/.vim/viminfo

  if exists("+undofile")
    " undofile - This allows you to use undos after exiting and restarting
    " This, like swap and backup files, uses .vim-undo first, then $HOME/.vim/undo
    " :help undo-persistence
    " This is only present in 7.3+
    if isdirectory($HOME . '/.vim/undo') == 0
      :silent !mkdir -p $HOME/.vim/undo > /dev/null 2>&1
    endif
    set undodir=./.vim-undo//
    set undodir+=$HOME/.vim/undo//
    set undofile
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

" Set up 4 spaces instead of tab character
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

" Line number
set number
