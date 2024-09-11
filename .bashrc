#!/bin/bash
# ${HOME}/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source global definitions
if [[ -f "/etc/bashrc" ]]; then
    # shellcheck disable=SC1091
    source "/etc/bashrc"
fi

# Source local macros
# shellcheck disable=SC1091
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
# shopt -s direxpand

# Don't put duplicate lines in the history.
export HISTCONTROL=ignoredups:erasedups

# Increase the size of the history
# export HISTSIZE=100000
# export HISTFILESIZE=100000

# Make the history infinite
export HISTSIZE=-1
export HISTFILESIZE=-1

# Save and reload the history after each command finishes
# export PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"

# Save the history after each command finishes
export PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"

# Set up ls colors
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=31;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'
export LS_COLORS

# Find our system
if [[ -z "${MSYSTEM}" ]]; then
    case "$(uname -o)" in
    "GNU/Linux")
        MSYSTEM="$(cat /etc/*release | grep DISTRIB_DESCRIPTION | awk -F'"' '{print $2}')"
        ;;
    *)
        echo -e "Warning: Unknown system"
        ;;
    esac
fi

# If we did not start with systemd or similar
if [[ -z "${XDG_RUNTIME_DIR}" ]]; then
    export XDG_RUNTIME_DIR=/run/user/${UID}
    if [[ ! -d "${XDG_RUNTIME_DIR}" ]]; then
        export XDG_RUNTIME_DIR=/tmp/${USER}-runtime
        if [[ ! -d "${XDG_RUNTIME_DIR}" ]]; then
            mkdir -m 0700 "${XDG_RUNTIME_DIR}"
        fi
    fi
fi

# Fix for helix truecolor
export COLORTERM=truecolor
export VISUAL=hx
export EDITOR=hx

# Set up PATH and source other settings
__prepend_dir_to_path_smart "${HOME}/.local/bin"
__prepend_dir_to_path_smart "${HOME}/.bin"
__prepend_dir_to_path_smart "${HOME}/bin"

__prepend_dir_to_path_smart_before "${HOME}/.cargo/bin" "/usr/games"
__append_dir_to_path_smart "${HOME}/go/bin"

__append_dir_to_path_smart "/usr/share/doc/git/contrib/diff-highlight"
__append_dir_to_path_smart "/usr/share/git/diff-highlight/" # Some distros use this instead
__append_dir_to_path_smart "/usr/share/git-core/contrib/" # Some distros use this instead

__source_if_exists "${HOME}/.bash-preexec.sh"
__source_if_exists "${HOME}/.bash_extra"

# Read in git specific scripts
__source_if_exists "/usr/share/bash-completion/completions/git"
__source_if_exists "${HOME}/.git-completion.bash"
__source_if_exists "${HOME}/.git-prompt.sh"
__source_if_exists "${HOME}/.install/git-prompt.source"

PS1=''
PS1+='\[\e[37m\][$?] `date +%y%m%d-%H%M%S`\n\[\e]0;\w\a\]\n'
PS1+='\[\e[32m\]\u@\h '
PS1+='\[\e[35m\]${MSYSTEM:+${MSYSTEM} }'
PS1+='\[\e[0m\]'
PS1+='\[\e[33m\]\w'
PS1+='\[\e[36m\]`__git_ps1`'
PS1+='\[\e[33m\]`__indicate_git_stash`'
PS1+='\[\e[0m\]\n\$ \[`tput smkx`\]'

# Hotfix for the helix-editor caret issue (and possibly others?) https://github.com/helix-editor/helix/issues/2684
__caret() {
    printf '\e[6 q'
}

__reload() {
    # history
    history -a # save current
    history -c # clear current
    history -r # reload from disk

    # bash
    # __source_if_exists "${HOME}/.bash_profile"
    exec bash

    # # readline
    # test -r "${HOME}/.inputrc" && bind -f "${HOME}/.inputrc"
}

PS1+='\[`__caret`\]'
export PS1

alias gst='(/usr/bin/git fetch --all --prune 2>/dev/null && __git_auto_fast_forward && git lol --all --color=always -10 && echo "---" && git lol --color=always -10 && git branch -vv --color=always ; __gitmsg_print_pretty_title ; git -c color.status=always status -s) | less -FRX'
alias jst='(__git_local_10 && echo "---" && git lol --color=always -10 && git branch -vv --color=always ; __gitmsg_print_pretty_title ; git -c color.status=always status -s) | less -FRX'
alias wst='west status'
alias gau='git add -u'
alias gapu='git add -pu'
alias gd='git diff'
alias gdc='git diff --cached'
alias gcm='git commit -m'
alias jcm="__gitmsg_edit_msg_file"
alias jc="__gitmsg_commit"
alias reload='__reload'
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
alias screenshot="import -window root \${HOME}/tmp/prtsc_"'$(date +%y%m%d_%H%M%S_%N).png'
alias btphones="echo -e 'power on\nconnect 28:9A:4B:20:07:16\nquit' | bluetoothctl"
alias tmux='tmux -2'
alias vlc='QT_AUTO_SCREEN_SCALE_FACTOR=0 vlc'
alias r='source ranger'
# shellcheck disable=SC2154
alias localnet='for i in $(seq 1 1 254) ; do ip=192.168.1.$i ; ans="$(dig -x $ip +short)" ; if [[ -n "$ans" ]] ; then echo "$ip: ${ans::-1}" ; fi ; done'
# shellcheck disable=SC2154
alias git-recurse='for dir in `find . -type d -name ".git"` ; do cd `dirname $dir` ; pwd ; git status -s ; cd - > /dev/null; done'
alias lessp='LESSOPEN="|lesspipe.sh %s" less'
alias gitextra='git checkout origin/gitconfig_extra .gitconfig_extra && git reset .gitconfig_extra > /dev/null'
# shellcheck disable=SC2142
alias github="curl 'https://api.github.com/users/tubbles/repos?per_page=100' 2>/dev/null | grep 'clone_url' | awk -F'\"' '{print \$4}' | sort -f"
alias R='R --quiet --no-save'
alias bc='bc --quiet'
alias df='df -Thx squashfs'
alias xbanish='systemctl --user start xbanish'
alias battery='upower -e | grep battery | xargs -n 1 upower -i | grep -i --color=never -e percent -e native'
alias asciiclean="tr -dc '\\11\\12\\15\\40-\\176' <"
alias dimages="docker image ls -a | grep -v '<none>' | sort"
alias funcs='declare -F | grep -v "declare -f _" | sed "s,declare -f ,,g"  | sort'
alias caret="printf '\033[6 q'"
alias mousepager='xbindkeys --file ${HOME}/.xbindkeysrc-mousepager'
alias transparency='transset -tc 0.75'
alias gl='__git_list'
alias gaff='git fetch --all --prune && __git_auto_fast_forward && git bdrop'

if cat /etc/*release | sed 's,ID_LIKE=,,g' | grep -q arch; then
    alias transset='transset-df'
fi

test "$(command -v vscodium)" && alias code=vscodium
test "$(command -v helix)" && test ! "$(command -v hx)" && test ! -L "${HOME}/.local/bin/hx" && mkdir -p "${HOME}/.local/bin" && ln -s "$(command -v helix)" "${HOME}/.local/bin/hx"
test "$(command -v podman)" && test ! "$(command -v docker)" && alias docker=podman

# Set up the dog alias
highlight_above_353=false
if command -v highlight >/dev/null; then
    # Check correct version, needs to be equal to or above 3.53
    if (($(highlight --version | grep " highlight version " | sed -E 's/ highlight version ([0-9]+)\.([0-9]+)/\1/g') > 3)); then
        highlight_above_353=true
    else
        if (($(highlight --version | grep " highlight version " | sed -E 's/ highlight version ([0-9]+)\.([0-9]+)/\1/g') == 3)); then
            if (($(highlight --version | grep " highlight version " | sed -E 's/ highlight version ([0-9]+)\.([0-9]+)/\2/g') >= 53)); then
                highlight_above_353=true
            fi
        fi
    fi
fi

dog_theme="zenburn"
if [[ "${highlight_above_353}" == "true" ]]; then
    # shellcheck disable=SC2139
    alias dog="highlight -s ${dog_theme} --force=sh -O xterm256"
else
    # shellcheck disable=SC2139
    alias dog="highlight -s ${dog_theme} --force -O xterm256"
fi

# Find the custom python git-blame script
gbfile="git-blame-colored.py"
for path in ${PATH//:/ }; do
    if [[ -x "${path}/${gbfile}" ]] && command -v python3 >/dev/null; then
        # shellcheck disable=SC2139
        alias git-blame="python3 ${path}/${gbfile}"
        break
    fi
done

# Start startx automatically on logon
# shellcheck disable=SC2154
[[ -z ${DISPLAY} && ${XDG_VTNR} -eq 1 ]] && command -v startx >/dev/null && exec startx

# Load standard modules
# shellcheck disable=SC2044
for module in $(find "${HOME}/.config/bashrc.d" -type f -name 'module-*'); do
    # shellcheck disable=SC1090
    source "${module}"
done

# Now load system specific files
__source_if_exists "${HOME}/.config/bashrc.d/os_name_${MSYSTEM//[\/ ]/_}"
__source_if_exists "${HOME}/.config/bashrc.d/host_name_$(uname -n)"

spawn() {
    {
        nohup "$@" </dev/null >/dev/null 2>&1 &
        disown
    } >/dev/null 2>&1
}

sspawn() {
    sudo printf ""
    (
        sudo nohup "$@" </dev/null >/dev/null 2>&1 &
    ) >/dev/null 2>&1
}

start() {
    {
        nohup xdg-open "$@" </dev/null >/dev/null 2>&1 &
        disown
    } >/dev/null 2>&1
}

mkscript() {
    args=("$@")
    for arg in "${args[@]}"; do
        mkdir -p "$(dirname "${arg}")"
        touch "${arg}"
        chmod +x "${arg}"
    done
}

cdir() {
    mkdir -p "$1"
    cd "$1" || return
}

bfind() {
    local path="$1"
    if [[ ! -d "${path}" ]]; then
        path="$(pwd)"
    else
        shift 1
    fi

    local depth=0
    local maxdepth=0
    maxdepth=$(find "${path}" -type d | tr -dc '/\n' | awk '{print length}' | sort -r | head -n 1)
    while [[ ${depth} -le ${maxdepth} ]]; do
        find "${path}" -mindepth "${depth}" -maxdepth "${depth}" "$@"
        ((depth++))
    done
}

findup() {
    local path="$1"
    if [[ ! -d "${path}" ]]; then
        path="$(pwd)"
    else
        shift 1
    fi

    path="$(readlink -f "${path}")"
    while : ; do
        find "${path}" -maxdepth 1 -mindepth 1 "$@"
        if [[ "${path}" == "/" ]]; then
            find "${path}" -maxdepth 0 "$@"
            break
        fi
        # Note: if you want to ignore symlinks, use "$(realpath -s "${path}"/..)"
        path="$(readlink -f "${path}"/..)"
    done
}

trim_history() {
    # First do a backup!
    cp "${HOME}/.bash_history" "${HOME}/.bash_history.bak"

    # Remove some crusty patterns
    patterns=(
        ".vscode/extensions/ms-python.debugpy-2024.0.0-linux-x64/bundled/libs/debugpy/adapter/../../debugpy/launcher"
        ".vscode/extensions/ms-python.python-2023.14.0/pythonFiles/lib/python/debugpy/adapter/../../debugpy/launcher"
        ".vscode/extensions/ms-python.python-2024.0.1/pythonFiles/lib/python/debugpy/adapter/../../debugpy/launcher"
        "/usr/bin/env /bin/sh /tmp/Microsoft-MIEngine-Cmd-"
    )

    for pattern in "${patterns[@]}"; do
        sed -i "\#${pattern}#d" "${HOME}/.bash_history"
    done

    # Also remove dupes, preserving order but keeping the latest entry (to have the most recent history somewhat intact)
    tmp_file="$(mktemp)"
    trap 'rm -f ${tmp_file}; exit 1' SIGHUP SIGINT SIGQUIT SIGPIPE SIGTERM
    tac < "${HOME}/.bash_history" | awk '!seen[$0]++' | tac > "${tmp_file}"
    mv "${tmp_file}" "${HOME}/.bash_history"
    trap 0
}

__git_local_10() {
    # Word splitting intended
    # shellcheck disable=SC2046
    git lol --color=always -10 $(git branch | grep -v 'HEAD detached' | cut -c3- | paste -sd' ')
}

# Set up fzf
__source_if_exists "/usr/share/doc/fzf/examples/key-bindings.bash"
__source_if_exists "/usr/share/doc/fzf/examples/completion.bash"
__source_if_exists "/usr/share/fzf/key-bindings.bash"
__source_if_exists "/usr/share/fzf/completion.bash"
__source_if_exists "/mingw64/share/fzf/key-bindings.bash"
__source_if_exists "/mingw64/share/fzf/completion.bash"

# Default settings for ydiff
export YDIFF_OPTIONS=-w0

:
