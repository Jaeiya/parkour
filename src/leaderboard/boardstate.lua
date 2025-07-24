

---Shared state between all scripts
---@class SharedState
local state = {
    timer = {
        isActive = false,
        milliseconds = 0,
    },
    monitorScale = 2,
}

return state
