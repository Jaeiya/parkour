local utils = require('utils')
local state = require('boardstate')

local pd = utils.getPlayerDetector()
if not pd then
    printError("player tracker terminated; missing player detector")
    return false
end


---@param config BoardConfig
local function trackPlayer(config)
    while state.runningPlayer do
        local info = pd.getPlayerPos(state.runningPlayer)
        if not info then
            error("could not retrieve player information")
        end

        if config.boundary.direction == 'upper' then
            if info[config.boundary.axis] > config.startPos[config.boundary.axis] then
                os.queueEvent("leaderboard", {
                    action = "force_cancel_run",
                    payload = state.timer.milliseconds
                })
                return
            end

        elseif config.boundary.direction == 'lower' then
            if info[config.boundary.axis] < config.startPos[config.boundary.axis] then
                os.queueEvent("leaderboard", {
                    action = "force_cancel_run",
                    payload = state.timer.milliseconds
                })
                return
            end
        end

        sleep(0.1)
    end
end


---@param config BoardConfig
return function(config)
    while true do
        local _, data = os.pullEvent("playertracker")

        if type(data) ~= "table" then
            error("tried to send non-table data to player tracker")
        end

        -- All events passed between modules will be in this format
        ---@type MessageEvent
        local msgEvent = data

        if msgEvent.action == "track_player" then
            trackPlayer(config)
        end
    end
end
