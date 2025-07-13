
local utils = {}

-- splitString at every space character
utils.splitString = function(str)
    local result = {}
    for word in str:gmatch("%S+") do
        table.insert(result, word)
    end
    return result
end


utils.writeFile = function(filepath, text)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end

utils.getPeripheral = function(name)
    local p = peripheral.find(name)
    if not p then
        error("missing peripheral: " .. name)
    end
    return p
end

-- sum adds all variadic arguments together
utils.sum = function(...)
    local total = 0
    for _, num in ipairs({...}) do
        total = total + num
    end
    return total
end

-- diffCoords compares two coordinates and determines
-- their absolute distance.
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


utils.getNearestPlayer = function(x, y, z, playerDetector)
    local players = playerDetector.getOnlinePlayers()
    local nearestPlayer = ""
    local nearestPos   = math.huge

    for i = 1, #players do
        local playerPosObj = playerDetector.getPlayerPos(players[i])
        local playerPosDiff = utils.sum(
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


-- centerText on a specified monitor
utils.centerText = function(text, mon)
    local w = mon.getSize()
    return string.rep(" ", (w - #text) / 2) .. text
end


-- getTimerStr in the format 00:00:00.00, from the
-- specified milliseconds.
utils.getTimerStr = function(milliseconds)
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


return utils
