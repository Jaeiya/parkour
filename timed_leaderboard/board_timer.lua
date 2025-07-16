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
local milliseconds = 0
local leaderBoardEvent = "leaderboard"

local modem = peripheral.find("modem")
if not modem then
    error("missing modem")
end

local config = lib.loadBoardConfig()
rednet.open(peripheral.getName(modem))


local function startTimer()
    local timerID = os.startTimer(speed)
    -- It takes one iteration to detect pull event
    iterations = 1
    while true do
        local event, data = os.pullEvent()

        if event == "timer" and data == timerID then
            iterations   = iterations + 1
            milliseconds = iterations * (speed * 1000)
            rednet.broadcast(utils.getTimerStr(milliseconds), config.monitor.protocol)
            timerID = os.startTimer(speed)

        elseif event == "cancel_run" then
            os.cancelTimer(timerID)
            milliseconds = 0
            rednet.broadcast(utils.getTimerStr(milliseconds), config.monitor.protocol)
            break

        elseif event == "finish_run" then
            os.cancelTimer(timerID)
            -- Param should always be the millisecond time when user
            -- pressed actuation (button/pressure plate).
            rednet.broadcast(utils.getTimerStr(data), config.monitor.protocol)
            break

        elseif event == "redstone" then
            local right = redstone.getInput("right")
            local left = redstone.getInput("left")

            if right then
                -- The run will only be canceled if the active runner
                -- is the same player who triggered this action.
                os.queueEvent(leaderBoardEvent, {
                    action="try_cancel_run",
                    time = milliseconds
                })

            elseif left then
                -- This action will be ignored entirely, if the player who
                -- triggered this action, is not the active runner.
                --
                -- Otherwise...if the active runner does not have a time on
                -- record, one will be created for them. If the active runner
                -- already has a faster time, a slower time will not be saved.
                os.queueEvent(leaderBoardEvent, {
                    action  = "save_player_time",
                    time = milliseconds,
                })
            end
        end
    end
end

print(" ConstellationProtocol: ".. config.monitor.protocol)
-- Always startup with monitors zero'd out
rednet.broadcast("00:00:00.00", config.monitor.protocol)

while true do
    os.pullEvent("redstone")
    if redstone.getInput("right") then
        os.queueEvent(leaderBoardEvent, {action="starting_run"})
        startTimer()
    end
end
