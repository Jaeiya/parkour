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
            pb = data.time.pb,
            last = data.time.last,
        }
    }
end


leaderboard.addAttempt = function (name)
    local player = leaderboard.getPlayer(name)
    player.attempts.current = player.attempts.current + 1
    player.attempts.total = player.attempts.total + 1
end


leaderboard.trySetPB = function (name, currentTime)
    local player = leaderboard.getPlayer(name)
    if currentTime < player.time.pb then
        player.time.pb = time
        player.attempts.pb = player.attempts.current
        player.attempts.current = 0
        leaderboard.save()
    end
end


leaderboard.tryAddPlayer = function (name)
    if playerExists(name) then return end

    leaderboard.data[name] = {
        attempts = {
            pb = 0,
            current = 1,
        },
        time = {
            pb = 0,
            last = 0,
        }
    }

    leaderboard.save()
end


leaderboard.getAll = function ()
    return leaderboard.data
end


leaderboard.save = function ()
   utils.writeFile(filePath, textutils.serialize(leaderboard.data))
end


return leaderboard
