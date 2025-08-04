local utils = require("utils")
local lib = require("boardlib")
local state = require("boardstate")

local pd  = utils.getPlayerDetector()
if not pd then
    printError("board terminated; missing player detector")
    return false
end

local mon = utils.getMonitor()
if not mon then
    printError("board terminated; missing monitor")
    return false
end

utils.clear(mon)
mon.setPaletteColor(colors.black, 0x000000)
mon.setTextScale(state.monitorScale)


---Names of all players currently online, updated through
---player detector event.
---@type string[]
local onlinePlayerNames = {}

local maxActuationDist  = 3 -- Max distance from configured start and end positions

---Check if a running player is the one who activated a trigger
---at the specified position
---@param pos Coord
local function isPlayerRunning(pos)
    local nearestPlayer = utils.getNearestPlayer(pos, pd, onlinePlayerNames)
    if nearestPlayer.distance <= maxActuationDist then
        if nearestPlayer.name == state.runningPlayer then
            return true
        end
    end
    return false
end


local function renderActiveRunner(playerName)
    local player = lib.findPlayer(playerName)
    if not player then
        error("active runner not found: " .. playerName)
    end

    utils.clear(mon)
    mon.setTextScale(2.5)

    mon.setBackgroundColor(colors.red)
    local w = mon.getSize()
    utils.print(utils.justifyText(";ylw;WARNING: Active Runner", 'center', w), mon)
    mon.setBackgroundColor(colors.black)

    mon.setCursorPos(1, 3)
    utils.print(";lim;"..utils.centerText(playerName, mon), mon)

    mon.setCursorPos(1, 5)
    utils.print(utils.centerText(";lgy;Attempt: ;org;"..player.attempts.current, mon), mon)
end


local function renderBoard()
    utils.clear(mon)
    mon.setTextScale(state.monitorScale)
    local yPos = 2
    mon.setCursorPos(1, yPos)
    utils.print(";org;"..utils.centerText("Leader Board", mon), mon)
    local players = lib.get()

    -- Add padding between times and title
    yPos = yPos + 1

    -- Display flavor text if level has no players
    local renderNoPlayers = function()
        mon.setCursorPos(1, yPos + 3)
        utils.print(";org;"..utils.centerText("Be the first to run this level!", mon), mon)
    end

    ---@type Player[]
    local playersWithPB = {}
    for _, player in ipairs(players) do
        if player.time.pb > 0 then
            playersWithPB[#playersWithPB+1] = player
        end
    end

    if #playersWithPB == 0 then
        renderNoPlayers()
        return
    end

    -- Calculate name column width
    local columnWidth = 0
    for _, player in ipairs(players) do
        if player then
            local nameWidth = #player.name
            if nameWidth > columnWidth and player.time.pb > 0 then
                columnWidth = nameWidth
            end
        end
    end

    for _, player in ipairs(playersWithPB) do
        yPos = yPos + 1
        mon.setCursorPos(1, yPos)
        local playerStr = (
            utils.justifyText(";wht;"..player.name, 'right', columnWidth)..
            ";gry;....."..
            ";lbu;"..utils.getTimerStr(player.time.pb)..
            ";gry;..;lgy;x;cyn;"..string.format("%03d", player.attempts.pb)
        )
        utils.print(utils.centerText(playerStr, mon), mon)
    end
end



---@param config BoardConfig
return function(config)
    renderBoard()

    while true do
        local _, data = os.pullEvent("leaderboard")

        if type(data) ~= "table" then
            error("tried to send non-table data to leaderboard")
        end

        -- All events passed between modules will be in this format
        ---@type MessageEvent
        local msgEvent = data

        if msgEvent.action == "start_run" then
            local nearestPlayer = utils.getNearestPlayer(config.startPos, pd, onlinePlayerNames)

            if nearestPlayer.distance <= maxActuationDist then
                lib.tryAddPlayer(nearestPlayer.name)
                lib.updateAttempt(nearestPlayer.name)
                state.runningPlayer = nearestPlayer.name
                os.queueEvent("playertracker", { action = "track_player" })
                renderActiveRunner(state.runningPlayer)
            else
                -- The timer starts no matter what, so we immediately cancel
                -- if no player is found.
                os.queueEvent("timer", { action = "cancel_run" })
            end

        elseif msgEvent.action == "try_cancel_run" then
            if isPlayerRunning(config.startPos) then
                os.queueEvent("timer", { action = "cancel_run" })
                lib.updateLives(state.runningPlayer)
                lib.updateTime(state.runningPlayer, msgEvent.payload)
                state.runningPlayer = nil
                renderBoard()
            end

        elseif msgEvent.action == "force_cancel_run" then
            -- It's possible that a 'try_cancel_run' takes longer to execute with
            -- more players online. So if it does, we make sure that the running
            -- player still exists when this event fires later.
            if state.runningPlayer then
                os.queueEvent("timer", { action = "cancel_run" })
                lib.updateLives(state.runningPlayer)
                lib.updateTime(state.runningPlayer, msgEvent.payload)
                state.runningPlayer = nil
                renderBoard()
            end

        elseif msgEvent.action == "save_player_time" then
            if isPlayerRunning(config.endPos) then
                os.queueEvent("timer", {action = "finish_run", payload = msgEvent.payload})
                lib.updateMedalStats(state.runningPlayer)
                lib.saveTime(state.runningPlayer, msgEvent.payload)
                state.runningPlayer = nil
                renderBoard()
            end

        elseif msgEvent.action == "set_player_list" then
            onlinePlayerNames = msgEvent.payload
        end
    end
end

