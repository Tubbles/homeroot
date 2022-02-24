#
# $HOME/.bash_profile
#

source "${HOME}/.install/bash_env.source"

__prepend_dir_to_path_smart "$HOME/bin"
__prepend_dir_to_path_smart "$HOME/.local/bin"
__prepend_dir_to_path_smart "$HOME/.bin"

__prepend_dir_to_path_smart_before "$HOME/.cargo/bin" "/usr/games"

__append_dir_to_path_smart  "/usr/share/doc/git/contrib/diff-highlight"
__append_dir_to_path_smart  "/usr/share/git/diff-highlight/" # Some distros use this instead

__source_if_exists "$HOME/.bashrc"
__source_if_exists "$HOME/.bash_extra"
