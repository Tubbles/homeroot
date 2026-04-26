#!/bin/sh
# Install or refresh micro plugins by shallow-cloning their upstream
# repos at pinned tags. Idempotent: existing plugin directories are
# left alone (delete one to force a re-clone).

set -eu

PLUGDIR="${XDG_CONFIG_HOME:-$HOME/.config}/micro/plug"
mkdir -p "$PLUGDIR"

install_plugin() {
    name=$1
    repo=$2
    tag=$3
    target="$PLUGDIR/$name"
    if [ -d "$target" ]; then
        printf 'skip  %-12s already at %s\n' "$name" "$target"
        return
    fi
    printf 'clone %-12s %s @ %s\n' "$name" "$repo" "$tag"
    git clone --depth 1 --branch "$tag" "https://github.com/$repo.git" "$target"
}

install_plugin lsp         AndCake/micro-plugin-lsp          v0.6.3
install_plugin palettero   terokarvinen/palettero            v0.0.5
install_plugin aspell      priner/micro-aspell-plugin        v1.3.0
install_plugin filemanager NicolaiSoeborg/filemanager-plugin v3.4.0
