local utils = require('utils')
local playerDBPath = "players.db"
local configPath   = "board.cfg"
---@class BoardConfig
local config = {
    ---Monitor Host Protocol
    monProto = "",
    ---Stat Board Protocol
    statsProto = "",
    ---Where the player will start their run
    ---@type Coord
    startPos = { x = 0, y = 0, z = 0, },
    ---Where the player will end their run
    ---@type Coord
    endPos = { x = 0, y = 0, z = 0, },
    ---Defines the boundary between the run-zone and cancel-zone
    ---@class BoardBoundary
    ---@field axis 'x'|'z'|nil The axis of the boundary
    ---@field direction 'upper'|'lower'|nil Determines if the boundary is in front or back of the start pos
    boundary = {
        axis = nil,
        direction = nil
    },
}


---@class Coord
---@field x integer
---@field y integer
---@field z integer

---@class Player
---@field name     string
---@field time     PlayerStats
---@field attempts PlayerStats

---@class PlayerStats
---@field pb      integer
---@field current integer
---@field total   integer



---Loads players from the player database file
---and returns them as a list and map.
local function loadPlayers()
    ---@type Player[]
    local playerList = utils.loadConfig(playerDBPath, {})

    ---@type table<string, Player>
    local playerMap = {}

    for i = 1, #playerList do
        local p = playerList[i]
        playerMap[p.name] = p
    end
    return playerList, playerMap
end



---@class Leaderboard
---@field playerList Player[]
---@field playerMap table<string, Player>
local leaderboard  = {
    playerList = {},
    playerMap = {},
    configPath = configPath
}

-- Initialize internal database objects
leaderboard.playerList, leaderboard.playerMap = loadPlayers()


---Checks if a player exists
---@param name string The name of the player
function leaderboard.playerExists(name)
    if leaderboard.playerMap[name] then
        return true
    end
    return false
end


---Saves the players to the player database file and
---sorts them by fastest time with fewest attempts.
function leaderboard.save()
    table.sort(leaderboard.playerList, function(a, b)
        if a.time.pb == b.time.pb then
            return a.attempts.pb < b.attempts.pb
        else
            return a.time.pb < b.time.pb end
        end
    )
    utils.writeFile(playerDBPath, textutils.serialize(leaderboard.playerList))
end


---Get player data by specified name
---@param name string Name of the player to get
---@return Player|nil
function leaderboard.findPlayer(name)
    return leaderboard.playerMap[name]
end


---Updates the current & total attempts for the specified player.
---@param name string Name of the player to update
function leaderboard.updateAttempt(name)
    local player = leaderboard.playerMap[name]
    player.attempts.current = player.attempts.current + 1
    player.attempts.total = player.attempts.total + 1
    leaderboard.save()
end


---Adds time to a players total run time.
function leaderboard.updateTime(name, time)
    local player = leaderboard.playerMap[name]
    player.time.total = player.time.total + time
    leaderboard.save()
end


---Saves all relevant time information for the specified
---player, however if the current time is not faster
---than their PB, then the PB is not updated.
---@param name string Name of the player to save
---@param time integer The time (in milliseconds) of the players run
function leaderboard.savePlayerTime(name, time)
    local player = leaderboard.playerMap[name]
    player.time.current = time
    player.time.total = player.time.total + player.time.current

    if player.time.current < player.time.pb or player.time.pb == 0 then
        player.time.pb = player.time.current
        player.attempts.pb = player.attempts.pb + player.attempts.current
        player.attempts.current = 0
    end

    leaderboard.save()
end


---Tries to add a player to the database if they don't
---already exist, otherwise it does nothing.
---@param name string Name of the player to add
function leaderboard.tryAddPlayer(name)
    if leaderboard.playerExists(name) then return end
    local index = #leaderboard.playerList+1
    leaderboard.playerList[index] = {
        name = name,
        attempts = {
            pb = 0,
            current = 0,
            total = 0,
        },
        time = {
            pb = 0,
            current = 0,
            total = 0,
        }
    }
    leaderboard.playerMap[name] = leaderboard.playerList[index]
    leaderboard.save()
end


---Gets a list of all saved players
function leaderboard.get()
    return leaderboard.playerList
end


---Loads the board config file
function leaderboard.loadConfig()
    if not fs.exists(configPath) then
        error("missing timer config file")
    end
    return utils.loadConfig(configPath, config)
end


---Saves the board to the configuration file
---@param cfg BoardConfig
function leaderboard.saveBoardConfig(cfg)
    utils.saveConfig(configPath, cfg)
end


return leaderboard
