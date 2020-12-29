#
# ${HOME}/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set correct umask
umask 002

# Find our system
if [[ -z "${MSYSTEM}" ]] ; then
    case "$(uname -o)" in
        "GNU/Linux")
            case "$(cat /etc/*-release | grep ^NAME | awk -F'[="]' '{print $3}')" in
                "Arch Linux")
                    MSYSTEM="Arch_Linux"
                    ;;
                "Manjaro Linux")
                    MSYSTEM="Manjaro_Linux"
                    ;;
                "Raspbian GNU/Linux")
                    MSYSTEM="Raspbian_GNU_Linux"
                    ;;
                *)
                    echo -e "Warning: Unknown linux system: $(cat /etc/*-release | grep ^NAME | awk -F'[="]' '{print $3}')"
                    ;;
            esac
            ;;
        *)
            echo -e "Warning: Unknown system"
            ;;
    esac
fi

export VISUAL=vim
export EDITOR=vim

export PATH="${HOME}/bin:${PATH}"

# Read in git specific scripts
test -r ${HOME}/.git-completion.bash && . ${HOME}/.git-completion.bash
test -r ${HOME}/.git-prompt.sh && . ${HOME}/.git-prompt.sh

export PS1='\[\e[37m\][$?] `date +%y%m%d-%H%M%S`\n\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]${MSYSTEM:+${MSYSTEM} }\[\e[0m\]\[\e[33m\]\w\[\e[36m\]`__git_ps1`\[\e[0m\]\n\$ \[`tput smkx`\]'

alias gst='(git fetch --all --prune 2>/dev/null && git lold --color=always -10 && echo "---" && git loll --color=always -10 && git branch -vv --color=always && git -c color.status=always status -s) | less -RFX'
alias reload='test -r ${HOME}/.bashrc && . ${HOME}/.bashrc'
alias ls='LC_COLLATE=C ls -b --group-directories-first'
alias l='ls -Fhl --color --time-style=+%y%m%d-%H%M%S'
alias lm='l -ct'
alias ll='l -A'
alias llm='ll -ct'
alias path='echo $PATH | tr ":" "\n"'
alias less='less -FRX'
alias grep='grep --color=auto'
alias jgrep='find . -type f -print0 | xargs -0 grep -nE'
alias todec='printf "%d\n"'
alias tohex='printf "%X\n"'
#alias dog='highlight -s solarized-dark --force=sh -O xterm256'
alias screenshot="import -window root ${HOME}/tmp/prtsc_"'$(date +%y%m%d_%H%M%S_%N).png'
alias btphones="echo -e 'power on\nconnect 28:9A:4B:20:07:16\nquit' | bluetoothctl"
alias tmux='tmux -2'
alias vlc='QT_AUTO_SCREEN_SCALE_FACTOR=0 vlc'
alias r='source ranger'
alias localnet='for i in $(seq 1 1 254) ; do ip=192.168.1.$i ; ans="$(dig -x $ip +short)" ; if [[ -n "$ans" ]] ; then echo "$ip: ${ans::-1}" ; fi ; done'
alias git-recurse='for dir in `find . -type d -name ".git"` ; do cd `dirname $dir` ; pwd ; git status -s ; cd - > /dev/null; done'

# Set up the dog alias
highlight_above_353=false
if [[ $(command -v highlight) ]] ; then
    # Check correct version, needs to be equal to or above 3.53
    if (( $(highlight --version | grep " highlight version " | sed -E 's/ highlight version ([0-9]+)\.([0-9]+)/\1/g') > 3 )) ; then
        highlight_above_353=true
    else
        if (( $(highlight --version | grep " highlight version " | sed -E 's/ highlight version ([0-9]+)\.([0-9]+)/\1/g') == 3 )) ; then
            if (( $(highlight --version | grep " highlight version " | sed -E 's/ highlight version ([0-9]+)\.([0-9]+)/\2/g') >= 53 )) ; then
                highlight_above_353=true
            fi
        fi
    fi
fi

if [[ "${highlight_above_353}" == "true" ]] ; then
    alias dog='highlight -s solarized-dark --force=sh -O xterm256'
else
    alias dog='highlight -s solarized-dark --force -O xterm256'
fi

#highlight () { grep --color -E "$1|$" "${@:2}" ;  }

# Start startx automatically on logon
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

# Now load system specific files
file="${HOME}/.config/bashrc.d/os_name_${MSYSTEM}"
test -r ${file} && . ${file}
unset file

spawn() {
    # { nohup "$@" < /dev/null > /dev/null 2>&1 & disown ; } > /dev/null 2>&1
    ("$@" &)
}
