#
# ${HOME}/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source global definitions
if [[ -f /etc/bashrc ]]; then
    source /etc/bashrc
fi

# Source local macros
source "${HOME}/.install/bash_env.source"

# Set correct umask
umask 002

# Remove Ctrl+S emulation
stty -ixon

# Make bash append rather than overwrite the history on disk
shopt -s histappend

# Make bash globbing smarter, even though it breaks POSIXly
#shopt -s nullglob
shopt -s extglob

# Expand path variables when tabbing instead of escaping them
shopt -s direxpand

# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups

# Set up ls colors
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=31;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

# Find our system
if [[ -z "${MSYSTEM}" ]] ; then
    case "$(uname -o)" in
        "GNU/Linux")
            MSYSTEM="$(cat /etc/*release | grep DISTRIB_DESCRIPTION | awk -F'"' '{print $2}')"
            ;;
        *)
            echo -e "Warning: Unknown system"
            ;;
    esac
fi

export VISUAL=vim
export EDITOR=vim

# Read in git specific scripts
test -r ${HOME}/.git-completion.bash && . ${HOME}/.git-completion.bash
test -r ${HOME}/.git-prompt.sh && . ${HOME}/.git-prompt.sh

export PS1='\[\e[37m\][$?] `date +%y%m%d-%H%M%S`\n\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]${MSYSTEM:+${MSYSTEM} }\[\e[0m\]\[\e[33m\]\w\[\e[36m\]`__git_ps1`\[\e[0m\]\n\$ \[`tput smkx`\]'

alias gst='(git fetch --all --prune 2>/dev/null && git lol --all --color=always -10 && echo "---" && git lol --color=always -10 && git branch -vv --color=always && git branch --color=never -rvv --color=always | grep -v "all/" ; git -c color.status=always status -s) | less -FRX'
alias jst='(git lol --all --color=always -10 && echo "---" && git lol --color=always -10 && git branch -vv --color=always && git branch --color=never -rvv --color=always | grep -v "all/" ; git -c color.status=always status -s) | less -FRX'
alias reload='test -r ${HOME}/.bash_profile && . ${HOME}/.bash_profile'
alias ls='LC_COLLATE=C ls -b --group-directories-first'
alias l='ls -Fhl --color --time-style=+%y%m%d-%H%M%S'
alias lm='l -ct'
alias ll='l -A'
alias llm='ll -ct'
alias path='echo $PATH | tr ":" "\n"'
alias less='less -FNMRX'
alias grep='grep --color=auto'
alias jgrep='find . -type f -print0 | xargs -0 grep -nE'
alias todec='printf "%d\n"'
alias tohex='printf "%X\n"'
alias screenshot="import -window root ${HOME}/tmp/prtsc_"'$(date +%y%m%d_%H%M%S_%N).png'
alias btphones="echo -e 'power on\nconnect 28:9A:4B:20:07:16\nquit' | bluetoothctl"
alias tmux='tmux -2'
alias vlc='QT_AUTO_SCREEN_SCALE_FACTOR=0 vlc'
alias r='source ranger'
alias localnet='for i in $(seq 1 1 254) ; do ip=192.168.1.$i ; ans="$(dig -x $ip +short)" ; if [[ -n "$ans" ]] ; then echo "$ip: ${ans::-1}" ; fi ; done'
alias git-recurse='for dir in `find . -type d -name ".git"` ; do cd `dirname $dir` ; pwd ; git status -s ; cd - > /dev/null; done'
alias lessp='LESSOPEN="|lesspipe.sh %s" less'
alias start='xdg-open'
alias gitextra='git checkout origin/gitconfig_extra .gitconfig_extra && git reset .gitconfig_extra > /dev/null'
alias github="curl 'https://api.github.com/users/tubbles/repos?per_page=100' 2>/dev/null | grep 'clone_url' | awk -F'\"' '{print \$4}' | sort -f"
alias R='R --quiet --no-save'
alias bc='bc --quiet'
alias df='df -Thx squashfs'
alias xbanish='systemctl --user start xbanish'
alias battery='upower -e | grep battery | xargs -n 1 upower -i | grep -i --color=never -e percent -e native'
alias asciiclean="tr -dc '\\11\\12\\15\\40-\\176' <"
alias git-repo-public='git config user.name Tubbles ; git config user.email "jae91m@gmail.com"'
alias git-repo-internal='git config --unset user.name ; git config --unset user.email'

test $(command -v vscodium) && alias code=vscodium

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

dog_theme="zenburn"
if [[ "${highlight_above_353}" == "true" ]] ; then
    alias dog='highlight -s ${dog_theme} --force=sh -O xterm256'
else
    alias dog='highlight -s ${dog_theme} --force -O xterm256'
fi

#highlight () { grep --color -E "$1|$" "${@:2}" ;  }

# Find the custom python git-blame script
gbfile="git-blame-colored.py"
for path in ${PATH//:/ }; do
    if [[ -x "${path}/${gbfile}" ]] && [[ $(command -v python3) ]] ; then
        alias git-blame="python3 ${path}/${gbfile}"
        break
    fi
done

# Start startx automatically on logon
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

# Now load system specific files
__source_if_exists "${HOME}/.config/bashrc.d/os_name_${MSYSTEM//[\/ ]/_}"

spawn() {
    { nohup "$@" < /dev/null > /dev/null 2>&1 & disown ; } > /dev/null 2>&1
    # ("$@" &)
}

# Set up atuin
command -v atuin >/dev/null && eval "$(atuin init bash)"
