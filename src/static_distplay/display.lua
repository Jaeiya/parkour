
local utils = require("utils")

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
    text = "default text",
    scale = 1,
    color = 1,
    stars = 1,
}
config = utils.loadConfig(configFile, config)


local function renderDisplay()
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.setTextScale(config.scale)
    mon.setTextColor(colors.lightGray)
    mon.write(utils.centerText(config.stars .. "*", mon))
    mon.setTextColor(config.color)
    mon.setCursorPos(1, 2)
    mon.write(utils.centerText(config.text, mon))
end


local function setText()
    config.text = utils.prompt("Enter new text")
    utils.saveConfig(configFile, config)
end


local function setColor()
::prompt::
    local color = utils.prompt("Enter new color")

    if not colors[color] then
        printError("'" .. color .. "' is not a valid color")
        goto prompt
    end

    config.color = colors[color]
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


local function setStarRating()
::prompt::
    local stars = tonumber(utils.prompt("Enter new stars rating"))

    if not stars then
        printError("star rating should be a number")
        goto prompt
    end

    config.stars = stars
    utils.saveConfig(configFile, config)
end

::menu::
renderDisplay()
local exiting = utils.promptMenu("Display Config", {
    { name = "Set Text",        exec = setText },
    { name = "Set Color",       exec = setColor },
    { name = "Set Scale",       exec = setScale },
    { name = "Set Star Rating", exec = setStarRating },
})

if exiting then
    return
end
goto menu
