
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


---@class PlayerStat
---@field PB integer
---@field Latest integer
---@field Total integer

mon.setPaletteColor(colors.black,  0x000000)
mon.setPaletteColor(colors.purple, 0xD596F2)
mon.setPaletteColor(colors.gray,   0x5A3F67)
mon.setPaletteColor(colors.green,  0x2ABD6F)
mon.setPaletteColor(colors.lime,   0x37FF95)

mon.setTextScale(1.5)

local monWidth, monHeight = mon.getSize()

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
    local hour = ";ppl;"..string.sub(timeStr, 1, 3)

    if hourNum > 0 and hourNum < 10 then
        hour = ";gry;0;ppl;"..tostring(hourNum)..':'
    elseif hourNum == 0 then
        hour = ";gry;00:"
    end

    local minuteNum = tonumber(string.sub(timeStr, 4, 5))
    local minute = ";ppl;"..string.sub(timeStr, 4, 6)

    if minuteNum > 0 and minuteNum < 10 and hourNum == 0 then
        minute = ";gry;0;ppl;"..tostring(minuteNum)..':'
    elseif hourNum == 0 and minuteNum == 0 then
        minute = ";gry;00:"
    end

    local secondNum = tonumber(string.sub(timeStr, 7, 8))
    local second = ';ppl;'..string.sub(timeStr, 7, 9)
    if secondNum > 0 and secondNum < 10 and minuteNum == 0 and hourNum == 0 then
        second = ';gry;0;ppl;'..tostring(secondNum)..':'
    end

    return hour..minute..second..";ppl;"..string.sub(timeStr, 10, #timeStr)
end


---Returns the specified integer as a zero-padded string up to
---to 3-digits. Insignificant digits are color-muted.
local function formatInt(int)
    if int < 10 then
        return ";gry;00;ppl;"..int
    elseif int < 100 then
        return ";gry;0;ppl;"..int
    else
        return ";ppl;"..int
    end
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
    mon.write(string.rep(" ", ((monWidth - #text) / 2)))
    mon.setBackgroundColor(colors.black)
    utils.print(";lbu;"..text, mon)
    mon.setBackgroundColor(colors.blue)
    mon.write(string.rep(" ", ((monWidth - #text) / 2) + 1))
    mon.setBackgroundColor(colors.black)
end

---@param stats PlayerStat
---@param yPos integer
local function renderTimeStats(stats, yPos)
    for key, val in pairs(stats) do
        mon.setCursorPos(1, yPos)
        utils.print(";org;" ..
            utils.centerText(utils.justifyText(key, 'right', 6)..": "..formatTime(val), mon), mon
        )
        yPos = yPos + 1
    end
end


---@param stats PlayerStat
---@param yPos integer
local function renderAttemptStats(stats, yPos)
    for key, val in pairs(stats) do
        mon.setCursorPos(1, yPos)
        utils.print(";org;" ..
            utils.centerText(utils.justifyText(key, 'right', 6)..": " ..
                utils.justifyText(formatInt(val), 'left', 11), mon
            ),
            mon
        )
        yPos = yPos + 1
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
    utils.print(utils.centerText(";grn;"..player.name.."'s ;org;Stats", mon), mon)
    renderSubHeader(" Time ", 4)
    renderTimeStats({
        PB = player.time.pb,
        Latest = player.time.current,
        Total = player.time.total
    }, 6)
    renderSubHeader(" Attempts ", 10)
    renderAttemptStats({
        PB = player.attempts.pb,
        Latest = player.attempts.current,
        Total = player.attempts.total
    }, 12)

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
    mon.setBackgroundColor(colors.orange)
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

        if not payload or #payload == 0 or #payload < #players then
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

