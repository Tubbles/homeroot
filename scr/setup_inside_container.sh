#!/usr/bin/env bash

set -e

# After upgrading to podman > 4.0.0 hopefully this next line will no longer be needed
sudo usermod -d "${HOME}" "$(whoami)"

sudo apt update

# Install sanity
sudo apt install -y git less vim fzf

# Install locate
sudo apt install -y mlocate
sudo updatedb

# Install apt-file
sudo apt install -y apt-file
sudo apt-file update

sudo unminimize
sudo make -C "/usr/share/doc/git/contrib/diff-highlight" clean
sudo make -C "/usr/share/doc/git/contrib/diff-highlight" all
