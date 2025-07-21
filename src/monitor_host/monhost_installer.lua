local utils = require("utils")


---
---
---Installs the monitor host on the connected computer.
---
---The monitor host is designed to be broadcast to from the
---leaderboard. You can set up multiple monitor hosts with
---the same protocol, so that you can have multiple timer
---displays.
---
---The only unique piece of information required is the
---hostname of the device.
---
---


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
print("Enter monitor host name")
write("> ")
config.hostname = read()


print()
print("Enter Constellation Protocol")
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
