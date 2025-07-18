
local utils = require("utils")
local mon = nil
for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "monitor" then
        mon = peripheral.wrap(name)
        break
    end
end

if not mon then
    term.setTextColor(colors.red)
    print("no monitor found; connect a monitor!")
end

-- Prevents linter warnings
assert(mon, "monitor should not be nil")

local configFile = "display.cfg"
local config = {
    text = "default text",
    scale = 1,
    color = 1,
    stars = "1",
}
config = utils.loadConfig(configFile, config)


local textScale  = config.scale
local xPos       = 1
local yPos       = 1
local textColor  = config.color
local starRating = config.stars
local text       = config.text


local function renderDisplay()
    mon.clear()
    mon.setCursorPos(xPos, yPos)
    mon.setTextScale(textScale)
    mon.setTextColor(colors.lightGray)
    mon.write(utils.centerText(starRating .. "*", mon))
    mon.setTextColor(textColor)
    mon.setCursorPos(1, yPos+1)
    mon.write(utils.centerText(text, mon))
end


local function setText()
    print()
    print("Enter new text")
    print()
    write("> ")
    text = read()
    config.text = text
    utils.saveConfig(configFile, config)
end


local function setColor()
::start::
    print()
    term.setTextColor(colors.white)
    print("Enter new text color")
    print()
    write("> ")
    local color = read()

    if not colors[color] then
        term.setTextColor(colors.red)
        print("'" .. color .. "' is not a valid color")
        goto start
    end

    textColor = colors[color]
    config.color = textColor
    utils.saveConfig(configFile, config)
end


local function setScale()
::start::
    print()
    term.setTextColor(colors.white)
    print("Enter new text scale")
    print()
    write("> ")
    local scale = read()
    scale = tonumber(scale)

    if not scale then
        term.setTextColor(colors.red)
        print("scale should be a number")
        goto start
    end

    if scale < 0.5 or scale > 5 then
        term.setTextColor(colors.red)
        print("invalid scale; min: 0.5, max: 5")
        goto start
    end

    if scale % 1 > 0 then
        if (scale % 1) * 10 ~= 5 then
            term.setTextColor(colors.red)
            print("the smallest increment allowed is 0.5")
            goto start
        end
    end

    textScale = scale
    config.scale = scale
    utils.saveConfig(configFile, config)
end


local function setStarRating()
::start::
    print()
    term.setTextColor(colors.white)
    print("Enter new star rating")
    print()
    write("> ")
    local rating = read()
    rating = tonumber(rating)

    if not rating then
        term.setTextColor(colors.red)
        print("star rating should be a number")
        goto start
    end

    starRating = tostring(rating)
    config.stars = starRating
    utils.saveConfig(configFile, config)
end



local choices = {
    setText,
    setColor,
    setScale,
    setStarRating,
}


::menu::
renderDisplay()
term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.white)
print("Display Config")
print()
print(" 1. Set Text")
print(" 2. Set Color")
print(" 3. Set Scale")
print(" 4. Set Star Rating")
print()
write("> ")
local choice = read()

if not tonumber(choice) then
    term.setTextColor(colors.red)
    print("invalid choice; try again")
    print()
    term.setTextColor(colors.white)
    write("Enter to continue...")
    read()
    goto menu
end

if not choices[tonumber(choice)] then
    term.setTextColor(colors.red)
    print("choice does not exist; try again")
    print()
    term.setTextColor(colors.white)
    write("Enter to continue...")
    read()
    goto menu
end

choices[tonumber(choice)]()
goto menu
