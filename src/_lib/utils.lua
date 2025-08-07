
---@class Coord
---@field x integer
---@field y integer
---@field z integer


---@class Utils
local utils = {}


---Color code map designed strictly for use with utils.print()
local colorCodes = {
    [";wht;"] = colors.white,
    [";org;"] = colors.orange,
    [";mgt;"] = colors.magenta,
    [";lbu;"] = colors.lightBlue,
    [";ylw;"] = colors.yellow,
    [";lim;"] = colors.lime,
    [";pnk;"] = colors.pink,
    [";gry;"] = colors.gray,
    [";lgy;"] = colors.lightGray,
    [";cyn;"] = colors.cyan,
    [";ppl;"] = colors.purple,
    [";blu;"] = colors.blue,
    [";bwn;"] = colors.brown,
    [";grn;"] = colors.green,
    [";red;"] = colors.red,
    [";blk;"] = colors.black,
}


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


---@param n integer
function utils.round(n)
    return math.floor(n + 0.5)
end


---Clears the screen and makes sure anything written to
---the screen afterwards, starts at the top of the screen.
---@param mon Monitor? The monitor to clear instead of the terminal
function utils.clear(mon)
    local display = term
    if mon then
        -- Only the monitor needs to have its background reset
        mon.setBackgroundColor(colors.black)
        display = mon
    end
    display.setTextColor(colors.white)
    display.clear()
    display.setCursorPos(1, 1)
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

        ---@type Coord
        local playerPos = {
            x = playerPosObj.x,
            y = playerPosObj.y,
            z = playerPosObj.z,
        }

        local playerPosDiff = utils.getDistance(pos, playerPos)

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


---Compare two coordinate positions and return the
---absolute distance between them.
---@param pos1 Coord
---@param pos2 Coord
function utils.getDistance(pos1, pos2)
    return utils.sum(
        math.abs(pos1.x - pos2.x),
        math.abs(pos1.y - pos2.y),
        math.abs(pos1.z - pos2.z)
    )
end


---Centers text on the specified device
---@param text string The text to write to the device
---@param device Monitor|Terminal
function utils.centerText(text, device)
    local w = device.getSize()
    return string.rep(" ", (w - #utils.stripColorCodes(text)) / 2) .. text
end


---Prints the `colText` to the specified `device` in
---fixed-size columns based on the largest string
---inside `colText`
---@param colText string[] An array of text to print in separate columns
---@param spacing integer The distance between columns
---@param maxWidth? integer Force a max column width
---@param device? Monitor Where the text is expected to be printed (default: terminal)
function utils.formatColumns(colText, spacing, maxWidth, device)
    if not device then
        device = term
    end

    local colWidth = 0
    for i in ipairs(colText) do
        local text = utils.stripColorCodes(colText[i])
        if #text > colWidth then
            colWidth = #text
        end
        if maxWidth and colWidth > maxWidth then
            error("column text is too large for max width")
        end
    end

    if maxWidth then
        colWidth = maxWidth
    end

    local newStr = ""
    for i in ipairs(colText) do
        if i > 1 then
            newStr = newStr..string.rep(" ", spacing)
        end
        newStr = newStr..utils.justifyText(colText[i], 'left', colWidth)
    end

    return utils.centerText(newStr, device)
end


---Converts the specified milliseconds to the
---string format: hh:mm:ss.tt
---@param milliseconds integer
function utils.getTimerStr(milliseconds)
    local ticks   = math.floor(milliseconds / 50)
    local seconds = math.floor(milliseconds / 1000)
    local minutes = math.floor(seconds / 60)
    local hours   = math.floor(minutes / 60)

    local str = string.format(
        "%02d:%02d:%02d.%02d",
        hours, -- We let hours run up
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
        utils.saveConfig(path, defaults)
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


---Saves serialized data to the specified config path.
---@param path string Path to config file
---@param data any The data to serialize to config file
function utils.saveConfig(path, data)
    utils.writeFile(path, textutils.serialize(data))
end


---Prompts the user for coordinates and validates them
---@param promptText string Should tell the user what type of coords to enter
---@return Coord
function utils.promptCoords(promptText)
::prompt::
    local coordParts = utils.splitString(utils.prompt(promptText))
    if #coordParts ~= 3 then
        printError("invalid coord length; try again!")
        goto prompt
    end

    ---@type integer[]
    local coords = {}

    -- Convert coords to numbers
    for i = 1, #coordParts do
        local coord = tonumber(coordParts[i])
        if not coord then
            printError("coordinate '"..coordParts[i].."' is not a number; try again!")
            goto prompt
        end
        if coord % 1 ~= 0 then
            printError("coordinates cannot be fractions: '"..coord.."'")
            goto prompt
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
---internally to get specific peripherals.
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


---Gets the first modem that matches the type
---@param type 'wireless'|'wired' What kind of modem to look for
---@param side? Side The side the modem is expected to be on
---@return Modem|nil
function utils.getModem(type, side)
    if side then
        if peripheral.getType(side) ~= 'modem' then
            return nil
        end
        return peripheral.wrap(side)
    end

    for _, blockSide in ipairs(peripheral.getNames()) do
        if peripheral.getType(blockSide) == 'modem' then
            ---@type Modem|nil
            local m = peripheral.wrap(blockSide)
            if not m then error('somehow modem is missing?') end

            if type == 'wireless' and m.isWireless() then
                return m
            end

            if type == 'wired' and not m.isWireless() then
                return m
            end
        end
    end
    return nil
end


---Tries to find a single player detector and return it
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


---Prompts the user for input
---@param prompt string Text telling the user what's required
function utils.prompt(prompt)
    utils.print("\n\n;lbu;"..prompt..";ylw;")
    write("> ")
    term.setTextColor(colors.lime)
    return utils.read()
end


---@class PromptMenuChoice
---@field name string
---@field exec function


---Displays a menu and prompts the user to select
---from the numbered list.
---@param title string
---@param choices PromptMenuChoice[] A list of choices with a name and function to execute
---@param clearScreen? boolean Whether or not to clear the screen on each render (defaults to true)
---@return boolean exiting True if the user chose to exit the prompt
function utils.promptMenu(title, choices, clearScreen)
::prompt::
    if clearScreen == nil then
        clearScreen = true
    end

    if clearScreen then
        term.clear()
        term.setCursorPos(1, 1)
    end

    utils.print(";ylw;" .. title)
    print()
    for i, choice in ipairs(choices) do
        utils.print("  ;lgy;" .. i .. ". ;wht;" .. choice.name)
    end
    utils.print("\n;red;  " .. #choices + 1 .. ". ;wht;Exit")
    print()
    term.setTextColor(colors.yellow)
    write("> ")
    term.setTextColor(colors.lime)
    local selected = tonumber(utils.read())

    if not selected or selected > (#choices + 1) then
        utils.print(";red;invalid choice; enter a number from the menu")
        print()
        utils.print(";gry;Enter to continue...")
        read()
        goto prompt
    end

    if selected == (#choices + 1) then
        return true
    end

    choices[selected].exec()
    return false
end


---Prints an error message to the script and prompts
---the user to continue.
---@param msg string
function utils.promptError(msg)
    printError(msg)
    print()
    utils.print(";lgy;Enter to continue...")
    read()
end


---
---A more advanced version of print, that allows embedded color codes
---to change the terminals color on-the-fly, as well as the option to
---print to a monitor.
---
---Supported Color Codes:
---
---     wht = white
---     org = orange
---     mgt = magenta
---     lbu = light blue
---     ylw = yellow
---     lim = lime
---     pnk = pink
---     gry = gray
---     lgy = light gray
---     cyn = cyan
---     ppl = purple
---     blu = blue
---     bwn = brown
---     grn = green
---     red = red
---     blk = black
---
---Usage:
---
---     ";org;Hello ;lim;World"
---
---@param text string The text to print with supported color codes
---@param mon? Monitor The monitor to print to, otherwise defaults to the terminal
function utils.print(text, mon)
    local display = term
    ---Preserve raw writing so we can handle new line chars
    local writeFunc = write
    if mon then
        display = mon
        writeFunc = display.write
    end

    ---Track where we are in the string
    local pos = 1

    for i = 1, #text do
        if i + 4 > #text then break end

        local code = string.sub(text, i, i + 4)
        local color = colorCodes[code]
        if color then
            writeFunc(string.sub(text, pos, i-1))
            text = string.gsub(text, code, "", 1)
            display.setTextColor(color)
            pos = i
        end
    end

    local newLine = "\n"
    if mon then
        newLine = ""
    end
    writeFunc(string.sub(text, pos, #text) .. newLine)
end


function utils.stripColorCodes(text)
    for key, _ in pairs(colorCodes) do
        if string.find(text, key, 1, true) then
            text = string.gsub(text, key, "")
        end
    end
    return text
end


---Deletes only script files from the computer
function utils.cleanScripts()
    local fileList = fs.list(".")
    for _, file in ipairs(fileList) do
        if file ~= "rom" and file ~= "disk" and not string.find(file, "%.") then
            fs.delete(file)
        end
    end
end


---Assumes the current disk is a formatted disk and installs
---its files to the computer.
function utils.installDisk()
    local files = fs.list("/disk")
    -- Assume at least 'get' and 'install' scripts will be present by default
    if #files < 3 then
        error("lacking minimum number of files to install")
    end

    -- Prevent potential side-effects from old scripts
    utils.cleanScripts()

    for _, file in ipairs(files) do
        if file ~= "get" and file ~= "startup" then
            local f = fs.open("/disk/" .. file, "r")
            if not f then error("missing install file: " .. file) end
            -- All startup files are suffixed with "_" so they don't start from disk
            if file == "startup_" then file = "startup" end
            utils.writeFile("/" .. file, f.readAll())
            f.close()
        end
    end
    shell.run("startup")
end


---Justifies the specified text within the specified area,
---towards the specified direction.
---@param text string
---@param direction 'left'|'right'|'center'
---@param area integer
function utils.justifyText(text, direction, area)
    local cleanText = utils.stripColorCodes(text)

    if #cleanText > area then
        error("area is too small to justify text")
    end

    if direction == 'left' then
        return text..string.rep(" ", area - #cleanText)
    elseif direction == 'right' then
        return string.rep(" ", area - #cleanText)..text
    elseif direction == 'center' then
        return (
            string.rep(" ", math.floor(area - #cleanText) / 2) ..
            text ..
            string.rep(" ", math.ceil((area - #cleanText) / 2))
        )
    end
end


return utils


