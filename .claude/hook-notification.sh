#!/usr/bin/env bash
# Claude Code Notification hook dispatcher.
# stdin: hook event JSON (see https://docs.claude.com/en/docs/claude-code/hooks)
# Per-host branches let one checked-in settings.json behave differently on
# each machine. Per-machine secrets (e.g. NTFY_TOPIC) live in
# ~/.claude/hook-local.env, which is not committed. If that file is absent
# the hook is a silent no-op, so a fresh checkout never leaks notifications
# to the wrong place.

set -u

env_file="$HOME/.claude/hook-local.env"
# shellcheck disable=SC1090
[[ -r "$env_file" ]] && source "$env_file"

payload=$(cat)
message=$(printf '%s' "$payload" | jq -r '.message // "Claude needs your input"')

case "$(hostname)" in
    vaio)
        [[ -n "${NTFY_TOPIC:-}" ]] || exit 0
        curl -s \
            -H 'Title: Claude Code (input needed)' \
            -H 'Tags: bell' \
            -d "$message" \
            "https://ntfy.sh/${NTFY_TOPIC}" > /dev/null 2>&1 || true
        ;;
    *)
        # Unknown host: no-op so the hook never misbehaves on new machines.
        :
        ;;
esac
