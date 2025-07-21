
--
-- Allows writing to the monitor wirelessly, by listening
-- on a specific protocol.
--
local utils = require("utils")

local mon = utils.getMonitor()
if not mon then
    print()
    printError("script terminated; missing monitor")
    return false
end

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

local modem = utils.getModem()
if not modem then
    print()
    printError("monhost terminated; missing modem")
    return false
end

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

term.setTextColor(colors.lightGray)
write("  host_name: ")
term.setTextColor(colors.cyan)
write(config.hostname .. "\n")
term.setTextColor(colors.lightGray)
write("   protocol: ")
term.setTextColor(colors.cyan)
write(config.protocol .. "\n")

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
