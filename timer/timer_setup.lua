
--
-- Copies all the files necessary to run a timer on
-- the computer, which is designed to write to a monitor
-- constellation. It will write to all monitors connected
-- to the specified protocol, via the monitor host script.
--
-- Once the setup is finished, restarting the server
-- will run the timer script.
--
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

print()
print("Start Pos")
write("> ")
local startPos = read()


-- All file operations below, will overwrite
-- any existing files.

writeFile("protocol.txt", protocol)
writeFile("startpos.txt", startPos)

local f = fs.open(timerPath, "r")
writeFile("/timer", f.readAll())
f.close()

f = fs.open(xtimerPath, "r")
writeFile("/startup", f.readAll())
f.close()
