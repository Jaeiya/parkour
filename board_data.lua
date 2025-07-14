local utils = require('utils')
local leaderboard = {}
local filePath = "leaderboard.cfg"


local function loadLeaderboard()
    if not fs.exists(filePath) then
        utils.writeFile(filePath, textutils.serialize({}))
    end

    local f = fs.open(filePath, "r")
    local data = textutils.unserialize(f.readAll())
    f.close()
    return data
end

leaderboard.data = loadLeaderboard()


local function playerExists(name)
    if leaderboard.data[name] then
        return true
    end
    return false
end
leaderboard.playerExists = playerExists



leaderboard.getPlayer = function (name)
    if not playerExists(name) then
        error("player does not exist")
    end

    local data = leaderboard.data[name]
    return {
        attempts = {
            pb      = data.attempts.pb,
            current = data.attempts.current,
            total   = data.attempts.total,
        },
        time = {
            pb      = data.time.pb,
            current = data.time.current,
        }
    }
end


leaderboard.addAttempt = function (name)
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

    leaderboard.data[name] = {
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

    leaderboard.save()
end


leaderboard.getAll = function ()
    return leaderboard.data
end


leaderboard.savePlayer = function (name, data)
    leaderboard.data[name] = data
    leaderboard.save()
end


leaderboard.save = function ()
    utils.writeFile(filePath, textutils.serialize(leaderboard.data))
end


return leaderboard
