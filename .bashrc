#
# $HOME/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

#alias ls='ls -AFq --color --group-directories-first'
alias ls='LC_COLLATE=C ls -Fq --color --group-directories-first'
alias l='ls -lh --time-style=+%y%m%d-%H%M%S'
alias ll='l -A'
alias path='echo $PATH | tr ":" "\n"'
alias less='less -r'
alias dog='highlight --force -O xterm256'
alias reload="test -r $HOME/.bashrc && . $HOME/.bashrc"
alias screenshot='import -window root'
alias btphones="echo -e 'power on\nconnect 28:9A:4B:20:07:16\nquit' | bluetoothctl"

#highlight () { grep --color -E "$1|$" "${@:2}" ;  }

