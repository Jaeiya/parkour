--
-- Sets up the monitor hosting listener, allowing you
-- to set the host name and protocol.
--
-- The hostname must be unique but the protocol is
-- designed to be broadcasted to. This means multiple
-- monitor hosts can receive messages from the same
-- protocol. This means we can create multiple timers
-- on a single parkour level and they'll all be synced.
--
-- It creates all the necessary files for running the
-- monitor host. Just setup and restart computer. It
-- will run automatically.
--
local utils = require("utils")

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


for key, path in pairs(paths) do
    local f = fs.open(path, "r")
    if not f then
        error("could not find install file: " .. path)
    end
    local installPath = string.gsub(path, "disk/", "")

    if key == paths.startup then
        utils.writeFile("startup", f.readAll())
    else
        utils.writeFile(installPath, f.readAll())
    end

    f.close()
end


utils.writeFile("monhost.cfg", textutils.serialize(config))

os.reboot()
