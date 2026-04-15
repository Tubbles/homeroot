#!/usr/bin/env bash
# Claude Code statusLine script
# Shows PS1-style info + Claude metadata + cache window approximation

input=$(cat)

# --- PS1 section ---

# Date/time in grey
printf '\e[37m%s\e[0m ' "$(date +%y%m%d-%H%M%S)"

# user@host in green
printf '\e[32m%s@%s\e[0m ' "$(whoami)" "$(hostname -s)"

# Working directory in yellow
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty' 2>/dev/null)
if [ -z "$cwd" ]; then
    cwd="$PWD"
fi
printf '\e[33m%s\e[0m' "$cwd"

# Git branch in cyan
git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
if [ -z "$git_branch" ]; then
    git_branch=$(git -C "$cwd" --no-optional-locks describe --tags --exact-match HEAD 2>/dev/null)
fi
if [ -z "$git_branch" ]; then
    git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi
if [ -n "$git_branch" ]; then
    printf ' \e[36m(%s)\e[0m' "$git_branch"
fi

# Stash indicator
stash_count=$(git -C "$cwd" --no-optional-locks stash list 2>/dev/null | wc -l)
if [ "$stash_count" -gt 0 ] 2>/dev/null; then
    printf '\e[33m$\e[0m'
fi

printf '\n'

# --- Model + Context ---

model=$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // "?"')
ctx_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // "?"')
ctx_size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // 0')
ctx_size_k=$((ctx_size / 1000))

printf '\e[1;35m[%s]\e[0m ' "$model"
# Context bar
if [ "$ctx_pct" != "?" ] && [ "$ctx_pct" -ge 0 ] 2>/dev/null; then
    filled=$((ctx_pct / 5))
    empty=$((20 - filled))
    if [ "$ctx_pct" -lt 70 ]; then
        bar_color='\e[32m'  # green
    elif [ "$ctx_pct" -lt 85 ]; then
        bar_color='\e[33m'  # yellow
    else
        bar_color='\e[31m'  # red
    fi
    bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    printf "${bar_color}%s\e[0m %s%% of %sk" "$bar" "$ctx_pct" "$ctx_size_k"
else
    printf '? %%'
fi

printf '\n'

# --- Token breakdown ---

in_tok=$(printf '%s' "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
out_tok=$(printf '%s' "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
cache_create=$(printf '%s' "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(printf '%s' "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
total_in=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(printf '%s' "$input" | jq -r '.context_window.total_output_tokens // 0')

# Format token counts (e.g. 37600 -> 37.6k)
fmt_tok() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        printf '%s.%sM' "$((n / 1000000))" "$(( (n % 1000000) / 100000 ))"
    elif [ "$n" -ge 1000 ]; then
        printf '%s.%sk' "$((n / 1000))" "$(( (n % 1000) / 100 ))"
    else
        printf '%s' "$n"
    fi
}

printf '\e[37min:\e[0m%s \e[37mout:\e[0m%s' " $(fmt_tok "$in_tok")" " $(fmt_tok "$out_tok")"
printf ' \e[37m│\e[0m \e[32mcache-read:\e[0m%s \e[33mcache-write:\e[0m%s' " $(fmt_tok "$cache_read")" " $(fmt_tok "$cache_create")"
printf ' \e[37m│\e[0m \e[37mtotal(in:\e[0m%s \e[37mout:\e[0m%s\e[37m)\e[0m' " $(fmt_tok "$total_in")" " $(fmt_tok "$total_out")"
printf '\n'

# --- Cache window approximation ---
# State file format: "expiry_epoch last_cache_create last_cache_read"
# Only reset the timer when token counts change (new API call happened).
# Cache miss: cache_creation > 0 && cache_read == 0.
# TTL is read from ~/.claude/statusline.conf (cache_ttl_seconds=N), default 300.

cache_ttl=300
conf_file="/home/tubbles/.claude/statusline.conf"
if [ -f "$conf_file" ]; then
    val=$(grep -m1 '^cache_ttl_seconds=' "$conf_file" | cut -d= -f2)
    if [ -n "$val" ] && [ "$val" -gt 0 ] 2>/dev/null; then
        cache_ttl=$val
    fi
fi

cache_state_file="/home/tubbles/tmp/.statusline-cache-state"
now=$(date +%s)
cache_miss=0

# Read previous state
prev_expiry=0
prev_create=0
prev_read=0
if [ -f "$cache_state_file" ]; then
    read -r prev_expiry prev_create prev_read < "$cache_state_file"
fi

# Check if cache token counts changed (means a new API call happened)
if [ "$cache_create" != "$prev_create" ] || [ "$cache_read" != "$prev_read" ]; then
    # New API response — reset the timer
    expiry=$((now + cache_ttl))
    printf '%s %s %s' "$expiry" "$cache_create" "$cache_read" > "$cache_state_file"

    # Detect cache miss: created tokens but nothing read from cache
    if [ "$cache_create" -gt 0 ] && [ "$cache_read" -eq 0 ]; then
        cache_miss=1
    fi
else
    expiry=$prev_expiry
fi

printf '\e[37mcache-window:\e[0m %ss' "$cache_ttl"
if [ "$cache_miss" -eq 1 ]; then
    printf ' \e[37m│\e[0m \e[1;31mCACHE MISS\e[0m'
fi
if [ "$expiry" -gt 0 ]; then
    if [ "$now" -lt "$expiry" ]; then
        expiry_str=$(date -d "@$expiry" +%H:%M:%S)
        printf ' \e[37m│\e[0m \e[36mcache-expires:\e[0m %s' "$expiry_str"
    else
        printf ' \e[37m│\e[0m \e[31mcache: expired\e[0m'
    fi
fi

printf '\n'

# --- Cost + session ---

cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(printf '%s' "$input" | jq -r '.cost.total_duration_ms // 0')
api_ms=$(printf '%s' "$input" | jq -r '.cost.total_api_duration_ms // 0')
lines_add=$(printf '%s' "$input" | jq -r '.cost.total_lines_added // 0')
lines_rm=$(printf '%s' "$input" | jq -r '.cost.total_lines_removed // 0')
version=$(printf '%s' "$input" | jq -r '.version // "?"')

# Format duration
fmt_dur() {
    local ms=$1
    local secs=$((ms / 1000))
    if [ "$secs" -ge 3600 ]; then
        printf '%dh%02dm' "$((secs / 3600))" "$(( (secs % 3600) / 60 ))"
    elif [ "$secs" -ge 60 ]; then
        printf '%dm%02ds' "$((secs / 60))" "$((secs % 60))"
    else
        printf '%ds' "$secs"
    fi
}

printf '\e[37m$\e[1;33m%.4f\e[0m' "$cost"
printf ' \e[37msession:\e[0m%s' " $(fmt_dur "$duration_ms")"
printf ' \e[37mapi:\e[0m%s' " $(fmt_dur "$api_ms")"
printf ' \e[32m+%s\e[0m/\e[31m-%s\e[0m lines' "$lines_add" "$lines_rm"
printf ' \e[37m│ v%s\e[0m' "$version"

# --- Extra usage (from OAuth API, cached) ---

usage_cache="/home/tubbles/tmp/.statusline-usage-cache.json"
usage_cache_ttl=300  # refresh every 5 minutes

fetch_usage=0
if [ ! -f "$usage_cache" ]; then
    fetch_usage=1
else
    cache_age=$(( $(date +%s) - $(stat -c %Y "$usage_cache") ))
    if [ "$cache_age" -ge "$usage_cache_ttl" ]; then
        fetch_usage=1
    fi
fi

if [ "$fetch_usage" -eq 1 ]; then
    token=$(jq -r '.claudeAiOauth.accessToken // empty' ~/.claude/.credentials.json 2>/dev/null)
    if [ -n "$token" ]; then
        resp=$(curl -s --max-time 5 \
            -H "Authorization: Bearer $token" \
            -H "anthropic-beta: oauth-2025-04-20" \
            https://api.anthropic.com/api/oauth/usage 2>/dev/null)
        if printf '%s' "$resp" | jq -e '.' >/dev/null 2>&1; then
            printf '%s' "$resp" > "$usage_cache"
        fi
    fi
fi

# Render a usage bar: usage_bar <label> <pct_float> [suffix]
usage_bar() {
    local label=$1 pct=$2 suffix=$3
    local pct_int=${pct%.*}
    local filled=$((pct_int / 5))
    local empty=$((20 - filled))
    local bar_color
    if [ "$pct_int" -lt 70 ]; then
        bar_color='\e[32m'
    elif [ "$pct_int" -lt 90 ]; then
        bar_color='\e[33m'
    else
        bar_color='\e[31m'
    fi
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    printf '\n\e[37m%s:\e[0m ' "$label"
    printf "${bar_color}%s\e[0m %.2f%%" "$bar" "$pct"
    if [ -n "$suffix" ]; then
        printf ' %s' "$suffix"
    fi
}

if [ -f "$usage_cache" ]; then
    # 5-hour window (Pro/Max)
    fh_util=$(jq -r '.five_hour.utilization // empty' "$usage_cache")
    if [ -n "$fh_util" ]; then
        fh_resets=$(jq -r '.five_hour.resets_at // empty' "$usage_cache")
        fh_suffix=""
        if [ -n "$fh_resets" ]; then
            fh_suffix=$(printf '\e[37mresets:\e[0m %s' "$(date -d "$fh_resets" +%H:%M 2>/dev/null || echo "$fh_resets")")
        fi
        usage_bar "5h-usage" "$fh_util" "$fh_suffix"
    fi

    # 7-day window (Pro/Max)
    sd_util=$(jq -r '.seven_day.utilization // empty' "$usage_cache")
    if [ -n "$sd_util" ]; then
        sd_resets=$(jq -r '.seven_day.resets_at // empty' "$usage_cache")
        sd_suffix=""
        if [ -n "$sd_resets" ]; then
            sd_suffix=$(printf '\e[37mresets:\e[0m %s' "$(date -d "$sd_resets" +%m/%d\ %H:%M 2>/dev/null || echo "$sd_resets")")
        fi
        usage_bar "7d-usage" "$sd_util" "$sd_suffix"
    fi

    # Extra usage (team/enterprise)
    eu_enabled=$(jq -r '.extra_usage.is_enabled // false' "$usage_cache")
    if [ "$eu_enabled" = "true" ]; then
        eu_used=$(jq -r '.extra_usage.used_credits // 0' "$usage_cache")
        eu_limit=$(jq -r '.extra_usage.monthly_limit // 0' "$usage_cache")
        eu_pct=$(jq -r '.extra_usage.utilization // 0' "$usage_cache")
        eu_used_usd=$(awk "BEGIN {printf \"%.2f\", $eu_used / 100}")
        eu_limit_usd=$(awk "BEGIN {printf \"%.2f\", $eu_limit / 100}")
        eu_suffix=$(printf '\e[37m(\e[1;33m$%s\e[0m \e[37m/\e[0m \e[37m$%s)\e[0m' "$eu_used_usd" "$eu_limit_usd")
        usage_bar "extra-usage" "$eu_pct" "$eu_suffix"
    fi
fi
