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
-- Example time: 00:00:00:00
-- hr = hour
-- m = minute
-- s = second
-- f = frame
--
-- Frames will only count up to 20 before resetting.
-- Max Time: 59:59:59:19 (resets to 0 if exceeded)
-- Min Time: 00:00:00:01
--
local speed        = 0.05 -- 50ms per tick (min is 0.05 because of rounding)
local iterations   = 0
local milliseconds = 0
local leaderBoardEvent = "leaderboard_update"

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

local function getTimeStr()
    local ticks   = math.floor(milliseconds / 50)
    local seconds = math.floor(milliseconds / 1000)
    local minutes = math.floor(seconds / 60)
    local hours   = math.floor(minutes / 60)


    local str = string.format(
        "%02d:%02d:%02d.%02d",
        hours   % 60,
        minutes % 60,
        seconds % 60,
        ticks   % 20
    )
    return str
end


local function startTimer()
    local timerID = os.startTimer(speed)
    -- It takes one iteration to detect pull event
    iterations = 1
    while true do
        local event, param = os.pullEvent()

        if event == "timer" and param == timerID then
            iterations   = iterations + 1
            milliseconds = iterations * (speed * 1000)
            rednet.broadcast(getTimeStr(), protocol)
            timerID = os.startTimer(speed)

        elseif event == "cancel_run" then
            os.cancelTimer(timerID)
            milliseconds = 0
            rednet.broadcast(getTimeStr(), protocol)
            break

        elseif event == "redstone" then
            local right = redstone.getInput("right")
            local left = redstone.getInput("left")

            if right then
                milliseconds = 0
                -- Delegates to leaderboard, because it tracks what player
                -- is actively running. Will only cancel if the player
                -- who started the run, is trying to cancel the run.
                os.queueEvent(leaderBoardEvent, {action="try_cancel_run"})
            elseif left then
                os.cancelTimer(timerID)
                rednet.broadcast(getTimeStr(), protocol)
                os.queueEvent(leaderBoardEvent, {
                    action  = "save_player_time",
                    time = milliseconds,
                })
                break
            end
        end
    end
end

print(" BroadcastingOn: ".. protocol)
while true do
    os.pullEvent("redstone")
    if redstone.getInput("right") then
        os.queueEvent("leaderboard_update", {action="get_player"})
        startTimer()
    end
end
