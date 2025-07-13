
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

local function splitString(str)
    local result = {}
    for word in str:gmatch("%S+") do
        table.insert(result, word)
    end
    return result
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
local startPos = {
    x = tonumber(posParts[1]),
    y = tonumber(posParts[2]),
    z = tonumber(posParts[3]),
}
f.close()
print(" StartPos: "..startPos.x..", "..startPos.y..", "..startPos.z)
-----------------------------------

--
-- Load times from file
--
local times = {}
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
        local time = string.sub(line, atPos+1)
        times[name] = time
    end
    file.close()
end
print("SavedTimes: "..#times)
----------------------------------


-- sum adds all variadic arguments together
local function sum(...)
    local total = 0
    for _, num in ipairs({...}) do
        total = total + num
    end
    return total
end

local function centerText(str)
    local w = mon.getSize()
    return string.rep(" ", (w - #str) / 2) .. str
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
                mon.clear()
            end
        end

    elseif data.action == "save_time" then
        if lastPlayer then
            times[lastPlayer] = data.time
        end
    end
end
