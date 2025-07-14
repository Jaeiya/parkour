--
-- Allows you to stop and start a timer that displays to a
-- monitor constellation. The smallest increment of time
-- that can be measured is 50ms which is the limitation of
-- minecraft itself.
--
-- The smallest increments displayed are frames. For every frame,
-- 50ms has passed, and the total number of frames per second
-- is 20.
--               hr m  s  f
-- Example time: 00:00:00.00
-- hr = hour
-- m = minute
-- s = second
-- f = frame
--
-- Frames will only count up to 20 before resetting.
-- Max Time: 59:59:59.19 (resets to 0 if exceeded)
-- Min Time: 00:00:00.01
--
local utils = require("utils")
local speed        = 0.05 -- 50ms per tick (min is 0.05 because of rounding)
local iterations   = 0
local milliseconds = 0
local leaderBoardEvent = "leaderboard"

local modem = peripheral.find("modem")
if not modem then
    error("missing modem")
end

if not fs.exists("protocol.txt") then
    error("missing protocol file")
end

local f = fs.open("protocol.txt", "r")
local protocol = f.readAll()
f.close()

rednet.open(peripheral.getName(modem))


local function startTimer()
    local timerID = os.startTimer(speed)
    -- It takes one iteration to detect pull event
    iterations = 1
    while true do
        local event, param = os.pullEvent()

        if event == "timer" and param == timerID then
            iterations   = iterations + 1
            milliseconds = iterations * (speed * 1000)
            rednet.broadcast(utils.getTimerStr(milliseconds), protocol)
            timerID = os.startTimer(speed)

        elseif event == "cancel_run" then
            os.cancelTimer(timerID)
            -- Param should always be the millisecond time
            milliseconds = 0
            rednet.broadcast(utils.getTimerStr(milliseconds), protocol)
            break

        elseif event == "finish_run" then
            os.cancelTimer(timerID)
            -- Param should always be the millisecond time when user
            -- pressed actuation (button/pressure plate).
            rednet.broadcast(utils.getTimerStr(param), protocol)
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

print(" BroadcastingOn: ".. protocol)
while true do
    os.pullEvent("redstone")
    if redstone.getInput("right") then
        os.queueEvent(leaderBoardEvent, {action="starting_run"})
        startTimer()
    end
end
