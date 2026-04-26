#
# $HOME/.bash_profile
#

source "${HOME}/.install/bash_env.source"

__source_if_exists "${HOME}/.bashrc"

__source_if_exists "${HOME}/.nix-profile/etc/profile.d/nix.sh"
