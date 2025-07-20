local utils = require("utils")

local pd        = utils.getPlayerDetector()
local players   = pd.getOnlinePlayers()
local listeners = {}


local function updateListeners()
    for _, listener in ipairs(listeners) do
        os.queueEvent(listener.event, {
            action = listener.action,
            payload = players,
        })
    end
end



local function startListening()
    parallel.waitForAny(
        function ()
           while true do
                os.pullEvent("playerJoin")
                players = pd.getOnlinePlayers()
                updateListeners()
           end
        end,
        function ()
           while true do
                os.pullEvent("playerLeave")
                players = pd.getOnlinePlayers()
                updateListeners()
           end
        end
    )
end

return function(...)
    for _, listener in ipairs({...}) do
        listeners[#listeners+1] = listener
        os.queueEvent(listener.event, {action = listener.action, payload = players})
    end
    startListening()
end
