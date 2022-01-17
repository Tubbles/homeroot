#
# $HOME/.bash_profile
#

__prepend_dir_to_path_smart() {
    [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

__append_dir_to_path_smart() {
    [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$PATH:$1"
}

__source_if_exists() {
    [[ -r "$1" ]] && source "$1"
}

__prepend_dir_to_path_smart "$HOME/bin"
__prepend_dir_to_path_smart "$HOME/.local/bin"
__prepend_dir_to_path_smart "$HOME/.bin"

__append_dir_to_path_smart  "/usr/share/doc/git/contrib/diff-highlight"
__append_dir_to_path_smart  "/usr/share/git/diff-highlight/" # Some distros use this instead

__source_if_exists "$HOME/.bashrc"

unset -f __source_if_exists
unset -f __prepend_dir_to_path_smart
unset -f __append_dir_to_path_smart

