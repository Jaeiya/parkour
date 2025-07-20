local utils = require("utils")

local intervalDelay = 2 -- seconds

local players = pd.getOnlinePlayers()
local pd        = utils.getPlayerDetector()
local players   = pd.getOnlinePlayers()

return function(...)
    local listeners = {}
    for _, listener in ipairs({...}) do
        listeners[#listeners+1] = listener
        os.queueEvent(listener.event, {action = listener.action, payload = players})
    end

    local function updateListeners()
        for _, listener in ipairs(listeners) do
            os.queueEvent(listener.event, {
                action = listener.action,
                payload = players,
            })
        end
    end

    while true do
        sleep(intervalDelay)

        local newPlayers = pd.getOnlinePlayers()
        if #newPlayers ~= #players then
            players = newPlayers
            updateListeners()

        else
            for i, newPlayer in ipairs(newPlayers) do
                if newPlayer ~= players[i] then
                    players = newPlayers
                    updateListeners()
                    break
                end
            end
        end
    end
end
