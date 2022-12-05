#!/bin/bash

set -ex

sudo steamos-readonly disable

sudo pacman-key --init
sudo pacman-key --populate archlinux

packages=(
    "atool"
    "base-devel"
    "fontconfig"
    "freetype2"
    "fzf"
    "gcc"
    "glibc"
    "highlight"
    "holo/linux-headers"
    "holo/linux-lts-headers"
    "imlib2"
    "librender"
    "libx11"
    "libxft"
    "libxrender"
    "linux-api-headers"
    "linux-neptune-headers"
    "lld"
    "lldb"
    "lynx"
    "mlocate"
    "ranger"
    "rust-analyzer-nightly-bin"
    "rustup"
    "tmux"
    "w3m"
    "xorgproto"
)

yay -S ${packages[@]}
rustup toolchain install nightly
yay -S helix-git
