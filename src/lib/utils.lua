
---@class Utils
local utils = {}


---Splits at every space character
---@param str string The string to split
---@return string[]
function utils.splitString(str)
    local result = {}
    for word in str:gmatch("%S+") do
        table.insert(result, word)
    end
    return result
end


---Creates or overwrites the specified filepath
---@param filepath string The full path of the file
---@param text string The content to save to the file
function utils.writeFile(filepath, text)
    local file = fs.open(filepath, "w")
    if not file then
        error("probably invalid path for file: " .. filepath)
    end
    file.write(text)
    file.close()
end


---Adds all arguments together
---@vararg integer
---@return integer
function utils.sum(...)
    ---@type integer[]
    local nums = {...}
    local total = 0
    for _, num in ipairs(nums) do
        total = total + num
    end
    return total
end


---Compares two coordinates and determines
---their absolute distance.
---@param coord1 integer
---@param coord2 integer
local function diffCoords(coord1, coord2)
    return math.abs(coord1 - coord2)
end


---Gets the nearest player to the specified coordinates
---@param pos Coord The coordinate position to compare with player positions
---@param playerDetector PlayerDetector
---@param playerNames string[]
function utils.getNearestPlayer(pos, playerDetector, playerNames)
    local nearestPlayer = ""
    local nearestPos   = math.huge

    for _, name in ipairs(playerNames) do
        local playerPosObj = playerDetector.getPlayerPos(name)
        if not playerPosObj then
            error("failed to get player position: " .. name)
        end
        local playerPosDiff = utils.sum(
            diffCoords(pos.x, playerPosObj.x),
            diffCoords(pos.y, playerPosObj.y),
            diffCoords(pos.z, playerPosObj.z)
        )
        if playerPosDiff < nearestPos then
            nearestPos = playerPosDiff
            nearestPlayer = name
        end
    end

    return {
        name = nearestPlayer,
        distance = nearestPos
    }
end


---Centers text on the specified monitor
---@param text string The text to write to the monitor
---@param mon Monitor
function utils.centerText(text, mon)
    local w = mon.getSize()
    return string.rep(" ", (w - #text) / 2) .. text
end


---Converts the specified milliseconds to the
---string: 00:00:00.00
---@param milliseconds integer
function utils.getTimerStr(milliseconds)
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
function utils.loadConfig(path, defaults)
    if not fs.exists(path) then
        utils.writeFile(path, textutils.serialize(defaults))
        return defaults
    else
        local f = fs.open(path, "r")
        if not f then
            error("probably invalid file path: " .. path)
        end
        local data = textutils.unserialize(tostring(f.readAll()))
        return data
    end
end


---Saves serializes data to the specified config
---path.
---@param path string Path to config file
---@param data any The data to serialize to config file
function utils.saveConfig(path, data)
    utils.writeFile(path, textutils.serialize(data))
end


---Prompts the user for coordinates and validates them
---@param promptText string Should tell the user what type of coords to enter
---@return Coord
function utils.promptCoords(promptText)
::restart::
    print()
    term.setTextColor(colors.lightBlue)
    print(promptText)
    term.setTextColor(colors.white)
    write("> ")
    local coords = utils.read()

    -- Validate coord entry
    local coordParts = utils.splitString(coords)
    if #coordParts ~= 3 then
        term.setTextColor(colors.red)
        print("invalid coord length; try again!")
        goto restart
    end

    ---@type integer[]
    local coords = {}

    -- Convert coords to numbers
    for i = 1, #coordParts do
        local coord = tonumber(coordParts[i])
        if not coord then
            term.setTextColor(colors.red)
            print("coordinate '" .. coordParts[i] .. "' is not a number; try again!")
            goto restart
        end
        coords[i] = coord
    end

    ---@type Coord
    local parsedCoord = {
        x = coords[1],
        y = coords[2],
        z = coords[3],
    }
    return parsedCoord
end


---Tries to find the specified peripheral and return it. If more
---than one is found or cannot be found, an error will occur.
---
---This function should never be exported as it's only used
---internally get specific peripherals.
local function getSinglePeripheral(name)
    local p1, p2 = peripheral.find(name)
    if not p1 then
        return nil
    end
    if p2 then
        error("found more than one " .. name)
    end
    return p1
end

---Tries to find a single monitor and return it
---@return Monitor|nil
function utils.getMonitor()
    return getSinglePeripheral("monitor")
end


---Tries to find a single modem and return it
---@return Modem|nil
function utils.getModem()
    return getSinglePeripheral("modem")
end


---Tries to find a player detector and return it
---@return PlayerDetector|nil
function utils.getPlayerDetector()
    return getSinglePeripheral("player_detector")
end


---Tries to find a single drive and return it
---@return Drive|nil
function utils.getDrive()
    return getSinglePeripheral("drive")
end


---Trims all leading and trailing whitespace from the
---specified text.
---@param text string
function utils.trim(text)
    return (string.gsub(text, "^%s*(.-)%s*$", "%1"))
end


---Wraps the read() and trims any trailing or leading
---whitespace from the input automatically.
function utils.read()
    return utils.trim(read())
end



return utils


