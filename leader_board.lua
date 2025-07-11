local pd = peripheral.find("player_detector")

local function validateTime(timeStr)
    if #timeStr ~= 11 then
        return false
    end

    local digitPos = 1
    for i = 1, 4 do
        if i < 4 and string.sub(timeStr, i*3, i*3) ~= ":" then
            return false
        end

        local _, found_end = string.find(timeStr, "%d%d", digitPos)
        if found_end ~= digitPos+1 then
            return false
        end

        digitPos = digitPos + 3
    end

    return true
end

local function readFileLines(filename)
    local file = fs.open("time.txt", "r")
    local lines = {}
    while true do
        local line = file.readLine()
        if not line then break end
        lines[#lines+1] = line
    end
    file.close()
    return lines
end


local function writeFile(filepath, text)
    if !fs.exists(filepath) then
        return false
    end

    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()

    return true
end


local function toMilli(timeStr)
    local hoursStr   = string.sub(timeStr, 1, 2)
    local minutesStr = string.sub(timeStr, 4, 5)
    local secondsStr = string.sub(timeStr, 7, 8)
    -- This is in base60
    local milliStr   = string.sub(timeStr, 10, 11)

    local hoursMilli   = tonumber(hoursStr) * 60 * 60 * 1000
    local minutesMilli = tonumber(minutesStr) * 60 * 1000
    local secondsMilli = tonumber(secondsStr) * 1000
    local milliseconds = math.ceil(tonumber(milliStr) * 16.666)

    return hoursMilli + minutesMilli + secondsMilli + milliseconds
end


local function timeToMilliseconds(timeStr)
    if not validateTime(timeStr) then
        return nil
    end
end

local function sum(...)
    local total = 0
    for _, num in ipairs({...}) do
        total = total + num
    end
    return total
end

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

local function getNearestPlayer()
    local players = pd.getOnlinePlayers()

    -- Computer location
    local x, y, z     = gps.locate()

    local nearestPlayer = ""
    local lastPosDiff   = math.huge

    for i = 1, #players do
        local playerPosObj = pd.getPlayerPos(players[i])
        local playerPosDiff = sum(
            diffCoords(x, playerPosObj.x),
            diffCoords(y, playerPosObj.y),
            diffCoords(z, playerPosObj.z)
        )
        if playerPosDiff < lastPosDiff then
            lastPosDiff = playerPosDiff
            nearestPlayer = players[i]
        end
    end

    return nearestPlayer
end

local function askForName()
    print("What name would you like to add?")
    print("")
    local input = read("Enter Name>")
    -- Check to see if name already exists
    -- Add name if it doesn't exist
end

local function updateTime()
    -- Display name selection
    -- Prompt for new time
    -- Make sure entered time is not larger than existing time
    -- Update time
    -- Refresh board
end

while true do
    print("Leaderboard Updater")
    print("")
    print("  1) Add Name")
    print("  2) Update Time")
    print("")
    local input = read("Choice>")

    if input == "1" then
        askForName()
    elseif input == "2" then
        updateTime()
    end

end


