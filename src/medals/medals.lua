local utils = require("utils")
utils.clear()

local mon = utils.getMonitor()
if not mon then
    printError("medals script terminated; missing monitor")
    return
end

local modem = utils.getModem('wired')
if not modem then
    printError("medals script terminated; missing wired modem")
    return
end

local dbFilePath = "medals.db"
---@class MedalsConfig
local medalLives = {
    mud    = 4,
    bronze = 4,
    silver = 4,
    gold   = 4,
    heart  = 0,
}
medalLives = utils.loadConfig(dbFilePath, medalLives)

utils.clear(mon)
mon.setTextScale(2)
mon.setPaletteColor(colors.black,     0x000000) -- Force true-black background
mon.setPaletteColor(colors.gray,      0x222222) -- zero-padding
mon.setPaletteColor(colors.brown,     0xAE7F52) -- Mud
mon.setPaletteColor(colors.orange,    0xE2801F) -- Bronze
mon.setPaletteColor(colors.white,     0xF1F8FF) -- Silver
mon.setPaletteColor(colors.yellow,    0xFFD800) -- Gold
mon.setPaletteColor(colors.pink,      0xFC00FF) -- Heart
mon.setPaletteColor(colors.lightGray, 0x444444) -- Lives

local chan = 420
modem.open(chan)



local function renderMedals()
    utils.clear(mon)
    local x, y = mon.getCursorPos()
    mon.setTextColor(colors.brown)
    mon.setCursorPos(x, y+1)
    utils.print("   ;bwn;Mud Medal     ;org;Bronze Medal", mon)
    mon.setCursorPos(1, y+2)

    local mudPadding    = ""
    local bronzePadding = ''
    if medalLives.mud    < 10 then mudPadding    = ";gry;0" end
    if medalLives.bronze < 10 then bronzePadding = ";gry;0" end

    utils.print(
        "   "..mudPadding..";lgy;"..medalLives.mud.." Lives        "..bronzePadding..";lgy;"..medalLives.bronze.." Lives",
        mon
    )

    mon.setCursorPos(1, y+4)
    utils.print(";wht;  Silver Medal    ;ylw;Gold Medal", mon)
    mon.setCursorPos(1, y+5)

    local silverPadding = ""
    local goldPadding   = ""
    if medalLives.silver < 10 then silverPadding = ";gry;0" end
    if medalLives.gold   < 10 then goldPadding   = ";gry;0" end

    utils.print(
        "   "..silverPadding..";lgy;"..medalLives.silver.." Lives        "..goldPadding..";lgy;"..medalLives.gold.." Lives",
        mon
    )

    mon.setCursorPos(1, y+7)
    utils.print(";pnk;" .. utils.centerText("Heart Medal", mon), mon)
    mon.setCursorPos(1, y+8)
    utils.print(";lgy;" .. utils.centerText("No Lives Lost", mon), mon)
end


---Sets the medal lives for the specified key in the
---config table
---@param key 'mud'|'bronze'|'silver'|'gold'
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
        medalLives[key] = val
        utils.saveConfig(dbFilePath, medalLives)
    end
end



local function renderMenu()
    while true do
        renderMedals()
        local exited = utils.promptMenu(
            "Configure Medal Lives",
            {
                { name = "Set Mud Lives",    exec = setMedalLives('mud')},
                { name = "Set Bronze Lives", exec = setMedalLives('bronze')},
                { name = "Set Silver Lives", exec = setMedalLives('silver')},
                { name = "Set Gold Lives",   exec = setMedalLives('gold')},
            }
        )
        if exited then
            return
        end
        modem.transmit(chan, chan, medalLives)
    end
end




parallel.waitForAny(
    function()
        while true do
            local _, _, _, _, msg = os.pullEvent("modem_message")
            if msg == 'send_medal_lives' then
                modem.transmit(chan, chan, medalLives)
            end
        end
    end,
    renderMenu
)



