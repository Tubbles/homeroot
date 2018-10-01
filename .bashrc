#
# ${HOME}/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Read in git specific scripts
test -r ${HOME}/.git-completion.bash && . ${HOME}/.git-completion.bash
test -r ${HOME}/.git-prompt.sh && . ${HOME}/.git-prompt.sh

export PS1='\[\e[37m\][$?] `date +%y%m%d-%H%M%S`\n\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]${MSYSTEM:+${MSYSTEM} }\[\e[0m\]\[\e[33m\]\w\[\e[36m\]`__git_ps1`\[\e[0m\]\n\$ '

alias ls='LC_COLLATE=C ls -bF --color --group-directories-first'
alias l='ls -hl --time-style=+%y%m%d-%H%M%S'
alias lm='l -ct'
alias ll='l -A'
alias llm='ll -ct'
alias path='echo $PATH | tr ":" "\n"'
alias less='less -r'
alias grep='grep --color=always'
alias dog='highlight --force -O xterm256'
alias reload='NOCD=TRUE test -r ${HOME}/.bashrc && . ${HOME}/.bashrc'
#alias screenshot='import -window root'
alias screenshot="import -window root ${HOME}/tmp/prtsc_"'$(date +%y%m%d_%H%M%S_%N)'
alias btphones="echo -e 'power on\nconnect 28:9A:4B:20:07:16\nquit' | bluetoothctl"
alias tmux='tmux -2'
alias vlc='QT_AUTO_SCREEN_SCALE_FACTOR=0 vlc'
alias jgrep='find . -type f -print0 | xargs -0 grep -nE'

#highlight () { grep --color -E "$1|$" "${@:2}" ;  }

