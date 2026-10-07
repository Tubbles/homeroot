#!/usr/bin/env bash

# update.sh - Update everything on this machine: the OS package manager first,
# then the third party stores that are installed (AUR helper, flatpak, snap,
# brew), then machine local extras from an update.local.sh next to this script.
#
# Usage:
#     update.sh [--check | --help]
#
#     --check     Run the preflight only: show which steps would run and why
#                 the others are skipped, then exit.
#
# Refuses to run as root. Steps that need root elevate themselves with the first
# of sudo, doas, run0 or su that is installed.
#
# Output is mirrored to the system log through logger(1) when available, so on
# systemd machines `journalctl -t update.sh` shows earlier runs.
#
# Every step runs in its own subshell with `set -e`. A failing step is reported
# and the run continues, the post hook always runs, and the exit status is 1 if
# any step failed.
#
# Local hooks: an optional update.local.sh in the same directory as this script
# is sourced during preflight and may define any of these functions:
#
#     update_pre      Runs before anything else (eg. remount root read-write).
#     update_local    Runs after the package stores (eg. git pulls, AppImage
#                     downloads, docker pull and restart).
#     update_post     Runs last, even when an earlier step failed (eg. remount
#                     root read-only).
#
# and may set
#
#     update_local_requires="docker git"
#
# naming tools the hooks need. If any is missing, all hooks are skipped with a
# warning. Hooks can call `elevate <command>` for root and `have <tool>` for
# tool checks. Variables do not carry over between hooks since each runs in a
# subshell.
#
# Package managers run non-interactively (-y, --noconfirm) but keep stdin, so
# dpkg conffile questions still reach you in the terminal.

set -euo pipefail

script_directory="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
local_hooks_file="${script_directory}/update.local.sh"
log_tag="update.sh"

info() { echo "$*"; }
warn() { echo "warning: $*" >&2; }
die() { echo "error: $*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# Privilege elevation ----------------------------------------------------------

elevation_tool=""
for candidate in sudo doas run0 su; do
    if have "$candidate"; then
        elevation_tool="$candidate"
        break
    fi
done

elevate() {
    case "$elevation_tool" in
        "") die "no elevation tool (sudo, doas, run0, su) found" ;;
        su) su root -c "$(printf '%q ' "$@")" ;;
        *) "$elevation_tool" "$@" ;;
    esac
}

# Steps ------------------------------------------------------------------------

os_package_manager=""
for candidate in apt-get dnf pacman zypper; do
    if have "$candidate"; then
        os_package_manager="$candidate"
        break
    fi
done

aur_helper=""
for candidate in paru yay; do
    if have "$candidate"; then
        aur_helper="$candidate"
        break
    fi
done

step_os() {
    case "$os_package_manager" in
        apt-get)
            elevate apt-get update
            elevate apt-get dist-upgrade -y
            ;;
        dnf)
            elevate dnf upgrade --refresh -y
            ;;
        pacman)
            elevate pacman -Syu --noconfirm
            ;;
        zypper)
            elevate zypper --non-interactive refresh
            elevate zypper --non-interactive update
            ;;
    esac
}

# The AUR helper calls sudo on its own for the pacman part, so it runs as the
# user. -Sua limits it to AUR packages since step_os already did the repos.
step_aur() { "$aur_helper" -Sua --noconfirm; }
step_flatpak_system() { elevate flatpak update -y --system; }
step_flatpak_user() { flatpak update -y --user; }
step_snap() { elevate snap refresh; }
step_brew() {
    brew update
    brew upgrade
}
step_hook_pre() { update_pre; }
step_hook_local() { update_local; }
step_hook_post() { update_post; }

# Preflight --------------------------------------------------------------------

planned_steps=()
hooks_enabled=""

# plan_step <name> <root|user> <tool> <function>
plan_step() {
    local name="$1" needs_root="$2" tool="$3" function="$4"
    if [[ -z "$tool" ]] || ! have "$tool"; then
        info "  ${name}: skipped, not installed"
        return
    fi
    if [[ "$needs_root" == root && -z "$elevation_tool" ]]; then
        warn "${name}: skipped, needs root but no elevation tool (sudo, doas, run0, su) found"
        return
    fi
    info "  ${name}: ${tool}"
    planned_steps+=("${name}:${function}")
}

plan_hooks() {
    if [[ ! -f "$local_hooks_file" ]]; then
        info "  local hooks: none (${local_hooks_file} not found)"
        return
    fi
    # shellcheck source=/dev/null
    source "$local_hooks_file"
    local missing_tools=""
    local tool
    for tool in ${update_local_requires:-}; do
        have "$tool" || missing_tools+=" ${tool}"
    done
    if [[ -n "$missing_tools" ]]; then
        warn "local hooks: skipped, missing tool(s):${missing_tools}"
        return
    fi
    local defined_hooks=""
    local hook
    for hook in update_pre update_local update_post; do
        declare -F "$hook" >/dev/null && defined_hooks+=" ${hook}"
    done
    info "  local hooks: ${local_hooks_file} (${defined_hooks# })"
    hooks_enabled=yes
}

preflight() {
    info "update.sh preflight"
    info "  elevation: ${elevation_tool:-none}"
    if have logger; then
        info "  logging: logger (journalctl -t ${log_tag})"
    else
        warn "logging: logger not found, output is not mirrored to the system log"
    fi
    if [[ -z "$os_package_manager" ]]; then
        warn "os: skipped, no supported package manager (apt-get, dnf, pacman, zypper) found"
    else
        plan_step os root "$os_package_manager" step_os
    fi
    plan_step aur user "$aur_helper" step_aur
    plan_step flatpak-system root flatpak step_flatpak_system
    plan_step flatpak-user user flatpak step_flatpak_user
    plan_step snap root snap step_snap
    plan_step brew user brew step_brew
    plan_hooks
}

# Run --------------------------------------------------------------------------

failed_steps=()

# run_step <name> <function>
run_step() {
    local name="$1" function="$2"
    info "==> ${name}"
    set +e
    ( set -e; "$function" )
    local status=$?
    set -e
    if [[ $status -ne 0 ]]; then
        warn "${name}: failed with status ${status}"
        failed_steps+=("$name")
    fi
}

# run_hook <name> <function> - only when the hooks file defines the function
run_hook() {
    local name="$1" function="$2"
    [[ -n "$hooks_enabled" ]] || return 0
    declare -F "$function" >/dev/null || return 0
    run_step "$name" "step_hook_${name#hook-}"
}

main() {
    preflight
    if [[ "$check_only" == yes ]]; then
        return
    fi
    if [[ "$elevation_tool" == sudo && "${planned_steps[*]}" == *:step_os* ]]; then
        sudo -v || die "sudo authentication failed"
    fi
    run_hook hook-pre update_pre
    local step
    for step in "${planned_steps[@]}"; do
        run_step "${step%%:*}" "${step#*:}"
    done
    run_hook hook-local update_local
    run_hook hook-post update_post
    if [[ ${#failed_steps[@]} -gt 0 ]]; then
        warn "failed steps: ${failed_steps[*]}"
        return 1
    fi
    info "all steps done"
}

check_only=no
case "${1:-}" in
    "") ;;
    --check) check_only=yes ;;
    -h | --help | help)
        sed -n '3,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
        exit 0
        ;;
    *) die "unknown argument: $1 (try --help)" ;;
esac

if [[ $EUID -eq 0 ]]; then
    die "do not run as root, steps that need root elevate themselves"
fi

if [[ "$check_only" == no ]] && have logger; then
    main 2>&1 | tee >(logger -t "$log_tag")
else
    main
fi
