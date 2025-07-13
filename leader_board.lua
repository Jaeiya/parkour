
local pd = peripheral.find("player_detector")
if not pd then
    error("missing player detector")
end

local mon = peripheral.find("monitor")
mon.clear()
mon.setTextScale(2)
mon.setBackgroundColor(colors.black)


local lastPlayer = nil
local timesPath = "/leaderboard.txt"
local times = {}
local startPos = {}

local function splitString(str)
    local result = {}
    for word in str:gmatch("%S+") do
        table.insert(result, word)
    end
    return result
end

local function writeFile(filepath, text)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end


local function addTime(name, newTime)
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
    writeFile(timesPath, table.concat(timeData, "\n"))
end


local function getTimeStr(milliseconds)
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


--
-- Load Start Position
--
if not fs.exists("startpos.txt") then
    error("missing start position file")
end
local f = fs.open("startpos.txt", "r")
local posParts = splitString(f.readAll())
if #posParts ~= 3 then
    error("invalid start position")
end
startPos = {
    x = tonumber(posParts[1]),
    y = tonumber(posParts[2]),
    z = tonumber(posParts[3]),
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
        addTime(name, time)
    end
    file.close()
end
----------------------------------


local function centerText(str)
    local w = mon.getSize()
    return string.rep(" ", (w - #str) / 2) .. str
end


local function displayBoard()
    mon.clear()
    mon.setTextScale(2)
    local yPos = 1
    mon.setCursorPos(1, yPos)
    mon.setTextColor(colors.lime)
    mon.write(centerText("Leader Board"))
    local maxNameWidth = 0
    for i = 1, #times do
        local nameWidth = #times[i].name
        if nameWidth > maxNameWidth then
            maxNameWidth = nameWidth
        end
    end

    -- Add padding between times and title
    yPos = yPos + 1

    for i = 1, #times do
        yPos = yPos + 1
        mon.setCursorPos(3, yPos)
        local name = times[i].name
        local padding = string.rep(" ", maxNameWidth - #name)
        mon.write(padding)
        mon.setTextColor(colors.white)
        mon.write(name)
        mon.write("     ")
        mon.setTextColor(colors.lightBlue)
        mon.write(getTimeStr(times[i].time))
    end
end


-- sum adds all variadic arguments together
local function sum(...)
    local total = 0
    for _, num in ipairs({...}) do
        total = total + num
    end
    return total
end

-- diffCoords compares two coordinates and determines
-- their absolute distance from each other.
local function diffCoords(coord1, coord2)
    if coord1 == coord2 then
        return 0
    elseif coord1 <= 0 and coord2 > 0 then
        return math.abs(coord1) + coord2
    elseif coord1 >= 0 and coord2 < 0 then
        return coord1 + math.abs(coord2)
    else
        -- Both coords are either positive or negative
        return math.abs(math.abs(coord1) - math.abs(coord2))
    end
end


local function getNearestPlayer(x, y, z)
    local players = pd.getOnlinePlayers()
    local nearestPlayer = ""
    local nearestPos   = math.huge

    for i = 1, #players do
        local playerPosObj = pd.getPlayerPos(players[i])
        local playerPosDiff = sum(
            diffCoords(x, playerPosObj.x),
            diffCoords(y, playerPosObj.y),
            diffCoords(z, playerPosObj.z)
        )
        if playerPosDiff < nearestPos then
            nearestPos = playerPosDiff
            nearestPlayer = players[i]
        end
    end

    return {
        name = nearestPlayer,
        distance = nearestPos
    }
end



print("   StartPos: "..startPos.x..", "..startPos.y..", "..startPos.z)
print(" SavedTimes: "..#times)
displayBoard()

while true do
    local _, data = os.pullEvent("leaderboard_update")

    if type(data) ~= "table" then
       error("tried to send non-table data to leaderboard")
    end

    if data.action == "get_player" then
        local nearestPlayer = getNearestPlayer(startPos.x, startPos.y, startPos.z)
        if nearestPlayer.distance <= 3 then
            lastPlayer = nearestPlayer.name
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
            mon.write(centerText(lastPlayer))
        end

    elseif data.action == "try_cancel_run" then
        local nearestPlayer = getNearestPlayer(startPos.x, startPos.y, startPos.z)
        if nearestPlayer.distance <= 3 then
            if nearestPlayer.name == lastPlayer then
                os.queueEvent("cancel_run")
                lastPlayer = nil
                mon.setBackgroundColor(colors.black)
                displayBoard()
            end
        end

    elseif data.action == "save_player_time" then
        if lastPlayer then
            addTime(lastPlayer, data.time)
            writeTimes()
            displayBoard()
        end
    end
end
