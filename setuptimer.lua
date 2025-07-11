local timerPath = "disk/timer"
local xtimerPath = "disk/xtimer"

local function writeFile(filepath, text)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end

if not fs.exists(timerPath) then
    error("missing timer script")
end

if not fs.exists(xtimerPath) then
    error("missing xtimer script")
end

print()
print("Enter Constellation Protocol")
write("> ")
local protocol = read()

-- All file operations below, will overwrite
-- any existing files.

writeFile("protocol.txt", protocol)

local f = fs.open(timerPath, "r")
writeFile("/timer", f.readAll())
f.close()

f = fs.open(xtimerPath, "r")
writeFile("/startup", f.readAll())
f.close()
