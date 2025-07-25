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

local modem = utils.getModem()
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


-- Assume that the existing configuration is accurate
if not fs.exists(lib.configPath) then
    utils.print(";ylw;   ... Configuring Leaderboard ...")
    lib.saveBoardConfig(
        utils.prompt("Enter Monitor Protocol"),
        utils.promptCoords("Enter Start Pos"),
        utils.promptCoords("Enter End Pos")
    )
end


utils.installDisk()
