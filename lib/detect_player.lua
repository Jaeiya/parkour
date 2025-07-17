local utils = require("utils")
local pd = peripheral.find("player_detector")
if not pd then
    term.setTextColor(colors.red)
    print("failed to run player detection; missing player detector")
    return
end

local listenEvent = "player_detector"
local detectionSpeed = 2 -- seconds

local players = pd.getOnlinePlayers()
utils.setTimeout(detectionSpeed, listenEvent)

-- Send players immediately to leaderboard
os.queueEvent("leaderboard", {action = "set_player_list", payload = players})

return function()
    while true do
        local _, data = os.pullEvent(listenEvent)

        if type(data) ~= "table" then
            error("tried to send non-table data to player detector")
        end

        if data.action == "timer" then
            local newPlayers = pd.getOnlinePlayers()
            if #newPlayers ~= players then
                os.queueEvent("leaderboard", {
                    action = "set_player_list",
                    payload = players,
                })
            end
            utils.setTimeout(detectionSpeed, listenEvent)
        end
    end
end
