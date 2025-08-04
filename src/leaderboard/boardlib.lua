local utils = require('utils')
local state = require('boardstate')
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

---@class Player
---@field name     string
---@field time     PlayerStats
---@field attempts PlayerStats
---@field medal    PlayerMedal

---@alias MedalString 'mud'|'bronze'|'silver'|'gold'|'heart'

---@class PlayerMedal
---@field type integer The type of the highest medal the player has achieved (gold, sliver, etc...)
---@field lastType integer
---@field types integer[] Track all medals accumulated over all runs
---@field rank integer The number of lives used to achieve a specific medal
---@field lastRank integer
---@field lifeCount integer Counts how many lives a player has used in the current run
---@field breakdown MedalBreakdown
---@field livesUsed PlayerStats The players life usage breakdown
---@field attempts PlayerStats The players attempt usage breakdown

---@class PlayerStats
---@field pb     integer
---@field latest integer
---@field total  integer

---@class MedalBreakdown
---@field pb     string
---@field latest string
---@field total  string

---@type Player
local defaultPlayerData = {
    name = "",
    attempts = {
        pb = 0,
        latest = 0,
        total = 0,
    },
    time = {
        pb = 0,
        latest = 0,
        total = 0,
    },
    medal = {
        type = 0,
        lastType = 0,
        types = {},
        rank = math.huge, -- Lower ranks are considered better (rank 1 > rank 2)
        lastRank = math.huge,
        lifeCount = 0,
        breakdown = {
            pb = '',
            latest = '',
            total = '',
        },
        attempts = {
            pb = 0,
            latest = 0,
            total = 0,
        },
        livesUsed = {
            pb = 0,
            latest = 0,
            total = 0,
        }
    }
}



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
local lib  = {
    playerList = {},
    playerMap = {},
    configPath = configPath
}


-- Initialize internal database objects
lib.playerList, lib.playerMap = loadPlayers()


---@class Medal
local Medal = {
    None   = 0,
    MUD    = 1,
    BRONZE = 2,
    SILVER = 3,
    GOLD   = 4,
    HEART  = 5,
}

lib.sortedMedals = {'heart', 'gold', 'silver', 'bronze', 'mud'}



---@param medal integer
---@return MedalString
local function toMedalStr(medal)
    if medal == 1 then return 'mud' end
    if medal == 2 then return 'bronze' end
    if medal == 3 then return 'silver' end
    if medal == 4 then return 'gold' end
    if medal == 5 then return 'heart' end
    error('invalid medal')
end


---@param medalName MedalString
local function toMedal(medalName)
    if medalName == 'mud'    then return Medal.MUD    end
    if medalName == 'bronze' then return Medal.BRONZE end
    if medalName == 'silver' then return Medal.SILVER end
    if medalName == 'gold'   then return Medal.GOLD   end
    if medalName == 'heart'  then return Medal.HEART  end
    error('invalid medal name')
end


---@param medal integer
---@param rank integer
local function toMedalNotation(medal, rank)
    if medal == Medal.MUD    then return 'M' .. tostring(rank) end
    if medal == Medal.BRONZE then return 'B' .. tostring(rank) end
    if medal == Medal.SILVER then return 'S' .. tostring(rank) end
    if medal == Medal.GOLD   then return 'G' .. tostring(rank) end
    if medal == Medal.HEART  then return 'H0' end

    -- User failed to get a medal
    if medal == Medal.None  then return 'F0' end

    error('medal notation not found: ' .. tostring(medal))
end


---@param types integer[]
local function toAvgMedalNotation(types)
    return string.sub(toMedalNotation(
        utils.round(utils.sum(table.unpack(types)) / #types),
        0
    ), 1, 1) .. "*"
end


---Returns a numeric rank based on the specified medal and lives.
---@param medal integer
---@param lives integer
local function toMedalRank(medal, lives)
    if medal == Medal.HEART then return 0 end

    local medalName = toMedalStr(medal + 1)
    return lives - state.medalLives[medalName]
end


---Returns the medal associated with the specified lives used
---@param lives integer
---@return integer
local function getPlayerMedal(lives)
    for _, medalName in ipairs(lib.sortedMedals) do
        if lives <= state.medalLives[medalName] then
            return toMedal(medalName)
        end
    end
    return Medal.None
end


---Checks if a player exists
---@param name string The name of the player
function lib.playerExists(name)
    if lib.playerMap[name] then
        return true
    end
    return false
end


---Saves the players to the player database file and
---sorts them by fastest time with fewest attempts.
function lib.save()
    table.sort(lib.playerList, function(a, b)
        if a.time.pb == b.time.pb then
            return a.attempts.pb < b.attempts.pb
        else
            return a.time.pb < b.time.pb end
        end
    )
    utils.writeFile(playerDBPath, textutils.serialize(lib.playerList))
end


---Get player data by specified name
---@param name string Name of the player to get
---@return Player|nil
function lib.findPlayer(name)
    return lib.playerMap[name]
end


---Updates the latest & total attempts for the specified player.
---@param name string Name of the player to update
function lib.updateAttempt(name)
    local player = lib.playerMap[name]
    player.attempts.latest = player.attempts.latest + 1
    player.attempts.total = player.attempts.total + 1
    lib.save()
end


function lib.updateMedalStats(name)
    local player = lib.playerMap[name]

    if player.medal.type == Medal.HEART then
        return
    end

    player.medal.attempts.latest = player.medal.attempts.latest + 1
    player.medal.attempts.total = player.medal.attempts.total + 1

    local medal = getPlayerMedal(player.medal.lifeCount)
    local medalRank = toMedalRank(medal, player.medal.lifeCount)

    local hasBetterRank = medal == player.medal.type and medalRank < player.medal.rank

    if medal > player.medal.type or hasBetterRank then
        player.medal.type = medal
        player.medal.types[#player.medal.types+1] = medal
        player.medal.rank = medalRank
        player.medal.lastType = medal
        player.medal.lastRank = medalRank
        player.medal.breakdown.pb = toMedalNotation(medal, medalRank)
        player.medal.breakdown.latest = toMedalNotation(medal, medalRank)
        player.medal.breakdown.total = toAvgMedalNotation(player.medal.types)
        player.medal.livesUsed.pb = player.medal.livesUsed.pb + player.medal.livesUsed.latest
        player.medal.attempts.pb = player.medal.attempts.pb + player.medal.attempts.latest
        player.medal.livesUsed.latest = 0
        player.medal.attempts.latest = 0
    else
        player.medal.lastType = medal
        ---Do not save none-types as it messes up medal calculation
        if medal ~= Medal.None then
            player.medal.types[#player.medal.types+1] = medal
        end
        player.medal.lastRank = medalRank
        player.medal.breakdown.latest = toMedalNotation(medal, medalRank)
        player.medal.breakdown.total = toAvgMedalNotation(player.medal.types)
    end

    player.medal.lifeCount = 0

    lib.save()
end


function lib.updateLives(name)
    local player = lib.playerMap[name]

    -- The player has already achieved max medal
    if player.medal.type == Medal.HEART then return end

    player.medal.lifeCount = player.medal.lifeCount + 1
    player.medal.livesUsed.latest = player.medal.livesUsed.latest + 1
    player.medal.livesUsed.total = player.medal.livesUsed.total + 1
    lib.save()
end


---Adds time to a players total run time.
function lib.updateTime(name, time)
    local player = lib.playerMap[name]
    player.time.total = player.time.total + time
    lib.save()
end


---Saves all relevant time information for the specified
---player, however if the latest time is not faster
---than their PB, then the PB is not updated.
---@param name string Name of the player to save
---@param time integer The time (in milliseconds) of the players run
function lib.saveTime(name, time)
    local player = lib.playerMap[name]
    player.time.latest = time
    player.time.total = player.time.total + player.time.latest

    if player.time.latest < player.time.pb or player.time.pb == 0 then
        player.time.pb = player.time.latest
        player.attempts.pb = player.attempts.pb + player.attempts.latest
        player.attempts.latest = 0
    end

    lib.save()
end


---Tries to add a player to the database if they don't
---already exist, otherwise it does nothing.
---@param name string Name of the player to add
function lib.tryAddPlayer(name)
    if lib.playerExists(name) then return end
    local index = #lib.playerList+1
    defaultPlayerData.name = name
    lib.playerList[index] = defaultPlayerData
    lib.playerMap[name] = lib.playerList[index]
    lib.save()
end


---Gets a list of all saved players
function lib.get()
    return lib.playerList
end


---Loads the board config file
function lib.loadConfig()
    if not fs.exists(configPath) then
        error("missing timer config file")
    end
    return utils.loadConfig(configPath, config)
end


---Saves the board to the configuration file
---@param cfg BoardConfig
function lib.saveBoardConfig(cfg)
    utils.saveConfig(configPath, cfg)
end


return lib
