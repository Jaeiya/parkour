local utils = require('utils')
local state = require('boardstate')



local mon = utils.getMonitor()
if not mon then
    printError("life bridge terminated; missing monitor")
    return false
end

local modem = utils.getModem('wired')
if not modem then
    printError("life bridge terminated; missing wired modem")
    return false
end


local chan = 420
modem.open(chan)


---Attempt to retrieve medals data from the medals computer
local function waitOnMedalData()
    mon.setCursorPos(1, 3)
    term.setCursorPos(1, 3)

    local text = utils.centerText(";cyn;... Getting Medal Data ...", mon)
    utils.print(text, mon)
    utils.print(text)

    modem.transmit(chan, chan, "send_medal_lives")

    while true do
        local _, _, sentChan, _, msg, _ = os.pullEvent("modem_message")
        if sentChan == chan then
            state.medalLives = msg
        end
        return
    end
end


---If we don't immediately get a response from the medals
---computer, then we retry until we do.
local function retryMedalData()
    local count = 0
    while true do
        sleep(2)
        count = count + 1
        mon.clearLine()
        term.clearLine()
        mon.setCursorPos(1, 3)
        term.setCursorPos(1, 3)
        local text = utils.centerText(";cyn;... Getting Medal Data (;red;"..count..";cyn;) ...", mon)
        utils.print(text, mon)
        utils.print(text)
        modem.transmit(chan, chan, "send_medal_lives")
    end
end


-- Try to get initial medal data and keep retrying if we don't get a response
-- within a reasonable time.
parallel.waitForAny(
    waitOnMedalData,
    retryMedalData
)


---Any life updates made by the medals computer will update the
---medal lives state.
return function()
    while true do
        local _, _, sentChan, _, msg, _ = os.pullEvent("modem_message")
        if sentChan == chan then
            state.medalLives = msg
        end
    end
end
