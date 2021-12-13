#
# $HOME/.bash_profile
#

[[ -r $HOME/.bashrc ]] && . $HOME/.bashrc
[[ -d "$HOME/bin" ]] && PATH="$HOME/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
