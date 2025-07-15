local utils = require("utils")
local leaderboard = require("board_data")

local pd  = utils.getPeripheral("player_detector")
local mon = utils.getPeripheral("monitor")
mon.clear()
mon.setTextScale(2)
mon.setBackgroundColor(colors.black)


local currentPlayer    = nil
local config           = utils.loadTimerConfig()
local maxActuationDist = 3 -- Max distance from configured start and end positions


local function isPlayerRunning(pos)
    local nearestPlayer = utils.getNearestPlayer(pos.x, pos.y, pos.z, pd)
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
    local player = leaderboard.getPlayer(playerName)
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
    mon.write(player.attempts.current)
end


local function displayTimes(colWidth, yPos)
    local monWidth    = mon.getSize()
    local timeLen     = #"00:00:00.00"
    local separator   = "....."
    local attemptsLen = #"..x000"
    local lineLen     = colWidth + timeLen + #separator + attemptsLen
    local linePadding = (monWidth - lineLen) / 2
    local players     = leaderboard.get()

    for i = 1, #players do
        local player = leaderboard.getPlayer(players[i].name)
        if player.time.pb > 0 then
            local attemptStr = string.format("%03d", player.attempts.pb)
            local padding = string.rep(" ", linePadding + (colWidth - #player.name))
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
end


local function renderBoard()
    mon.clear()
    mon.setTextScale(2)
    local yPos = 1
    mon.setCursorPos(1, yPos)
    mon.setTextColor(colors.lime)
    mon.write(utils.centerText("Leader Board", mon))
    local columnWidth = 0
    local players = leaderboard.get()
    for i = 1, #players do
        local player = leaderboard.getPlayer(players[i].name)
        local nameWidth = #player.name
        if nameWidth > columnWidth and player.time.pb > 0 then
            columnWidth = nameWidth
        end
    end

    -- Add padding between times and title
    yPos = yPos + 1
    displayTimes(columnWidth, yPos)
end



print("   StartPos: "..config.startPos.x..", "..config.startPos.y..", "..config.startPos.z)
print("  FinishPos: "..config.endPos.x..", "..config.endPos.y..", "..config.endPos.z)
renderBoard()

while true do
    local _, data = os.pullEvent("leaderboard")

    if type(data) ~= "table" then
       error("tried to send non-table data to leaderboard")
    end

    if data.action == "starting_run" then
        local nearestPlayer = utils.getNearestPlayer(
            config.startPos.x,
            config.startPos.y,
            config.startPos.z,
            pd
        )
        leaderboard.tryAddPlayer(nearestPlayer.name)
        leaderboard.updateAttempt(nearestPlayer.name)

        if nearestPlayer.distance <= maxActuationDist then
            currentPlayer = nearestPlayer.name
            renderActiveRunner(currentPlayer)
        end

    elseif data.action == "try_cancel_run" then
        if isPlayerRunning(config.startPos) then
            os.queueEvent("cancel_run")
            currentPlayer = nil
            mon.setBackgroundColor(colors.black)
            renderBoard()
        end

    elseif data.action == "save_player_time" then
        if isPlayerRunning(config.endPos) then
            os.queueEvent("finish_run", data.time)
            leaderboard.savePlayerTime(currentPlayer, data.time)
            renderBoard()
        end
    end
end
