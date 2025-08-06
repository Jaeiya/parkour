local utils = require("utils")
local state = require("boardstate")


---50ms per tick (min is 0.05 because of rounding)
local speed = 0.05

---Updated every time the time is updated
local iterations = 0

local modem = utils.getModem('wireless')
if not modem then
    printError("timer terminated; missing modem")
    return false
end



---@param config BoardConfig
return function(config)
    rednet.open(peripheral.getName(modem))

    -- Always startup with monitors zero'd out
    rednet.broadcast("00:00:00.00", config.monProto)

    -- Prevent any default timer events
    local timerID = 133742069

    while true do
        local _, data = os.pullEvent("timer")

        if type(data) == "number" then
            ---@type number
            local id = data

            if id == timerID then
                iterations = iterations + 1
                state.timer.milliseconds = iterations * (speed * 1000)
                rednet.broadcast(utils.getTimerStr(state.timer.milliseconds), config.monProto)
                timerID = os.startTimer(speed)
            end

        else
            ---@type MessageEvent
            local msgEvent = data

            if msgEvent.action == "start" then
                iterations = 1
                os.queueEvent("leaderboard", {action="start_run"})
                timerID = os.startTimer(speed)
                state.timer.isActive = true

            elseif msgEvent.action == "cancel_run" then
                os.cancelTimer(timerID)
                state.timer.isActive = false
                state.timer.milliseconds = 0
                rednet.broadcast(utils.getTimerStr(state.timer.milliseconds), config.monProto)

            elseif msgEvent.action == "finish_run" then
                os.cancelTimer(timerID)
                state.timer.isActive = false
                -- Payload should always be the millisecond time when user
                -- pressed actuation (button/pressure plate).
                rednet.broadcast(utils.getTimerStr(msgEvent.payload), config.monProto)
            end
        end
    end
end
