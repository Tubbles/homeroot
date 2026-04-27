local micro = import("micro")
local util = import("micro/util")

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
-- on the last split, fall through to the next tab.
function smartNextPane(bp)
    if not bp:NextSplit() then
        bp:NextTab()
    end
end

-- Mirror image of smartNextPane.
function smartPrevPane(bp)
    if not bp:PreviousSplit() then
        bp:PreviousTab()
    end
end
