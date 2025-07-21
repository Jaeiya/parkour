local utils = require("utils")
local lib = require("board_lib")
local state = require("board_state")


---
---
---Installs the leaderboard to the connected computer.
---
---Legend:
---    Actuator - a pressure plate, button, or lever
---      Prompt - waits for user input
---
---It will prompt for the following pieces of information:
---    Protocol - The monitor host protocol to broadcast the timer to
---    StartPos - Coordinates of the actuator to trigger the start/cancel of a run
---      EndPos - Coordinates of the actuator to trigger the end of a run
---
---


print()
local mon = utils.getMonitor()
if not mon then
    printError("Installation Aborted")
    utils.printColor(";org;Attach an ;lim;advanced monitor ;org;to this computer\n\n")
    return
end

---We can't calculate the size without knowing the scale
mon.setTextScale(state.monitorScale)
local monW, monH = mon.getSize()
if monW < 36 or monH < 10 then
    utils.printColor(
        ";red;Installation Aborted\n" ..
        ";org;The ;lim;monitor ;org;needs to be at least ;lim;7 ;org;blocks wide " ..
        "and ;lim;3 ;org;blocks tall\n\n"
    )
    return
end

if not utils.getPlayerDetector() then
    utils.printColor(
        ";red;Installation Aborted\n" ..
        ";org;Attach a ;lim;player detector ;org;to this computer\n\n"
    )
    return
end

local modem = utils.getModem()
if not modem then
    utils.printColor(
        ";red;Installation Aborted\n" ..
        ";org;Attach an ;lim;ender modem ;org;to this computer\n\n"
    )
    return
end

if not modem.isWireless() then
    utils.printColor(
        ";red;Installation Aborted\n" ..
        "The attached ;lim;modem ;org;needs to be ;lim;wireless;\n\n"
    )
    return
end


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


utils.clear()
utils.printColor(";org;   ... Configuring Leaderboard ...")
lib.saveBoardConfig(
    utils.prompt("Enter Monitor Protocol"),
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
