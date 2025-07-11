
local pd = peripheral.find("player_detector")
local mon = peripheral.find("monitor")

local lastPlayer = nil

-- sum adds all variadic arguments together
local function sum(...)
    local total = 0
    for _, num in ipairs({...}) do
        total = total + num
    end
    return total
end

-- diffCoords compares two coordinates and determines
-- their absolute distance from each other.
local function diffCoords(coord1, coord2)
    if coord1 == coord2 then
        return 0
    elseif coord1 <= 0 and coord2 > 0 then
        return math.abs(coord1) + coord2
    elseif coord1 >= 0 and coord2 < 0 then
        return coord1 + math.abs(coord2)
    else
        -- Both coords are either positive or negative
        return math.abs(math.abs(coord1) - math.abs(coord2))
    end
end


local function getNearestPlayer(x, y, z)
    local players = pd.getOnlinePlayers()
    local nearestPlayer = ""
    local nearestPos   = math.huge

    for i = 1, #players do
        local playerPosObj = pd.getPlayerPos(players[i])
        local playerPosDiff = sum(
            diffCoords(x, playerPosObj.x),
            diffCoords(y, playerPosObj.y),
            diffCoords(z, playerPosObj.z)
        )
        if playerPosDiff < nearestPos then
            nearestPos = playerPosDiff
            nearestPlayer = players[i]
        end
    end

    return {
        name = nearestPlayer,
        distance = nearestPos
    }
end

while true do
    -- local event, data = os.pullEvent("leaderboard_update")

    -- if type(data) ~= "table" then
    --    error("tried to send non-table data to leaderboard")
    -- end

    -- if data.type == "get_player" then
    os.pullEvent("redstone")
    if redstone.getInput("front") then
        local nearestPlayer = getNearestPlayer(-2, -60, -2)
        mon.setCursorPos(1, 1)
        mon.setTextScale(1.5)
        mon.write(nearestPlayer.name)
        mon.setCursorPos(1, 2)
        mon.write(nearestPlayer.distance)
    end
end
