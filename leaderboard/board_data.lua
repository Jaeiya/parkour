local utils = require('utils')
local leaderboard = {}
local filePath    = "players.db"


local function loadPlayers()
    if not fs.exists(filePath) then
        utils.writeFile(filePath, textutils.serialize({}))
    end

    local f = fs.open(filePath, "r")
    local playerList = textutils.unserialize(f.readAll())
    local playerMap = {}
    for i = 1, #playerList do
        local p = playerList[i]
        playerMap[p.name] = {
            name = p.name,
            time = {
                pb      = p.time.pb,
                current = p.time.current,
            },
            attempts = {
                pb      = p.attempts.pb,
                current = p.attempts.current,
                total   = p.attempts.total,
            }
        }
    end
    f.close()
    return playerList, playerMap
end


-- Initialize internal database objects
leaderboard.playerList, leaderboard.playerMap = loadPlayers()


local function playerExists(name)
    if leaderboard.playerMap[name] then
        return true
    end
    return false
end
leaderboard.playerExists = playerExists


local function save()
    for i = 1, #leaderboard.playerList do
        local player = leaderboard.playerList[i]
        leaderboard.playerList[i] = leaderboard.playerMap[player.name]
    end

    table.sort(leaderboard.playerList, function(a, b) return a.time.pb < b.time.pb end)
    utils.writeFile(filePath, textutils.serialize(leaderboard.playerList))
end
leaderboard.save = save


local function savePlayer(player)
    if not playerExists(player.name) then
        error("player not found: '" .. name .. "'")
    end

    leaderboard.playerMap[player.name] = player
    save()
end
leaderboard.savePlayer = savePlayer


local function getPlayer(name)
    if not playerExists(name) then
        error("player not found: '" .. name "'")
    end

    local player = leaderboard.playerMap[name]
    return {
        name = player.name,
        attempts = {
            pb      = player.attempts.pb,
            current = player.attempts.current,
            total   = player.attempts.total,
        },
        time = {
            pb      = player.time.pb,
            current = player.time.current,
        }
    }
end
leaderboard.getPlayer = getPlayer


-- Updates the current & total attempts for the specified player.
local function updateAttempt(name)
    local player = getPlayer(name)
    player.attempts.current = player.attempts.current + 1
    player.attempts.total = player.attempts.total + 1
    savePlayer(player)
end
leaderboard.updateAttempt = updateAttempt


-- Tries to save a specified players run time, but if it
-- is not faster than the players current PB, then it does
-- nothing.
local function savePlayerTime(name, time)
    local player = getPlayer(name)

    player.time.current = time

    if player.time.current < player.time.pb or player.time.pb == 0 then
        player.time.pb = player.time.current
        player.attempts.pb = player.attempts.pb + player.attempts.current
        player.attempts.current = 0
    end

    savePlayer(player)
end
leaderboard.savePlayerTime = savePlayerTime


-- Tries to add a player to the database if they don't
-- already exist, otherwise it does nothing.
leaderboard.tryAddPlayer = function (name)
    if playerExists(name) then return end

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
        }
    }
    leaderboard.playerMap[name] = leaderboard.playerList[index]
    save()
end


leaderboard.get = function ()
    return leaderboard.playerList
end


return leaderboard
