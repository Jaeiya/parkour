
local utils = require("utils")
local mon = peripheral.wrap("monitor_0")
if not mon then error("monitor not connected") end

local textScale  = 1
local xPos       = 1
local yPos       = 1
local textColor  = colors.white
local starRating = "1"
local text       = "default text"


local function render()
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
end



local choices = {
    setText,
    setColor,
    setScale,
    setStarRating,
}


::menu::
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
render()
goto menu
