
---@class Utils
local utils = {
    -- For use with timer ONLY
    milliseconds = 0
}

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
    return math.abs(coord1 - coord2)
end


utils.getNearestPlayer = function(x, y, z, playerDetector, players)
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


---Tries to load a configuration file, but if it cannot, it
---will create one instead and return the defaults.
---@generic T
---@param path string The path to the config file
---@param defaults T The default configuration value to use
---@return T
utils.loadConfig = function(path, defaults)
    if not fs.exists(path) then
        utils.writeFile(path, textutils.serialize(defaults))
        return defaults
    else
        local f = fs.open(path, "r")
        local data = textutils.unserialize(tostring(f.readAll()))
        return data
    end
end


---Saves serializes data to the specified config
---path.
---@param path string Path to config file
---@param data any The data to serialize to config file
utils.saveConfig = function (path, data)
    utils.writeFile(path, textutils.serialize(data))
end


utils.promptCoords = function(promptText)
::restart::
    print()
    term.setTextColor(colors.lightBlue)
    print(promptText)
    term.setTextColor(colors.white)
    write("> ")
    local coords = read()

    -- Validate coord entry
    local coordParts = utils.splitString(coords)
    if #coordParts ~= 3 then
        term.setTextColor(colors.red)
        print("invalid coord length; try again!")
        goto restart
    end

    -- Convert coords to numbers
    for i = 1, #coordParts do
        local coord = coordParts[i]
        coordParts[i] = tonumber(coord)
        if not coordParts[i] then
            term.setTextColor(colors.red)
            print("coordinate '" .. coord .. "' is not a number; try again!")
            goto restart
        end
    end

    return {
        x = coordParts[1],
        y = coordParts[2],
        z = coordParts[3],
    }
end

return utils

