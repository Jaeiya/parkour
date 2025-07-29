local utils = require('utils')

local pd = utils.getPlayerDetector()
if not pd then
    printError("statboard redstone terminated; missing player detector")
    return false
end

return function()
    while true do
        os.pullEvent('redstone')

        local players = pd.getPlayersInRange(2)
        if #players > 0 then
            os.queueEvent("update", { action = "view_player", payload = players[1]})
        end
    end
end
