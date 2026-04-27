#!/bin/sh
# Install, update, or no-op micro plugins to match the pinned tags below.
# - Missing plugins are shallow-cloned at the pinned tag.
# - Plugins already at the pinned tag are left alone.
# - Plugins on a different tag are fetched and checked out.
# - Plugins with uncommitted local changes are skipped (resolve manually).

set -eu

PLUGDIR="${XDG_CONFIG_HOME:-$HOME/.config}/micro/plug"
mkdir -p "$PLUGDIR"

sync_plugin() {
    name=$1
    repo=$2
    tag=$3
    target="$PLUGDIR/$name"
    url="https://github.com/$repo.git"

    if [ ! -d "$target/.git" ]; then
        if [ -e "$target" ]; then
            printf 'skip   %-12s %s exists but is not a git checkout\n' "$name" "$target"
            return
        fi
        printf 'clone  %-12s %s @ %s\n' "$name" "$repo" "$tag"
        git clone --quiet --depth 1 --branch "$tag" "$url" "$target"
        return
    fi

    current=$(git -C "$target" describe --tags --exact-match 2>/dev/null || echo '')

    if [ "$current" = "$tag" ]; then
        printf 'ok     %-12s already at %s\n' "$name" "$tag"
        return
    fi

    if [ -n "$(git -C "$target" status --porcelain)" ]; then
        printf 'skip   %-12s uncommitted local changes in %s\n' "$name" "$target"
        return
    fi

    printf 'update %-12s %s -> %s\n' "$name" "${current:-unknown}" "$tag"
    git -C "$target" fetch --quiet --depth 1 origin "refs/tags/$tag:refs/tags/$tag"
    git -C "$target" checkout --quiet "$tag"
}

sync_plugin lsp         AndCake/micro-plugin-lsp          v0.6.3
sync_plugin palettero   terokarvinen/palettero            v0.0.5
sync_plugin aspell      priner/micro-aspell-plugin        v1.3.0
sync_plugin filemanager NicolaiSoeborg/filemanager-plugin v3.4.0
