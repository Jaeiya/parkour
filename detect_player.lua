local utils = require("utils")
local pd = peripheral.find("player_detector")
if not pd then
    term.setTextColor(colors.red)
    print("failed to run player detection; missing player detector")
    return
end

local detectPlayerEvent = "player_detection_timer"
local detectionSpeed = 0.5 -- seconds

local players = pd.getOnlinePlayers()
utils.startTimer(detectionSpeed, detectPlayerEvent)

while true do
    local event = os.pullEvent()

    if event == detectPlayerEvent then
        players = pd.getOnlinePlayers()
        os.queueEvent("player_list", players)
        utils.startTimer(detectionSpeed, detectPlayerEvent)

    elseif event == "get_players" then
        os.queueEvent("player_list", players)
    end
end
