
local utils = require("utils")
local lib = require('boardlib')


return function(config)
::menu::
    utils.clear()
    local sp = config.startPos
    local ep = config.endPos
    utils.print(
        "... Running Leaderboard ...\n" ..
        "\n;lgy;       start_pos: ;cyn;"..sp.x..", "..sp.y..", "..sp.z ..
        "\n;lgy;         end_pos: ;cyn;"..ep.x..", "..ep.y..", "..ep.z ..
        "\n;lgy;    mon_protocol: ;cyn;"..config.monProto ..
        "\n;lgy;  stats_protocol: ;cyn;"..config.statsProto
    )
    print()
    local exiting = utils.promptMenu("Manage Configuration", {
        {
            name = "Set Start Pos",
            exec = function ()
                config.startPos = utils.promptCoords("Enter Start Pos")
            end
        },
        {
            name = "Set End Pos",
            exec = function ()
                config.endPos = utils.promptCoords("Enter End Pos")
            end
        },
        {
            name = "Set Monitor Protocol",
            exec = function ()
                config.monProto = utils.prompt("Enter Monitor Protocol")
            end
        },
        {
            name = "Set Stats Protocol",
            exec = function ()
                config.statsProto = utils.prompt("Enter Stats Protocol")
            end
        }
    }, false)

    if exiting then
        return
    end

    lib.saveBoardConfig(config)

    goto menu
end
