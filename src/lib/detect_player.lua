local utils = require("utils")

local pd = utils.getPlayerDetector()
if not pd then
    printError("player detection terminated; missing player detector")
    return false
end

local playerNames = pd.getOnlinePlayers()
local listeners   = {}


local function updateListeners()
    for _, listener in ipairs(listeners) do
        os.queueEvent(listener.event, {
            action = listener.action,
            payload = playerNames,
        })
    end
end


local function startListening()
    parallel.waitForAny(
        function ()
           while true do
                os.pullEvent("playerJoin")
                playerNames = pd.getOnlinePlayers()
                updateListeners()
           end
        end,
        function ()
           while true do
                os.pullEvent("playerLeave")
                playerNames = pd.getOnlinePlayers()
                updateListeners()
           end
        end
    )
end


return function(...)
    for _, listener in ipairs({...}) do
        listeners[#listeners+1] = listener
        os.queueEvent(listener.event, {action = listener.action, payload = playerNames})
    end
    startListening()
end
