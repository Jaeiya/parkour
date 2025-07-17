local utils = require("utils")
local lib = require("board_lib")
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
    boardTimer     = "disk/board_timer",
    boardStartup   = "disk/board_startup",
    board          = "disk/board",
    boardData      = "disk/board_lib",
    boardRedstone  = "disk/board_redstone",
    utils          = "disk/utils",
    playerDetector = "disk/detect_player"
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

local function promptProtocol()
    print()
    print("Enter Constellation Protocol")
    write("> ")
    return read()
end


if not fs.exists(paths.boardTimer) then
    error("missing board timer script")
end

if not fs.exists(paths.boardStartup) then
    error("missing board startup script")
end


-- All file operations below, will overwrite
-- any existing files.

lib.saveBoardConfig(
    promptProtocol(),
    promptCoords("Enter Start Pos"),
    promptCoords("Enter End Pos")
)

local f = fs.open(paths.boardTimer, "r")
utils.writeFile("/board_timer", f.readAll())
f.close()

f = fs.open(paths.board, "r")
utils.writeFile("/board", f.readAll())
f.close()

f = fs.open(paths.boardData, "r")
utils.writeFile("/board_lib", f.readAll())
f.close()

f = fs.open(paths.boardStartup, "r")
utils.writeFile("/startup", f.readAll())
f.close()

f = fs.open(paths.boardRedstone, "r")
utils.writeFile("/board_redstone", f.readAll())
f.close()

f = fs.open(paths.utils, "r")
utils.writeFile("/utils", f.readAll())
f.close()

f = fs.open(paths.playerDetector, "r")
utils.writeFile("/detect_player", f.readAll())
f.close()

os.reboot()
