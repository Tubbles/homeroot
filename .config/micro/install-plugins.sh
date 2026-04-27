#!/usr/bin/env bash
# Install, update, or no-op micro plugins to match the pinned versions below.
#
# Two source types are supported. To switch a plugin between them, change the
# function name in the manifest at the bottom (the args are documented per fn).
#
#   git_sync_plugin <name> <repo> <tag>   shallow clone of github.com/<repo>
#   zip_sync_plugin <name> <url>          download and extract a zip archive
#
# git_sync_plugin:
# - Missing plugins are shallow-cloned at the pinned tag.
# - Plugins already at the pinned tag are left alone.
# - Plugins on a different tag are fetched and checked out.
# - Plugins with uncommitted local changes are skipped (resolve manually).
#
# zip_sync_plugin:
# - Missing plugins are downloaded, extracted into the plug dir, and the zip
#   archive itself is discarded.
# - Plugins already at the pinned url (per stamp file) are left alone.
# - Plugins at a different url are removed and reinstalled.
# - Plugins that exist but were not installed via zip are skipped (resolve
#   manually, e.g. by deleting the directory before re-running).

set -euo pipefail

PLUGDIR="${XDG_CONFIG_HOME:-$HOME/.config}/micro/plug"
mkdir -p "$PLUGDIR"

git_sync_plugin() {
    local name=$1 repo=$2 tag=$3
    local target="$PLUGDIR/$name"
    local url="https://github.com/$repo.git"
    local current

    if [[ ! -d $target/.git ]]; then
        if [[ -e $target ]]; then
            printf 'skip   %-12s %s exists but is not a git checkout\n' "$name" "$target"
            return
        fi
        printf 'clone  %-12s %s @ %s\n' "$name" "$repo" "$tag"
        git clone --quiet --depth 1 --branch "$tag" "$url" "$target"
        return
    fi

    current=$(git -C "$target" describe --tags --exact-match 2>/dev/null || true)

    if [[ $current == "$tag" ]]; then
        printf 'ok     %-12s already at %s\n' "$name" "$tag"
        return
    fi

    if [[ -n $(git -C "$target" status --porcelain) ]]; then
        printf 'skip   %-12s uncommitted local changes in %s\n' "$name" "$target"
        return
    fi

    printf 'update %-12s %s -> %s\n' "$name" "${current:-unknown}" "$tag"
    git -C "$target" fetch --quiet --depth 1 origin "refs/tags/$tag:refs/tags/$tag"
    git -C "$target" checkout --quiet "$tag"
}

zip_sync_plugin() {
    local name=$1 url=$2
    local target="$PLUGDIR/$name"
    local stamp="$target/.zip-source"
    local tmpdir zipfile extract_dir
    local -a fetch_cmd top_entries

    if [[ -e $target && ! -f $stamp ]]; then
        printf 'skip   %-12s %s exists but was not installed via zip\n' "$name" "$target"
        return
    fi

    if [[ -f $stamp && $(< "$stamp") == "$url" ]]; then
        printf 'ok     %-12s already at %s\n' "$name" "$url"
        return
    fi

    if ! command -v unzip &>/dev/null; then
        printf 'skip   %-12s unzip not installed\n' "$name"
        return
    fi

    if command -v curl &>/dev/null; then
        fetch_cmd=(curl --fail --silent --show-error --location --output)
    elif command -v wget &>/dev/null; then
        fetch_cmd=(wget --quiet --output-document)
    else
        printf 'skip   %-12s neither curl nor wget installed\n' "$name"
        return
    fi

    if [[ -e $target ]]; then
        printf 'update %-12s -> %s\n' "$name" "$url"
    else
        printf 'fetch  %-12s %s\n' "$name" "$url"
    fi

    tmpdir=$(mktemp -d)
    zipfile="$tmpdir/plugin.zip"
    extract_dir="$tmpdir/extract"

    "${fetch_cmd[@]}" "$zipfile" "$url"
    unzip -q "$zipfile" -d "$extract_dir"
    rm -f "$zipfile"

    rm -rf "$target"

    # If the archive has a single top-level directory, use it as the plugin
    # root; otherwise treat the extract dir itself as the root.
    shopt -s nullglob dotglob
    top_entries=("$extract_dir"/*)
    shopt -u nullglob dotglob
    if (( ${#top_entries[@]} == 1 )) && [[ -d ${top_entries[0]} ]]; then
        mv "${top_entries[0]}" "$target"
    else
        mv "$extract_dir" "$target"
    fi

    printf '%s' "$url" > "$stamp"
    rm -rf "$tmpdir"
}

git_sync_plugin lsp         AndCake/micro-plugin-lsp v0.6.3
git_sync_plugin palettero   terokarvinen/palettero   v0.0.5
git_sync_plugin aspell      priner/micro-aspell-plugin v1.3.0
zip_sync_plugin filemanager https://github.com/micro-editor/updated-plugins/releases/download/v1.0.0/filemanager-3.5.1.zip
