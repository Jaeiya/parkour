
local utils = require("utils")
local lib = require('boardlib')



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
---@param boundary BoardBoundary Original configured board boundary
---@return BoardBoundary
local function promptBoundaryAxis(startPos, boundary)
    utils.promptMenu("Select Boundary Axis", {
        { name = "x = " .. startPos.x + 1, exec = setBoundary('x', 'upper', boundary) },
        { name = "x = " .. startPos.x - 1, exec = setBoundary('x', 'lower', boundary)  },
        { name = "z = " .. startPos.z + 1, exec = setBoundary('z', 'upper', boundary) },
        { name = "z = " .. startPos.z - 1, exec = setBoundary('z', 'lower', boundary)  },
    })
    return boundary
end

---@param config BoardConfig
return function(config)
::menu::
    utils.clear()
    local sp = config.startPos
    local ep = config.endPos
    ---@type string
    local infoHeader = (
        "... Running Leaderboard ...\n" ..
        "\n;lgy;       start_pos: ;cyn;"..sp.x..", "..sp.y..", "..sp.z ..
        "\n;lgy;         end_pos: ;cyn;"..ep.x..", "..ep.y..", "..ep.z ..
        "\n;lgy;    mon_protocol: ;cyn;"..config.monProto ..
        "\n;lgy;  stats_protocol: ;cyn;"..config.statsProto ..
        "\n;lgy;    cancel_bound: ;cyn;"..config.boundary.direction..'('..config.boundary.axis..')\n\n' ..
        ';ylw;Manage Configuration'
    )
    print()
    local exiting = utils.promptMenu(infoHeader, {
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
        },
        {
            name = "Set Cancel Boundary",
            exec = function()
                promptBoundaryAxis(config.startPos, config.boundary)
            end
        }
    })

    if exiting then
        return
    end

    lib.saveBoardConfig(config)

    goto menu
end
