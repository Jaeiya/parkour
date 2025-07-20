
--
-- Allows writing to the monitor wirelessly, by listening
-- on a specific protocol.
--
local utils = require("utils")

local modem      = utils.getModem()
local mon        = utils.getMonitor()
local configFile = "monhost.cfg"
local config = {
    protocol = "",
    hostname = ""
}

-- Config file should be created by installer
if not fs.exists(configFile) then
    error("missing config file")
end

config = utils.loadConfig(configFile, config)

rednet.open(peripheral.getName(modem))
rednet.host(config.protocol, config.hostname)

mon.setTextScale(4.5)
mon.setTextColor(colors.lime)

local function isValidMonitorSize()
    local width = mon.getSize()
    if width < 11 or width > 11 then
        return false
    end

    return true
end

if not isValidMonitorSize() then error("Must be 5 blocks long") end

print("Hostname: " .. config.hostname)
print("Protocol: " .. config.protocol)

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
