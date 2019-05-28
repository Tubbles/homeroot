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

export PATH="${HOME}/bin:${PATH}"

# Read in git specific scripts
test -r ${HOME}/.git-completion.bash && . ${HOME}/.git-completion.bash
test -r ${HOME}/.git-prompt.sh && . ${HOME}/.git-prompt.sh

export PS1='\[\e[37m\][$?] `date +%y%m%d-%H%M%S`\n\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]${MSYSTEM:+${MSYSTEM} }\[\e[0m\]\[\e[33m\]\w\[\e[36m\]`__git_ps1`\[\e[0m\]\n\$ '

alias gst='(git fetch --all 2>/dev/null && git lold --color=always -10 && echo "---" && git loll --color=always -10 && git branch -vv --color=always && git -c color.status=always status -s) | less -RFX'
alias reload='test -r ${HOME}/.bashrc && . ${HOME}/.bashrc'
alias ls='LC_COLLATE=C ls -bF --color --group-directories-first'
alias l='ls -hl --time-style=+%y%m%d-%H%M%S'
alias lm='l -ct'
alias ll='l -A'
alias llm='ll -ct'
alias path='echo $PATH | tr ":" "\n"'
alias less='less -FRX'
alias grep='grep --color=auto'
alias jgrep='find . -type f -print0 | xargs -0 grep -nE'
alias todec='printf "%d\n"'
alias tohex='printf "%X\n"'
alias dog='highlight -s solarized-dark --force -O xterm256'
alias screenshot="import -window root ${HOME}/tmp/prtsc_"'$(date +%y%m%d_%H%M%S_%N).png'
alias btphones="echo -e 'power on\nconnect 28:9A:4B:20:07:16\nquit' | bluetoothctl"
alias tmux='tmux -2'
alias vlc='QT_AUTO_SCREEN_SCALE_FACTOR=0 vlc'

#highlight () { grep --color -E "$1|$" "${@:2}" ;  }

# Start startx automatically on logon
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

# Now load system specific files
file="${HOME}/.config/bashrc.d/os_name_${MSYSTEM}"
test -r ${file} && . ${file}
unset file

