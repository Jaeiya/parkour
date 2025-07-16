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
    timer     = "disk/timer",
    xtimer    = "disk/xtimer",
    board     = "disk/board",
    boardData = "disk/board_data",
    utils     = "disk/utils",
    playerDetector = "disk/player_detector"
}


local function promptCoords(prompt)
::restart::
    print()
    term.setTextColor(colors.lightBlue)
    print(prompt)
    term.setTextColor(colors.white)
    write("> ")
    local coords = read()

    -- Validate coord entry
    local coordParts = utils.splitString(coords)
    if #coordParts ~= 3 then
        term.setTextColor(colors.red)
        print("invalid coord length; try again!")
        goto restart
    end

    -- Convert coords to numbers
    for i = 1, #coordParts do
        local coord = coordParts[i]
        coordParts[i] = tonumber(coord)
        if not coordParts[i] then
            term.setTextColor(colors.red)
            print("coordinate '" .. coord .. "' is not a number; try again!")
            goto restart
        end
    end

    return {
        x = coordParts[1],
        y = coordParts[2],
        z = coordParts[3],
    }
end


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


-- All file operations below, will overwrite
-- any existing files.

utils.saveTimerConfig(
    protocol,
    promptCoords("Enter Start Pos"),
    promptCoords("Enter End Pos")
)

local f = fs.open(paths.timer, "r")
utils.writeFile("/timer", f.readAll())
f.close()

f = fs.open(paths.board, "r")
utils.writeFile("/board", f.readAll())
f.close()

f = fs.open(paths.boardData, "r")
utils.writeFile("/board_data", f.readAll())
f.close()

f = fs.open(paths.xtimer, "r")
utils.writeFile("/startup", f.readAll())
f.close()

f = fs.open(paths.utils, "r")
utils.writeFile("/utils", f.readAll())
f.close()

f = fs.open(paths.playerDetector, "r")
utils.writeFile("/player_detector", f.readAll())
f.close()
