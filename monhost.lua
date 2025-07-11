local hostnameFile = "hostname.txt"
local protocolFile = "protocol.txt"

if not fs.exists(hostnameFile) then
    error("could not find host name")
end

if not fs.exists(protocolFile) then
    error("could not find protocol")
end

local f = fs.open(hostnameFile, "r")
local hostname = f.readAll()
f.close()

f = fs.open(protocolFile, "r")
local protocol = f.readAll()
f.close()


local modem = peripheral.find("modem")
if not modem then error("missing modem") end

rednet.open(peripheral.getName(modem))
rednet.host(protocol, hostname)

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

print("Hostname: " .. hostname)
print("Protocol: " .. protocol)

while true do
    local senderID, msg = rednet.receive(protocol)

    if type(msg) ~= "string" then
        rednet.send(senderID, "error: invalid message type", protocol)
    else
        mon.setCursorPos(1, 1)
        mon.write(msg)
    end
end
