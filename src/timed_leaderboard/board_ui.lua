
local utils = require("utils")

local configFile = "board.cfg"
local config = {
    protocol = "",
    startPos = {
        x = 0,
        y = 0,
        z = 0,
    },
    endPos = {
        x = 0,
        y = 0,
        z = 0,
    },
}
config = utils.loadConfig(configFile, config)

local function promptMonitorProtocol()
    print()
    print("Enter Monitor Protocol")
    print()
    write("> ")
    return utils.read()
end



local choices = {
    function()
    end,
    function ()
    end,
    function ()
    end,
}


return function()
::menu::
    term.clear()
    term.setCursorPos(1, 1)
    local sp = config.startPos
    local ep = config.endPos
    utils.printColor(";cyn;Current Values\n")
    utils.printColor(";lgy;  start_pos: ;wht;"..sp.x..", "..sp.y..", "..sp.z)
    utils.printColor(";lgy;    end_pos: ;wht;"..ep.x..", "..ep.y..", "..ep.z)
    utils.printColor(";lgy;   Protocol: ;wht;"..config.protocol)
    print()
    local exiting = utils.promptMenu("Manage Configuration", {
        {
            name = "Set Start Pos",
            exec = function ()
                config.startPos = utils.promptCoords("Enter Start Pos")
                utils.saveConfig(configFile, config)
                os.queueEvent("leaderboard", {action = "set_start_pos", payload = config.startPos})
            end
        },
        {
            name = "Set End Pos",
            exec = function ()
                config.endPos = utils.promptCoords("Enter End Pos")
                utils.saveConfig(configFile, config)
                os.queueEvent("leaderboard", {action = "set_end_pos", payload = config.endPos})
            end
        },
        {
            name = "Set Monitor Protocol",
            exec = function ()
                config.protocol = promptMonitorProtocol()
                utils.saveConfig(configFile, config)
                os.queueEvent("timer", {action = "new_protocol", payload = config.protocol })
            end
        }
    }, false)

    if exiting then
        return
    end
    goto menu
end
