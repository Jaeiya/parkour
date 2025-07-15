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



leaderboard.getPlayer = function (name)
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


leaderboard.updateAttempt = function (name)
    local playerData = leaderboard.getPlayer(name)
    playerData.attempts.current = playerData.attempts.current + 1
    playerData.attempts.total = playerData.attempts.total + 1
    leaderboard.savePlayer(name, playerData)
end


leaderboard.trySetPB = function (name, currentTime)
    local playerData = leaderboard.getPlayer(name)
    if playerData.time.pb == 0 or currentTime < playerData.time.pb then
        playerData.time.pb = currentTime
        playerData.attempts.pb = playerData.attempts.pb + playerData.attempts.current
        playerData.attempts.current = 0
        leaderboard.savePlayer(name, playerData)
    end
end


leaderboard.updateCurrentTime = function (name, time)
    local playerData = leaderboard.getPlayer(name)
    playerData.time.current = time
    leaderboard.savePlayer(name, playerData)
end


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
    leaderboard.save()
end


leaderboard.get = function ()
    return leaderboard.playerList
end


leaderboard.savePlayer = function (name, data)
    if not leaderboard.playerExists(name) then
        error("player not found: '" .. name .. "'")
    end

    leaderboard.playerMap[name] = data
    leaderboard.save()
end


leaderboard.save = function ()
    for i = 1, #leaderboard.playerList do
        local player = leaderboard.playerList[i]
        leaderboard.playerList[i] = leaderboard.playerMap[player.name]
    end

    table.sort(leaderboard.playerList, function(a, b) return a.time.pb < b.time.pb end)
    utils.writeFile(filePath, textutils.serialize(leaderboard.playerList))
end


return leaderboard
