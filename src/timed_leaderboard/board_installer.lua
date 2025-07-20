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

---@class BoardPaths
---@field boardTimer string
---@field startup string
---@field board string
---@field boardData string
---@field boardUI string
---@field boardRedstone string
---@field boardState string
---@field utils string
---@field playerDetector string

---@type BoardPaths
local paths = {
    boardTimer     = "disk/board_timer",
    startup        = "disk/board_startup",
    board          = "disk/board",
    boardData      = "disk/board_lib",
    boardUI        = "disk/board_ui",
    boardRedstone  = "disk/board_redstone",
    boardState     = "disk/board_state",
    utils          = "disk/utils",
    playerDetector = "disk/detect_player",
}



local function promptProtocol()
    print()
    print("Enter Constellation Protocol")
    write("> ")
    return read()
end

-- All file operations below, will overwrite
-- any existing files.

lib.saveBoardConfig(
    promptProtocol(),
    utils.promptCoords("Enter Start Pos"),
    utils.promptCoords("Enter End Pos")
)

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

local f = fs.open("settings", "w")
if not f then error() end -- to appease linter
utils.writeFile("settings", "motd.enable=false")
f.close()

os.reboot()
