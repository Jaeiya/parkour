local utils = require("utils")


---
---
---Allows writing to a monitor wirelessly.
---
---


local mon = utils.getMonitor()
if not mon then
    print()
    printError("script terminated; missing monitor")
    return false
end

local modem = utils.getModem()
if not modem then
    print()
    printError("monhost terminated; missing modem")
    return false
end

local width = mon.getSize()
if width < 11 or width > 11 then
    printError("monhost terminated; expected 5 block wide monitor")
    return false
end


local configFile = "monhost.cfg"
---@class MonhostConfig
local config = {
    protocol = "",
    hostname = ""
}
config = utils.loadConfig(configFile, config)

rednet.open(peripheral.getName(modem))
rednet.host(config.protocol, config.hostname)

mon.setTextScale(4.5)
mon.setTextColor(colors.lime)

utils.print(
    ";lgy;  host_name: ;cyn;"..config.hostname.."\n"..
    ";lgy;   protocol: ;cyn;"..config.protocol
)

-- Default to zero values
mon.setCursorPos(1, 1)
mon.write("00:00:00.00")

while true do
    local senderID, msg = rednet.receive(config.protocol)

    if type(msg) ~= "string" then
        rednet.send(senderID, "error: invalid message type", config.protocol)
    else
        mon.setCursorPos(1, 1)
        mon.write(msg)
    end
end
