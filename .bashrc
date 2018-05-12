#
# ${HOME}/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Read in git specific scripts
test -r ${HOME}/.git-completion.bash && . ${HOME}/.git-completion.bash
test -r ${HOME}/.git-prompt.sh && . ${HOME}/.git-prompt.sh

export PS1='\[\e[37m\][$?] `date +%y%m%d-%H%M%S`\n\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]$MSYSTEM\[\e[0m\] \[\e[33m\]\w\[\e[36m\]`__git_ps1`\[\e[0m\]\n\$ '

alias ls='LC_ALL=C ls -Fq --color --group-directories-first'
alias l='ls -lh --time-style=+%y%m%d-%H%M%S'
alias ll='l -A'
alias path='env | grep -E "^PATH=" | tr ":" "\n" | sed "s/PATH=//g"'
alias less='less -r'
alias grep='grep --color=always'
alias dog='highlight --force -O xterm256'
alias reload="test -r ${HOME}/.bashrc && . ${HOME}/.bashrc"
alias screenshot='import -window root'
alias tmux='tmux -2'

