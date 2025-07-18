local pd = peripheral.find("player_detector")
if not pd then
    term.setTextColor(colors.red)
    print("failed to run player detection; missing player detector")
    return
end

local intervalDelay = 2 -- seconds

local players = pd.getOnlinePlayers()

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
