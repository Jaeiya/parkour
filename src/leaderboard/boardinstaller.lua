local utils = require("utils")
local lib = require("boardlib")
local state = require("boardstate")


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


utils.clear()
print()
local mon = utils.getMonitor()
if not mon then
    printError("Installation Aborted")
    utils.print(";org;Attach an ;lim;advanced monitor ;org;to this computer\n\n")
    return
end

---We can't calculate the size without knowing the scale
mon.setTextScale(state.monitorScale)
local monW, monH = mon.getSize()
if monW < 36 or monH < 10 then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;The ;lim;monitor ;org;needs to be at least ;lim;7 ;org;blocks wide " ..
        "and ;lim;3 ;org;blocks tall\n\n"
    )
    return
end

if not utils.getPlayerDetector() then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Attach a ;lim;player detector ;org;to this computer\n\n"
    )
    return
end

local modem = utils.getModem('wireless')
if not modem then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Attach an ;lim;ender modem ;org;to this computer\n\n"
    )
    return
end

if not modem.isWireless() then
    utils.print(
        ";red;Installation Aborted\n" ..
        "The attached ;lim;modem ;org;needs to be ;lim;wireless;\n\n"
    )
    return
end


---@param axis 'x'|'z'|nil
---@param direction 'upper'|'lower'|nil
---@param boundary BoardBoundary
local function setBoundary(axis, direction, boundary)
    return function()
        boundary.axis = axis
        boundary.direction = direction
    end
end


---@param startPos Coord
---@return BoardBoundary
local function promptBoundaryAxis(startPos)
    ---@type BoardBoundary
    local boundary = { axis = nil, direction = nil }

    local isExiting = utils.promptMenu("Select Boundary Axis", {
        { name = "x = " .. startPos.x + 1, exec = setBoundary('x', 'upper', boundary) },
        { name = "x = " .. startPos.x - 1, exec = setBoundary('x', 'lower', boundary)  },
        { name = "z = " .. startPos.z + 1, exec = setBoundary('z', 'upper', boundary) },
        { name = "z = " .. startPos.z - 1, exec = setBoundary('z', 'lower', boundary)  },
    })

    if isExiting then
        printError("Installation Aborted by User")
        error("script terminated")
    end

    return boundary
end


-- Assume that the existing configuration is accurate
if not fs.exists(lib.configPath) then
    utils.print(";ylw;   ... Configuring Leaderboard ...")

    ---@type BoardConfig
    local config = {}

    config.monProto   = utils.prompt("Enter Monitor Protocol")
    config.statsProto = utils.prompt("Enter Stat Board Protocol")
    config.startPos   = utils.promptCoords("Enter Start Pos")
    config.endPos     = utils.promptCoords("Enter End Pos")
    config.boundary   = promptBoundaryAxis(config.startPos)
    lib.saveBoardConfig(config)
end


utils.installDisk()
