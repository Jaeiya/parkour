
local utils = require('utils')
utils.clear()


local mon = utils.getMonitor()
if not mon then
    printError("statboard terminated; missing monitor")
    return false
end


local pd  = utils.getPlayerDetector()
if not pd then
    printError("statboard terminated; missing player detector")
    return false
end


local modem = utils.getModem('wireless')
if not modem then
    printError("statboard terminated; missing modem")
    return false
end


mon.setPaletteColor(colors.black,     0x000000)
mon.setPaletteColor(colors.magenta,   0xD596F2) -- Brighter & paler magenta
mon.setPaletteColor(colors.gray,      0x5A3F67) -- Dark Magenta
mon.setPaletteColor(colors.brown,     0xAE7F52) -- Mud
mon.setPaletteColor(colors.orange,    0xE2801F) -- Bronze
mon.setPaletteColor(colors.white,     0xF1F8FF) -- Silver
mon.setPaletteColor(colors.yellow,    0xFFD800) -- Gold
mon.setPaletteColor(colors.pink,      0xFC00FF) -- Heart
mon.setPaletteColor(colors.lightGray, 0x555555)
mon.setPaletteColor(colors.green,     0x2FD97F)

mon.setTextScale(1.5)

local monWidth, monHeight = mon.getSize()
local sortedKeys = { 'pb', 'latest', 'total' }

---@type Player[]
local players = {}
local playerIndex = 1

local function findPlayer(name)
    for i in ipairs(players) do
        if players[i].name == name then
            return players[i], i
        end
    end
    return nil
end

---Returns the time, formatted to ticks, but with
---the insignificant digits color-muted
---@param time integer
local function formatTime(time)
    local timeStr = utils.getTimerStr(time)

    local hourNum = tonumber(string.sub(timeStr, 1, 2))
    local hour = ";mgt;"..string.sub(timeStr, 1, 3)

    if hourNum > 0 and hourNum < 10 then
        hour = ";gry;0;mgt;"..tostring(hourNum)..':'
    elseif hourNum == 0 then
        hour = ";gry;00:"
    end

    local minuteNum = tonumber(string.sub(timeStr, 4, 5))
    local minute = ";mgt;"..string.sub(timeStr, 4, 6)

    if minuteNum > 0 and minuteNum < 10 and hourNum == 0 then
        minute = ";gry;0;mgt;"..tostring(minuteNum)..':'
    elseif hourNum == 0 and minuteNum == 0 then
        minute = ";gry;00:"
    end

    local secondNum = tonumber(string.sub(timeStr, 7, 8))
    local second = ';mgt;'..string.sub(timeStr, 7, 9)
    if secondNum > 0 and secondNum < 10 and minuteNum == 0 and hourNum == 0 then
        second = ';gry;0;mgt;'..tostring(secondNum)..':'
    end

    return hour..minute..second..";mgt;"..string.sub(timeStr, 10, #timeStr)
end


---Returns the specified integer as a zero-padded string up to
---to 3-digits. Insignificant digits are color-muted.
local function formatInt(int)
    if int < 10 then
        return ";gry;00;mgt;"..int
    elseif int < 100 then
        return ";gry;0;mgt;"..int
    else
        return ";mgt;"..int
    end
end


---@param code string
local function colorMedalCode(code)
    local medal = string.sub(code, 1, 1)
    if medal == 'M' then return ';bwn;'..code end
    if medal == 'B' then return ';org;'..code end
    if medal == 'S' then return ';wht;'..code end
    if medal == 'G' then return ';ylw;'..code end
    if medal == 'H' then return ';pnk;'..code end
    if medal == 'F' then return ';red;'..code end
    return ';red;DNF'
end


local function renderButton(text, xPos, yPos)
    mon.setCursorPos(xPos, yPos-1)
    mon.setBackgroundColor(colors.green)
    mon.write(string.rep(" ", #text))
    mon.setCursorPos(xPos, yPos)
    utils.print(";blk;"..text, mon)
    mon.setBackgroundColor(colors.black)
end


local function renderSubHeader(text, yPos)
    mon.setCursorPos(1, yPos)
    mon.setBackgroundColor(colors.blue)
    local textLen = #utils.stripColorCodes(text)
    mon.write(string.rep(" ", ((monWidth - textLen) / 2)))
    mon.setBackgroundColor(colors.black)
    utils.print(text, mon)
    mon.setBackgroundColor(colors.blue)
    mon.write(string.rep(" ", ((monWidth - textLen) / 2) + 1))
    mon.setBackgroundColor(colors.black)
end

---@param player Player
---@param yPos integer
local function renderTimeStats(player, yPos)
    for _, key in ipairs(sortedKeys) do
        local timeStr = utils.justifyText(";cyn;"..key, 'right', 7) .. ';lgy;...' .. formatTime(player.time[key])
        local attemptStr = ';lgy;...x' .. formatInt(player.attempts[key])
        mon.setCursorPos(1, yPos)
        utils.print(utils.centerText(timeStr..attemptStr, mon), mon)
        yPos = yPos + 1
    end
end


---@param player Player
local function renderMedalStats(player, yPos)
    for _, key in pairs(sortedKeys) do
        ---'latest' data resets every pb, so this line won't matter if the
        ---player has max medal
        if player.medal.breakdown.pb == 'H0' and key == 'latest' then
            goto continue
        end

        ---The lives and attempts will be the same as the pb
        ---so we ignore them
        if player.medal.breakdown.pb == 'H0' and key == 'total' then
            mon.setCursorPos(1, yPos)
            utils.print(utils.centerText(
                utils.justifyText(
                    ';cyn;'..key..';lgy;...'..colorMedalCode(player.medal.breakdown[key]),
                    'left',
                    23
                ), mon),
                mon
            )
            yPos = yPos + 1
            goto continue
        end

        mon.setCursorPos(1, yPos)
        local str = colorMedalCode(player.medal.breakdown[key]) ..
                    ';lgy;...x'..formatInt(player.medal.livesUsed[key])..';lgy;...x' ..
                    formatInt(player.medal.attempts[key])

        utils.print(utils.centerText(utils.justifyText(';cyn;'..key, 'right', 6)..';lgy;...'.. str, mon), mon)
        yPos = yPos + 1
        ::continue::
    end
end


local function renderStats()
    utils.clear(mon)

    if not players or #players == 0 then
        mon.setCursorPos(1, 3)
        utils.print(utils.centerText(";org;No Player Data", mon), mon)
        return
    end

    local player = players[playerIndex]
    mon.setCursorPos(1, 2)
    utils.print(utils.centerText(";lim;"..player.name..' ;lgy;['..colorMedalCode(player.medal.breakdown.pb)..';lgy;]', mon), mon)
    renderSubHeader(" ;lbu;Time;lgy;/;lbu;Attempts ", 4)
    renderTimeStats(player, 6)

    renderSubHeader(" ;lbu;Medal;lgy;/;lbu;Lives;lgy;/;lbu;Attempts ", 11)
    renderMedalStats(player, 13)

    if #players > 1 then
        renderButton("  BACK  ", 1, monHeight)
        renderButton("  NEXT  ", monWidth - 7, monHeight)
    end
end


local function highlightButton(buttonType)
    local xpos = 1
    local btnText = "  BACK  "
    if buttonType == "next" then
        xpos = monWidth - 7
        btnText = "  NEXT  "
    end

    mon.setCursorPos(xpos, monHeight-1)
    mon.setBackgroundColor(colors.cyan)
    mon.write("        ")
    mon.setCursorPos(xpos, monHeight)
    utils.print(";blk;" .. btnText, mon)
    mon.setBackgroundColor(colors.black)
    sleep(0.2)
end


---@param config StatBoardConfig
local function statBoardHandler(config)
    while true do
        local _, msg, proto = rednet.receive()

        ---@type MessageEvent
        local msgEvent = msg

        if config.protocol ~= proto then
            goto skip
        end

        if msgEvent.action ~= "update_player_data" then
            goto skip
        end

        ---@type Player[]|nil
        local payload = msgEvent.payload

        if not payload or #payload == 0 or #payload ~= #players then
            players = payload
            playerIndex = 1
            goto continue
        end

        for i in ipairs(payload) do
            local player, index = findPlayer(payload[i].name)
            if player and index then
                players[index] = payload[i]
            else
                players[#players+1] = payload[i]
            end
        end

        ::continue::
        renderStats()
    ::skip::
    end
end


local function buttonHandler()
    while true do
        renderStats()
        local _, _, x, y = os.pullEvent("monitor_touch")

        if #players == 0 then goto continue end

        if x <= 8 and y >= monHeight-1 then
            playerIndex = playerIndex - 1
            if playerIndex == 0 then
                playerIndex = #players
            end
            highlightButton()

        elseif x >= monWidth - 6 and y >= monHeight - 1 then
            playerIndex = playerIndex + 1
            if playerIndex > #players then
                playerIndex = 1
            end
            highlightButton("next")
        end

    ::continue::
    end
end


local function updateHandler()
    while true do
        local _, msg = os.pullEvent("update")

        ---@cast msg MessageEvent

        if msg.action == "view_player" then
            local p, index = findPlayer(msg.payload)
            if p and index then
                playerIndex = index
                renderStats()
            end
        end
    end
end

utils.clear(mon)


---@param config StatBoardConfig
return function(config)
    utils.clear(mon)
    mon.setCursorPos(1, 3)
    utils.print(utils.centerText(";wht;... Starting Stat Board ...", mon), mon)

    rednet.open(peripheral.getName(modem))
    rednet.host(config.protocol, config.hostname)

    parallel.waitForAny(
        function() statBoardHandler(config) end,
        buttonHandler,
        updateHandler
    )
end

