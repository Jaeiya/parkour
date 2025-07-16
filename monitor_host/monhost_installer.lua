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
local paths = {
    monhost = "disk/monhost",
    startup = "disk/monhost_startup"
}

local function writeFile(filepath, text)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end

if not fs.exists(paths.monhost) then
    error("missing monhost script")
end

if not fs.exists(paths.startup) then
    error("missing monhost startup script")
end

print()
print("Enter monitor host name")
write("> ")
local hostname = read()

print()
print("Enter Constellation Protocol")
write("> ")
local protocol = read()


-- All file operations below, will overwrite
-- any existing files.

writeFile("hostname.txt", hostname)
writeFile("protocol.txt", protocol)

local f = fs.open(paths.monhost, "r")
writeFile("/monhost", f.readAll())
f.close()

f = fs.open(paths.startup, "r")
writeFile("/startup", f.readAll())
f.close()

