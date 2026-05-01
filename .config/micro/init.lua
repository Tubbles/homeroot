local micro = import("micro")
local util = import("micro/util")
local shell = import("micro/shell")

function scrollUpOne(bp)
    bp:ScrollUp(1)
    return true
end

function scrollDownOne(bp)
    bp:ScrollDown(1)
    return true
end

-- VS Code-style Ctrl+D: select word under cursor, then add cursors
-- at subsequent matches. Always does substring matching (no word
-- boundaries) when a selection exists.
function addNextMatch(bp)
    local c = bp.Buf:GetCursor(bp.Buf:NumCursors() - 1)

    if not c:HasSelection() then
        c:SelectWord()
        bp:Relocate()
        return true
    end

    local sel = util.String(c:GetSelection())
    local searchFrom = -c.CurSelection[2]

    local match, found = bp.Buf:FindNext(
        sel, bp.Buf:Start(), bp.Buf:End(),
        searchFrom, true, false
    )
    if not found then
        micro.InfoBar():Message("No more matches")
        return false
    end

    local newC = bp:SpawnCursorAtLoc(match[1])
    newC:SetSelectionStart(match[1])
    newC:SetSelectionEnd(match[2])
    newC.OrigSelection[1] = newC.CurSelection[1]
    newC.OrigSelection[2] = newC.CurSelection[2]
    newC.Loc = match[2]

    bp.Buf:SetCurCursor(bp.Buf:NumCursors() - 1)

    bp:Relocate()
    return true
end

-- Move to next pane: try next split inside the current tab first; if already
-- on the last split, fall through to the next tab; if already on the last
-- tab, wrap around to the leftmost leaf of the first tab. Walks the split
-- tree in visual reading order, matching MovePaneToNext.
function smartNextPane(bp)
    if bp:NextLeafSplit() then return end
    if bp:NextTab() then return end
    bp:FirstTab()
    local cur = micro.CurPane()
    while cur:PreviousLeafSplit() do
        cur = micro.CurPane()
    end
end

-- Mirror image of smartNextPane.
function smartPrevPane(bp)
    if bp:PreviousLeafSplit() then return end
    if bp:PreviousTab() then return end
    bp:LastTab()
    local cur = micro.CurPane()
    while cur:NextLeafSplit() do
        cur = micro.CurPane()
    end
end

-- VSCode-style Ctrl+P file picker: shells out to fzf with a candidate
-- list (git-tracked + untracked-non-ignored, falling back to fd, then
-- find), opens the chosen file in a new tab. RunInteractiveShell does
-- TempFini/TempStart so fzf gets a real terminal.
function fzfOpen(bp)
    local listCmd = "(git ls-files --cached --others --exclude-standard 2>/dev/null"
        .. " || fd --type f 2>/dev/null"
        .. " || find . -type f)"
    local cmd = "bash -c \"" .. listCmd .. " | fzf --layout=reverse\""

    local out, err = shell.RunInteractiveShell(cmd, false, true)
    if err ~= nil then return end

    local path = out:gsub("%s+$", "")
    if path == "" then return end

    -- HandleCommand re-parses with shellquote.Split, so wrap the path
    -- in single quotes and POSIX-escape any embedded single quotes
    -- (foo'bar -> 'foo'\''bar') so spaces and shell metacharacters
    -- survive intact.
    local quoted = "'" .. path:gsub("'", "'\\''") .. "'"
    bp:HandleCommand("tab " .. quoted)
end
