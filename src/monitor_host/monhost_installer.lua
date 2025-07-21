local utils = require("utils")


---
---
---Installs the monitor host on the connected computer.
---
---The monitor host is designed to be broadcasted to from the
---leaderboard. You can set up multiple monitor hosts with
---the same protocol, so that you can have multiple timer
---displays.
---
---The only unique piece of information required is the
---hostname of the device.
---
---


print()
local mon = utils.getMonitor()
if not mon then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Attach an ;lim;advanced monitor ;org;to this computer\n\n"
    )
    return
end

---We can't calculate the size without knowing the scale
mon.setTextScale(4.5)
local monW = mon.getSize()
if monW < 11 then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;The ;lim;monitor ;org;needs to be at least ;lim;5 ;org;blocks wide\n\n"
    )
    return
end

local modem = utils.getModem()
if not modem then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Attach an ;lim;ender modem ;org;to this computer\n\n"
    )
    return
end

if not modem.isWireless() then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;The attached ;lim;modem ;org;needs to be ;lim;wireless\n\n"
    )
    return
end


---@class MonhostPaths
---@field monhost string
---@field startup string
---@field utils   string

---@type MonhostPaths
local paths = {
    monhost = "disk/monhost",
    startup = "disk/monhost_startup",
    utils   = "disk/utils",
}


local config = {
    hostname = "",
    protocol = ""
}

utils.clear()
utils.print(";ylw;   ... Configuring Monitor Host ...")
config.hostname = utils.prompt("Enter Host Name ;org;(unique)")
config.protocol = utils.prompt("Enter Protocol ;lgy;(anything)")

for _, path in pairs(paths) do
    local f = fs.open(path, "r")
    if not f then
        error("could not find install file: " .. path)
    end
    local installPath = string.gsub(path, "disk/", "")

    if path == paths.startup then
        utils.writeFile("startup", f.readAll())
    else
        utils.writeFile(installPath, f.readAll())
    end

    f.close()
end


utils.writeFile("monhost.cfg", textutils.serialize(config))

os.reboot()
