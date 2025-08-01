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

-- Try to get medal data and keep retrying if we don't get a response
-- within a reasonable time.
parallel.waitForAny(
    function ()
        mon.setCursorPos(1, 3)
        term.setCursorPos(1, 3)
        local text = utils.centerText(";cyn;... Getting Medal Data ...", mon)
        utils.print(text, mon)
        utils.print(text)
        modem.transmit(chan, chan, "send_medal_lives")

        while true do
            local _, _, _, _, msg, _ = os.pullEvent("modem_message")
            state.medalLives = msg
            return
        end
    end,
    function ()
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
)


return function()
    while true do
        local _, _, _, _, msg, _ = os.pullEvent("modem_message")
        state.medalLives = msg
    end
end
