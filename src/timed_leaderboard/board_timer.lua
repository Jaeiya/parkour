--
-- Allows you to stop and start a timer that displays to a
-- monitor constellation. The smallest increment of time
-- that can be measured is 50ms which is the limitation of
-- minecraft itself.
--
-- The smallest increments displayed are ticks. For every tick,
-- 50ms has passed, and the total number of ticks per second
-- is 20.
--               hr m  s  t
-- Example time: 00:00:00.00
-- hr = hour
-- m = minute
-- s = second
-- t = tick
--
-- Ticks will only count up to 20 before resetting.
-- Max Time: 59:59:59.19 (resets to 0 if exceeded)
-- Min Time: 00:00:00.01
--
local utils = require("utils")
local lib = require("board_lib")
local state = require("board_state")

local speed        = 0.05 -- 50ms per tick (min is 0.05 because of rounding)
local iterations   = 0
local leaderBoardEvent = "leaderboard"
local config = lib.loadConfig()

local modem = utils.getModem()
if not modem then
    printError("timer terminated; missing modem")
    return false
end


rednet.open(peripheral.getName(modem))

-- Always startup with monitors zero'd out
rednet.broadcast("00:00:00.00", config.protocol)

return function()
    local timerID = 0
    while true do
        local _, data = os.pullEvent("timer")

        if type(data) == "number" then
            ---@type number
            local id = data

            if id == timerID then
                iterations         = iterations + 1
                utils.milliseconds = iterations * (speed * 1000)
                rednet.broadcast(utils.getTimerStr(utils.milliseconds), config.protocol)
                timerID = os.startTimer(speed)
            end

        else
            ---@type MessageEvent
            local msgEvent = data

            if msgEvent.action == "start" then
                iterations = 1
                os.queueEvent(leaderBoardEvent, {action="start_run"})
                timerID = os.startTimer(speed)
                state.isTimerActive = true

            elseif msgEvent.action == "cancel_run" then
                os.cancelTimer(timerID)
                state.isTimerActive = false
                utils.milliseconds = 0
                rednet.broadcast(utils.getTimerStr(utils.milliseconds), config.protocol)

            elseif msgEvent.action == "finish_run" then
                os.cancelTimer(timerID)
                state.isTimerActive = false
                -- Payload should always be the millisecond time when user
                -- pressed actuation (button/pressure plate).
                rednet.broadcast(utils.getTimerStr(msgEvent.payload), config.protocol)

            elseif msgEvent.action == "new_protocol" then
                config.protocol = msgEvent.payload
            end
        end


    end
end
