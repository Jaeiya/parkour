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
    boardUI        = "disk/board_ui",
    boardRedstone  = "disk/board_redstone",
    utils          = "disk/utils",
    playerDetector = "disk/detect_player"
}


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
    utils.promptCoords("Enter Start Pos"),
    utils.promptCoords("Enter End Pos")
)

local f = fs.open(paths.boardTimer, "r")
utils.writeFile("/board_timer", f.readAll())
f.close()

f = fs.open("settings", "w")
utils.writeFile("settings", "motd.enable=false")
f.close()

f = fs.open(paths.board, "r")
utils.writeFile("/board", f.readAll())
f.close()

f = fs.open(paths.boardData, "r")
utils.writeFile("/board_lib", f.readAll())
f.close()

f = fs.open(paths.boardUI, "r")
utils.writeFile("/board_ui", f.readAll())
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
