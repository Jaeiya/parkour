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
    printError("Installation Aborted")
    term.setTextColor(colors.orange)
    write("Attach a ")
    term.setTextColor(colors.lime)
    write("monitor ")
    term.setTextColor(colors.orange)
    write("to this computer\n\n")
    return
end

---We can't calculate the size without knowing the scale
mon.setTextScale(4.5)
local monW = mon.getSize()
if monW < 11 then
    printError("Installation Aborted")
    term.setTextColor(colors.orange)
    write("The ")
    term.setTextColor(colors.lime)
    write("monitor ")
    term.setTextColor(colors.orange)
    write("needs to be at least 5 blocks wide\n\n")
    return
end

local modem = utils.getModem()
if not modem then
    printError("Installation Aborted")
    term.setTextColor(colors.orange)
    write("Attach an ")
    term.setTextColor(colors.lime)
    write("ender wireless modem ")
    term.setTextColor(colors.orange)
    write("to this computer\n\n")
    return
end

if not modem.isWireless() then
    printError("Installation Aborted")
    term.setTextColor(colors.orange)
    write("The attached ")
    term.setTextColor(colors.lime)
    write("modem ")
    term.setTextColor(colors.orange)
    write("needs to be ")
    term.setTextColor(colors.lime)
    write("wireless\n\n")
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

print()
term.setTextColor(colors.lightBlue)
write("Enter Host Name ")
term.setTextColor(colors.orange)
write("(unique)\n")
term.setTextColor(colors.white)
write("> ")
config.hostname = read()


print()
term.setTextColor(colors.lightBlue)
write("Enter Protocol ")
term.setTextColor(colors.lightGray)
write("(anything)\n")
term.setTextColor(colors.white)
write("> ")
config.protocol = read()


--
-- All file operations below will overwrite any existing files.
--


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
