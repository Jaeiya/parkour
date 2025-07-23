
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

return function()
::menu::
    utils.clear()
    local sp = config.startPos
    local ep = config.endPos
    utils.print(
        "... Running Leaderboard ...\n" ..
        "\n;lgy;  start_pos: ;cyn;"..sp.x..", "..sp.y..", "..sp.z ..
        "\n;lgy;    end_pos: ;cyn;"..ep.x..", "..ep.y..", "..ep.z ..
        "\n;lgy;   Protocol: ;cyn;"..config.protocol
    )
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
                config.protocol = utils.prompt("Enter Monitor Protocol")
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
