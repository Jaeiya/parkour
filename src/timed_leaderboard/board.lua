local utils = require("utils")
local lib = require("board_lib")

local pd  = utils.getPlayerDetector()
if not pd then
    return printError("board terminated; missing player detector")
end

local mon = utils.getMonitor()
if not mon then
    printError("board terminated; missing monitor")
    return false
end

mon.clear()
mon.setTextScale(2)
mon.setBackgroundColor(colors.black)

---@type string[]
local onlinePlayerNames = {}
local currentPlayer     = ""
local config            = lib.loadConfig()
local maxActuationDist  = 3 -- Max distance from configured start and end positions

---Check if a running player is the one who activated a trigger
---at the specified position
---@param pos Coord
local function isPlayerRunning(pos)
    local nearestPlayer = utils.getNearestPlayer(pos, pd, onlinePlayerNames)
    if nearestPlayer.distance <= maxActuationDist then
        if nearestPlayer.name == currentPlayer then
            return true
        end
    end
    return false
end


local function renderActiveRunner(playerName)
    local text = "WARNING: Active Runner"
    mon.setTextScale(2.5)
    local w = mon.getSize()
    local textWidthDiff = w - #text
    local player = lib.getPlayer(playerName)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.setBackgroundColor(colors.red)
    mon.setTextColor(colors.yellow)
    mon.write(string.rep(" ", math.ceil(textWidthDiff / 2))..text..string.rep(" ", w - (textWidthDiff / 2)))
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos(1, 3)
    mon.setTextColor(colors.lime)
    mon.write(utils.centerText(playerName, mon))
    mon.setCursorPos(1, 5)
    local attemptText = "Attempt: "
    local textWidth = #attemptText + #tostring(player.attempts.current)
    local textPadding = (w - textWidth) / 2
    mon.setTextColor(colors.white)
    mon.write(string.rep(" ", textPadding) .. attemptText)
    mon.setTextColor(colors.yellow)
    mon.write(tostring(player.attempts.current))
end


local function renderBoard()
    mon.clear()
    mon.setTextScale(2)
    local yPos = 2
    mon.setCursorPos(1, yPos)
    mon.setTextColor(colors.lime)
    mon.write(utils.centerText("Leader Board", mon))

    -- Add padding between times and title
    yPos = yPos + 1

    -- Calculate name column width
    local columnWidth = 0
    for _, name in ipairs(onlinePlayerNames) do
        local player = lib.getPlayer(name)
        local nameWidth = #player.name
        if nameWidth > columnWidth and player.time.pb > 0 then
            columnWidth = nameWidth
        end
    end

    local monWidth    = mon.getSize()
    local timeLen     = #"00:00:00.00"
    local separator   = "....."
    local attemptsLen = #"..x000"
    local lineLen     = columnWidth + timeLen + #separator + attemptsLen
    local linePadding = (monWidth - lineLen) / 2
    local noPlayersStr = "Be the first to run this level!"
    local hasPlayers = false


    for _, name in ipairs(onlinePlayerNames) do
        local player = lib.getPlayer(name)
        if player.time.pb > 0 then
            hasPlayers = true
            local attemptStr = string.format("%03d", player.attempts.pb)
            local padding = string.rep(" ", linePadding + (columnWidth - #player.name))
            yPos = yPos + 1
            mon.setCursorPos(1, yPos)
            mon.write(padding)
            mon.setTextColor(colors.white)
            mon.write(player.name)
            mon.setTextColor(colors.gray)
            mon.write(separator)
            mon.setTextColor(colors.lightBlue)
            mon.write(utils.getTimerStr(player.time.pb))
            mon.setTextColor(colors.gray)
            mon.write("..")
            mon.setTextColor(colors.lightGray)
            mon.write("x")
            mon.setTextColor(colors.cyan)
            mon.write(attemptStr)
        end
    end

    if not hasPlayers then
        mon.setCursorPos(1, yPos + 3)
        mon.setTextColor(colors.orange)
        mon.write(utils.centerText(noPlayersStr, mon))
    end
end


renderBoard()

return function()
    while true do
        local _, data = os.pullEvent("leaderboard")

        if type(data) ~= "table" then
            error("tried to send non-table data to leaderboard")
        end

        -- All events passed between modules will be in this format
        ---@cast data MessageEvent

        if data.action == "start_run" then
            local nearestPlayer = utils.getNearestPlayer(config.startPos, pd, onlinePlayerNames)

            lib.tryAddPlayer(nearestPlayer.name)
            lib.updateAttempt(nearestPlayer.name)

            if nearestPlayer.distance <= maxActuationDist then
                currentPlayer = nearestPlayer.name
                renderActiveRunner(currentPlayer)
            end

        elseif data.action == "try_cancel_run" then
            if isPlayerRunning(config.startPos) then
                os.queueEvent("timer", { action = "cancel_run" })
                currentPlayer = nil
                mon.setBackgroundColor(colors.black)
                renderBoard()
            end

        elseif data.action == "save_player_time" then
            if isPlayerRunning(config.endPos) then
                os.queueEvent("timer", {action = "finish_run", payload = data.payload})
                lib.savePlayerTime(currentPlayer, data.payload)
                renderBoard()
            end

        elseif data.action == "set_player_list" then
            onlinePlayerNames = data.payload

        elseif data.action == "set_start_pos" then
            config.startPos = data.payload

        elseif data.action == "set_end_pos" then
            config.endPos = data.payload
        end
    end
end

