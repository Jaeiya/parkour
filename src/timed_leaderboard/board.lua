local utils = require("utils")
local lib = require("board_lib")
local state = require("board_state")

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
mon.setTextScale(state.monitorScale)


---Names of all players currently online, updated through
---player detector event.
---@type string[]
local onlinePlayerNames = {}

---The player that is currently running the course (if any)
local runningPlayerName = ""

local config            = lib.loadConfig()
local maxActuationDist  = 3 -- Max distance from configured start and end positions

---Check if a running player is the one who activated a trigger
---at the specified position
---@param pos Coord
local function isPlayerRunning(pos)
    local nearestPlayer = utils.getNearestPlayer(pos, pd, onlinePlayerNames)
    if nearestPlayer.distance <= maxActuationDist then
        if nearestPlayer.name == runningPlayerName then
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

    mon.setTextScale(2.5)
    local w = mon.getSize()
    local text = "WARNING: Active Runner"
    local textWidthDiff = w - #text
    utils.clear(mon)
    mon.setBackgroundColor(colors.red)
    local banner = (
        string.rep(" ", math.ceil(textWidthDiff / 2)) ..
        text ..
        string.rep(" ", w - (textWidthDiff / 2))
    )
    utils.print(";ylw;"..banner, mon)

    -- Print the player name
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos(1, 3)
    utils.print(";lim;"..utils.centerText(playerName, mon), mon)
    mon.setCursorPos(1, 5)

    local attemptText = "Attempt: "
    local textWidth = #attemptText + #tostring(player.attempts.current)
    local attemptsStr = (
        string.rep(" ", (w - textWidth) / 2) ..
        attemptText ..
        ";ylw;"..player.attempts.current
    )
    utils.print(attemptsStr, mon)
end


local function renderBoard()
    mon.clear()
    mon.setTextScale(2)
    local yPos = 2
    mon.setCursorPos(1, yPos)
    utils.print(";lim;"..utils.centerText("Leader Board", mon), mon)
    local players = lib.get()

    -- Add padding between times and title
    yPos = yPos + 1

    -- Display flavor text if level has no players
    local renderNoPlayers = function()
        mon.setCursorPos(1, yPos + 3)
        utils.print(";org;"..utils.centerText("Be the first to run this level!", mon), mon)
    end

    if #players == 0 then
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

    local monWidth    = mon.getSize()
    local timeLen     = #"00:00:00.00"
    local separator   = "....."
    local attemptsLen = #"..x000"
    local lineLen     = columnWidth + timeLen + #separator + attemptsLen
    local linePadding = (monWidth - lineLen) / 2
    local hasPlayers  = false

    for _, player in ipairs(players) do
        if player.time.pb > 0 then
            hasPlayers = true
            yPos = yPos + 1
            mon.setCursorPos(1, yPos)
            local playerStr = (
                string.rep(" ", linePadding + (columnWidth - #player.name)) ..
                ";wht;"..player.name..
                ";gry;"..separator..
                ";lbu;"..utils.getTimerStr(player.time.pb)..
                ";gry;..;lgy;x;cyn;"..string.format("%03d", player.attempts.pb)
            )
            utils.print(playerStr, mon)
        end
    end

    if not hasPlayers then
       renderNoPlayers()
    end
end


return function()
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

            lib.tryAddPlayer(nearestPlayer.name)
            lib.updateAttempt(nearestPlayer.name)

            if nearestPlayer.distance <= maxActuationDist then
                runningPlayerName = nearestPlayer.name
                renderActiveRunner(runningPlayerName)
            end

        elseif msgEvent.action == "try_cancel_run" then
            if isPlayerRunning(config.startPos) then
                os.queueEvent("timer", { action = "cancel_run" })
                runningPlayerName = nil
                mon.setBackgroundColor(colors.black)
                renderBoard()
            end

        elseif msgEvent.action =="save_player_time" then
            if isPlayerRunning(config.endPos) then
                os.queueEvent("timer", {action = "finish_run", payload = msgEvent.payload})
                lib.savePlayerTime(runningPlayerName, msgEvent.payload)
                renderBoard()
            end

        elseif msgEvent.action == "set_player_list" then
            onlinePlayerNames = msgEvent.payload

        elseif msgEvent.action == "set_start_pos" then
            config.startPos = msgEvent.payload

        elseif msgEvent.action == "set_end_pos" then
            config.endPos = msgEvent.payload
        end
    end
end

