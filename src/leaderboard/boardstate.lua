

---Shared state between all board scripts
---@class SharedState
---@field runningPlayer string|nil Always set to nil when run is finished or cancelled
local state = {
    timer = {
        isActive = false,
        milliseconds = 0,
    },
    monitorScale = 1.5,
    runningPlayer = nil,
    medalLives = {
        mud    = 0,
        bronze = 0,
        silver = 0,
        gold   = 0,
        heart  = 0,
    }
}

return state
