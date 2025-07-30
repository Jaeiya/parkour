

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
}

return state
