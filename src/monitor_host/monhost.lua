local utils = require("utils")
local ui = require("monhostui")


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

utils.clear()
print("... Starting Monitor Host ...")

local configFilePath = "monhost.cfg"
---@class MonhostConfig
local config = {
    protocol = "",
    hostname = ""
}
config = utils.loadConfig(configFilePath, config)

rednet.open(peripheral.getName(modem))
rednet.host(config.protocol, config.hostname)

mon.setTextScale(4.5)
mon.setTextColor(colors.lime)

-- Default to zero values
mon.setCursorPos(1, 1)
mon.write("00:00:00.00")


local function main()
    while true do
        local senderID, msg, proto = rednet.receive(config.protocol)

        -- Ignore any old protocols
        if proto == config.protocol then
            if type(msg) ~= "string" then
                rednet.send(senderID, "error: invalid message type", config.protocol)

            elseif msg == "@update_config" then
                config = utils.loadConfig(configFilePath, {})
                rednet.host(config.protocol, config.hostname)

            else
                mon.setCursorPos(1, 1)
                mon.write(msg)
            end
        end
    end
end


parallel.waitForAny(
    main,
    function () ui(config) end
)

