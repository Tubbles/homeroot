VERSION = "1.0.0"

local micro = import("micro")
local config = import("micro/config")

function init()
    micro.SetStatusInfoFn("icase.indicator")
end

function indicator(b)
    if config.GetGlobalOption("ignorecase") then
        return "Aa"
    end
    return "A"
end
