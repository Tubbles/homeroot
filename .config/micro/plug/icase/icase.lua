VERSION = "1.0.0"

local micro = import("micro")

function init()
    micro.SetStatusInfoFn("icase.indicator")
end

function indicator(b)
    if b.Settings["ignorecase"] then
        return "Aa"
    end
    return "A"
end
