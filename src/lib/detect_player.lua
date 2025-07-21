local utils = require("utils")


---
---
---Registers events for tracking players on a server.
---
---If a player leaves or joins the game, an event is sent out to all
---registered listeners, with the new player name list.
---
---


---Player detector listener
---@class PDListener
---@field event  string The event you're listening on
---@field action string The MessageEvent action to receive the player name list payload


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

---Sets up listeners to send an updated player name
---list to.
---@vararg PDListener
return function(...)
    for _, listener in ipairs({...}) do
        listeners[#listeners+1] = listener
        os.queueEvent(listener.event, {action = listener.action, payload = playerNames})
    end
    startListening()
end
