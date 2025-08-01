local utils = require("utils")
utils.clear()

local mon = utils.getMonitor()
if not mon then
    error("whoops no monitor")
end

local configFilePath = "medals.cfg"
---@class MedalsConfig
local config = {
    mudLives    = 4,
    bronzeLives = 4,
    silverLives = 4,
    goldLives   = 4,
}
config = utils.loadConfig(configFilePath, config)

mon.setTextScale(2)
mon.setPaletteColor(colors.black,     0x000000) -- Force true-black background
mon.setPaletteColor(colors.gray,      0x222222) -- zero-padding
mon.setPaletteColor(colors.brown,     0xAE7F52) -- Mud
mon.setPaletteColor(colors.orange,    0xE2801F) -- Bronze
mon.setPaletteColor(colors.white,     0xF1F8FF) -- Silver
mon.setPaletteColor(colors.yellow,    0xFFD800) -- Gold
mon.setPaletteColor(colors.pink,      0xFC00FF) -- Heart
mon.setPaletteColor(colors.lightGray, 0x444444) -- Lives


local function renderMedals()
    utils.clear(mon)
    local x, y = mon.getCursorPos()
    mon.setTextColor(colors.brown)
    mon.setCursorPos(x, y+1)
    utils.print("   ;bwn;Mud Medal     ;org;Bronze Medal", mon)
    mon.setCursorPos(1, y+2)

    local mudPadding    = ""
    local bronzePadding = ''
    if config.mudLives    < 10 then mudPadding    = ";gry;0" end
    if config.bronzeLives < 10 then bronzePadding = ";gry;0" end

    utils.print(
        "   "..mudPadding..";lgy;"..config.mudLives.." Lives        "..bronzePadding..";lgy;"..config.bronzeLives.." Lives",
        mon
    )

    mon.setCursorPos(1, y+4)
    utils.print(";wht;  Silver Medal    ;ylw;Gold Medal", mon)
    mon.setCursorPos(1, y+5)

    local silverPadding = ""
    local goldPadding   = ""
    if config.silverLives < 10 then silverPadding = ";gry;0" end
    if config.goldLives   < 10 then goldPadding   = ";gry;0" end

    utils.print(
        "   "..silverPadding..";lgy;"..config.silverLives.." Lives        "..goldPadding..";lgy;"..config.goldLives.." Lives",
        mon
    )

    mon.setCursorPos(1, y+7)
    utils.print(";pnk;" .. utils.centerText("Heart Medal", mon), mon)
    mon.setCursorPos(1, y+8)
    utils.print(";lgy;" .. utils.centerText("No Lives Lost", mon), mon)
end


---Sets the medal lives for the specified key in the
---config table
---@param key 'mudLives'|'bronzeLives'|'silverLives'|'goldLives'
local function setMedalLives(key)
    return function ()
    ::prompt::
        local val = tonumber(utils.prompt("Enter how many lives"))
        if not val or val == "" then
            utils.promptError("invalid life amount; try again!")
            goto prompt
        elseif val > 99 then
            utils.promptError("over 99 lives is not allowed!")
            goto prompt
        end
        config[key] = val
        utils.saveConfig(configFilePath, config)
    end
end


while true do
    renderMedals()
    local exited = utils.promptMenu(
        "Configure Medal Lives",
        {
            { name = "Set Mud Lives",    exec = setMedalLives('mudLives')},
            { name = "Set Bronze Lives", exec = setMedalLives('bronzeLives')},
            { name = "Set Silver Lives", exec = setMedalLives('silverLives')},
            { name = "Set Gold Lives",   exec = setMedalLives('goldLives')},
        }
    )
    if exited then
        return
    end
end
