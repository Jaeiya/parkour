
local utils = require("utils")
utils.clear()

---@type Monitor|nil
local mon = nil

-- Find the monitor connected through the modem
for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "monitor" then
        mon = peripheral.wrap(name)
        break
    end
end

if not mon then
    printError("display terminated; missing monitor")
    return
end


local configFile = "display.cfg"

---@class DisplayConfig
local config = {
    textLine1 = "Line 1",
    textLine2 = "Line 2",
    colorLine1 = 1,
    colorLine2 = 2,
    scale = 1,
}
config = utils.loadConfig(configFile, config)

local function renderDisplay()
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.setTextScale(config.scale)

    if config.textLine1 ~= "" then
        mon.setTextColor(config.colorLine1)
        mon.write(utils.centerText(config.textLine1, mon))
    end

    mon.setCursorPos(1, 2)
    if config.textLine2 then
        mon.setTextColor(config.colorLine2)
        mon.write(utils.centerText(config.textLine2, mon))
    end
end


local function setTextLine1()
    config.textLine1 = utils.prompt("Enter new text")
    utils.saveConfig(configFile, config)
end


local function setTextLine2()
    config.textLine2 = utils.prompt("Enter new text")
    utils.saveConfig(configFile, config)
end


local function setColorLine1()
::prompt::
    local color = utils.prompt("Enter new color")

    if not colors[color] then
        printError("'" .. color .. "' is not a valid color")
        goto prompt
    end

    config.colorLine1 = colors[color]
    utils.saveConfig(configFile, config)
end


local function setColorLine2()
::prompt::
    local color = utils.prompt("Enter new color")

    if not colors[color] then
        printError("'" .. color .. "' is not a valid color")
        goto prompt
    end

    config.colorLine2 = colors[color]
    utils.saveConfig(configFile, config)
end


local function setScale()
::prompt::
    local scale = tonumber(utils.prompt("Enter new text scale"))

    if not scale then
        printError("scale should be a number")
        goto prompt
    end

    if scale < 0.5 or scale > 5 then
        printError("invalid scale; min: 0.5, max: 5")
        goto prompt
    end

    if scale % 1 > 0 then
        if (scale % 1) * 10 ~= 5 then
            printError("the smallest increment allowed is 0.5")
            goto prompt
        end
    end

    config.scale = scale
    utils.saveConfig(configFile, config)
end



::menu::
renderDisplay()
local exiting = utils.promptMenu("Display Config", {
    { name = "Set Text Line 1",  exec = setTextLine1 },
    { name = "Set Text Line 2",  exec = setTextLine2 },
    { name = "Set Color Line 1", exec = setColorLine1 },
    { name = "Set Color Line 2", exec = setColorLine2 },
    { name = "Set Scale",        exec = setScale },
})

if exiting then
    return
end
goto menu
