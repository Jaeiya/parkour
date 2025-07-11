
local speed        = 0.05 -- 50ms per tick (min is 0.05 because of rounding)
local iterations   = 0
local milliseconds = 0
local redstoneDir  = "front"

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
    local seconds     = math.floor(milliseconds / 1000)
    local minutes     = math.floor(seconds / 60)
    local hours       = math.floor(minutes / 60)

    local str = string.format(
        "%02d:%02d:%02d.%02d",
        hours       % 60,
        minutes     % 60,
        seconds     % 60,
        iterations  % 20
    )
    return str
end


local function writeFile(filepath, text)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
    return true
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
        elseif event == "redstone" and redstone.getInput(redstoneDir) then
            os.cancelTimer(timerID)
            local timeStr = getTimeStr()
            rednet.broadcast(timeStr, protocol)
            -- writeFile("temp.txt", timeStr)
            break
        end
    end
end

print("AcceptsRedstone: "..redstoneDir)
print(" BroadcastingOn: ".. protocol)
while true do
    os.pullEvent("redstone")
    if redstone.getInput(redstoneDir) then
        startTimer()
    end
end
