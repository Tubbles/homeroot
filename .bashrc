#
# $HOME/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

#alias ls='ls -AFq --color --group-directories-first'
alias ls='LC_ALL=C ls -Fq --color --group-directories-first'
alias l='ls -lh --time-style=+%y%m%d-%H%M%S'
alias ll='l -A'
alias path='env | grep -E "^PATH=" | tr ":" "\n" | sed "s/PATH=//g"'
alias less='less -r'
alias dog='highlight --force -O xterm256'
alias reload="test -r $HOME/.bashrc && . $HOME/.bashrc"

