local utils = require("utils")

local pd  = utils.getPeripheral("player_detector")
local mon = utils.getPeripheral("monitor")
mon.clear()
mon.setTextScale(2)
mon.setBackgroundColor(colors.black)


local currentPlayer = nil
local timesPath     = "/leaderboard.txt"
local times         = {}

local actuationStart   = {x=0, y=0, z=0} -- position of timer-start actuation (pressure plate/button)
local actuationEnd     = {x=0, y=0, z=0} -- position of timer-end   actuation (pressure plate/button)
local maxActuationDist = 3



local function updateTimes(name, newTime)
    for i = 1, #times do
        if times[i].name == name then
            if times[i].time > newTime then
                times[i].time = newTime
            end
            return
        end
    end
    times[#times + 1] = {name = name, time = newTime}
end


local function writeTimes()
    table.sort(times, function(a, b) return a.time < b.time end)
    -- Serialize times
    local timeData = {}
    for i = 1, #times do
        timeData[i] = times[i].name .. "@" .. times[i].time
    end
    utils.writeFile(timesPath, table.concat(timeData, "\n"))
end


--
-- Load Start Position
--
if not fs.exists("positions.txt") then
    error("missing start position file")
end
local f = fs.open("positions.txt", "r")
local posStr = f.readAll()
local atPos = string.find(posStr, "@")
if not atPos then
    error("invalid start/finish value")
end

local startPosParts  = utils.splitString(string.sub(posStr, 1, atPos-1))
local finishPosParts = utils.splitString(string.sub(posStr, atPos+1))
if #startPosParts ~=3 or #finishPosParts ~= 3 then
    error("found invalid start/finish position")
end
actuationStart = {
    x = tonumber(startPosParts[1]),
    y = tonumber(startPosParts[2]),
    z = tonumber(startPosParts[3]),
}
actuationEnd = {
    x = tonumber(finishPosParts[1]),
    y = tonumber(finishPosParts[2]),
    z = tonumber(finishPosParts[3]),
}
f.close()
-----------------------------------

--
-- Load times from file
--
if fs.exists(timesPath) then
    local file = fs.open(timesPath, "r")
    while true do
        local line = file.readLine()
        if not line then break end

        -- Parse line as name@time
        local atPos = string.find(line, "@")
        if not atPos then
            error("invalid leaderboard value")
        end

        local name = string.sub(line, 1, atPos-1)
        -- This should be in milliseconds
        local time = tonumber(string.sub(line, atPos+1))
        updateTimes(name, time)
    end
    file.close()
end
----------------------------------

local function isPlayerRunning(pos)
    local nearestPlayer = utils.getNearestPlayer(pos.x, pos.y, pos.z, pd)
    if nearestPlayer.distance <= maxActuationDist then
        if nearestPlayer.name == currentPlayer then
            return true
        end
    end
    return false
end

local function renderActiveRunner(playerName)
    local text = "Active Runner"
    mon.setTextScale(2.5)
    local w = mon.getSize()
    local textWidthDiff = w - #text
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.setBackgroundColor(colors.blue)
    mon.setTextColor(colors.yellow)
    mon.write(string.rep(" ", math.ceil(textWidthDiff / 2))..text..string.rep(" ", w - (textWidthDiff / 2)))
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos(1, 3)
    mon.setTextColor(colors.lime)
    mon.write(utils.centerText(playerName, mon))
end

local function displayTimes(colWidth, yPos)
    local monWidth = mon.getSize()
    local timeLen = #"00:00:00.00"
    local separator = "....."
    local lineLen = colWidth + timeLen + #separator
    local linePadding = math.ceil((monWidth - lineLen) / 2)

    for i = 1, #times do
        yPos = yPos + 1
        mon.setCursorPos(1, yPos)
        local name = times[i].name
        local padding = string.rep(" ", linePadding + (colWidth - #name))
        mon.write(padding)
        mon.setTextColor(colors.white)
        mon.write(name)
        mon.setTextColor(colors.gray)
        mon.write(separator)
        mon.setTextColor(colors.lightBlue)
        mon.write(utils.getTimerStr(times[i].time))
    end
end


local function renderBoard()
    mon.clear()
    mon.setTextScale(2)
    local yPos = 1
    mon.setCursorPos(1, yPos)
    mon.setTextColor(colors.lime)
    mon.write(utils.centerText("Leader Board", mon))
    local columnWidth = 0
    for i = 1, #times do
        local nameWidth = #times[i].name
        if nameWidth > columnWidth then
            columnWidth = nameWidth
        end
    end

    -- Add padding between times and title
    yPos = yPos + 1
    displayTimes(columnWidth, yPos)
end




print("   StartPos: "..actuationStart.x..", "..actuationStart.y..", "..actuationStart.z)
print("  FinishPos: "..actuationEnd.x..", "..actuationEnd.y..", "..actuationEnd.z)
print(" SavedTimes: "..#times)
renderBoard()

while true do
    local _, data = os.pullEvent("leaderboard")

    if type(data) ~= "table" then
       error("tried to send non-table data to leaderboard")
    end

    if data.action == "starting_run" then
        local nearestPlayer = utils.getNearestPlayer(actuationStart.x, actuationStart.y, actuationStart.z, pd)
        if nearestPlayer.distance <= maxActuationDist then
            currentPlayer = nearestPlayer.name
            renderActiveRunner(currentPlayer)
        end

    elseif data.action == "try_cancel_run" then
        if isPlayerRunning(actuationStart) then
            os.queueEvent("cancel_run")
            currentPlayer = nil
            mon.setBackgroundColor(colors.black)
            renderBoard()
        end

    elseif data.action == "save_player_time" then
        if isPlayerRunning(actuationEnd) then
            os.queueEvent("finish_run", data.time)
            updateTimes(currentPlayer, data.time)
            writeTimes()
            renderBoard()
        end
    end
end
