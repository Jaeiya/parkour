--
-- Allows you to stop and start a timer that displays to a
-- monitor constellation. The smallest increment of time
-- that can be measured is 50ms which is the limitation of
-- minecraft itself.
--
-- The smallest increments displayed are frames. For every frame,
-- 50ms has passed, and the total number of frames per second
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
local speed        = 0.05 -- 50ms per tick (min is 0.05 because of rounding)
local iterations   = 0
local leaderBoardEvent = "leaderboard"

local modem = peripheral.find("modem")
if not modem then
    error("missing modem")
end

local config = lib.loadBoardConfig()
rednet.open(peripheral.getName(modem))



-- Always startup with monitors zero'd out
rednet.broadcast("00:00:00.00", config.monitor.protocol)

return function()
    local timerID = 0
    while true do
        local _, data = os.pullEvent("timer")

        if type(data) == "number" then
            if data == timerID then
                iterations         = iterations + 1
                utils.milliseconds = iterations * (speed * 1000)
                rednet.broadcast(utils.getTimerStr(utils.milliseconds), config.monitor.protocol)
                timerID = os.startTimer(speed)
            end

        elseif data.action == "start" then
            iterations = 1
            os.queueEvent(leaderBoardEvent, {action="start_run"})
            timerID = os.startTimer(speed)

        elseif data.action == "cancel_run" then
            os.cancelTimer(timerID)
            utils.milliseconds = 0
            rednet.broadcast(utils.getTimerStr(utils.milliseconds), config.monitor.protocol)

        elseif data.action == "finish_run" then
            os.cancelTimer(timerID)
            -- Payload should always be the millisecond time when user
            -- pressed actuation (button/pressure plate).
            rednet.broadcast(utils.getTimerStr(data.payload), config.monitor.protocol)
        end
    end
end
