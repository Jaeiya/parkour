local utils = require("utils")
--
-- Copies all the files necessary to run a timer on
-- the computer, which is designed to write to a monitor
-- constellation. It will write to all monitors connected
-- to the specified protocol, via the monitor host script.
--
-- Once the setup is finished, restarting the server
-- will run the timer script.
--
local paths = {
    timer       = "disk/timer",
    xtimer      = "disk/xtimer",
    leaderBoard = "disk/leaderboard",
    utils       = "disk/utils",
}

if not fs.exists(paths.timer) then
    error("missing timer script")
end

if not fs.exists(paths.xtimer) then
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

utils.writeFile("protocol.txt", protocol)
utils.writeFile("startpos.txt", startPos)

local f = fs.open(paths.timer, "r")
utils.writeFile("/timer", f.readAll())
f.close()

f = fs.open(paths.leaderBoard, "r")
utils.writeFile("/leaderboard", f.readAll())
f.close()

f = fs.open(paths.xtimer, "r")
utils.writeFile("/startup", f.readAll())
f.close()

f = fs.open(paths.utils, "r")
utils.writeFile("/utils", f.readAll())
f.close()
