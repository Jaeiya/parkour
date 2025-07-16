
--
-- Allows writing to the monitor wirelessly, by listening
-- on a specific protocol.
--
local configFile = "monhost.cfg"
local config = {
    protocol = "",
    hostname = ""
}

if not fs.exists(configFile) then
    error("missing config file")
end

local f = fs.open(configFile, "r")
local data = textutils.unserialize(f.readAll())
f.close()
config.protocol = data.protocol
config.hostname = data.hostname


local modem = peripheral.find("modem")
if not modem then error("missing modem") end

rednet.open(peripheral.getName(modem))
rednet.host(config.protocol, config.hostname)

local mon = peripheral.find("monitor")
if not mon then error("missing monitors") end
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
