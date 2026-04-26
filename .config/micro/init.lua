local buffer = import("micro/buffer")
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

local function locAfter(loc, y, x)
    return loc.Y > y or (loc.Y == y and loc.X > x)
end

local function locBefore(loc, y, x)
    return loc.Y < y or (loc.Y == y and loc.X < x)
end

local function nearestMessage(messages, n, cur, forward)
    local target = nil
    for i = 1, n do
        local s = messages[i].Start
        local ok = forward and locAfter(s, cur.Y, cur.X) or locBefore(s, cur.Y, cur.X)
        if ok then
            local closer = (target == nil) or
                (forward and locBefore(s, target.Y, target.X)) or
                ((not forward) and locAfter(s, target.Y, target.X))
            if closer then target = s end
        end
    end
    return target
end

local function wrapMessage(messages, n, forward)
    local target = messages[1].Start
    for i = 2, n do
        local s = messages[i].Start
        if forward and locBefore(s, target.Y, target.X) then
            target = s
        elseif (not forward) and locAfter(s, target.Y, target.X) then
            target = s
        end
    end
    return target
end

local function jumpMessage(bp, forward)
    local messages = bp.Buf.Messages
    local n = #messages
    if n == 0 then
        micro.InfoBar():Message("No messages in buffer")
        return
    end
    local target = nearestMessage(messages, n, bp.Cursor, forward)
    if target == nil then
        target = wrapMessage(messages, n, forward)
        micro.InfoBar():Message("Wrapped to " .. (forward and "first" or "last") .. " message")
    end
    bp.Cursor:GotoLoc(target)
    bp:Relocate()
end

function jumpNextMessage(bp) jumpMessage(bp, true) end
function jumpPrevMessage(bp) jumpMessage(bp, false) end
