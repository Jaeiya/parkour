

---Shared state between all scripts
---@class SharedState
---@field runningPlayer string|nil
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
    }
}

return state
