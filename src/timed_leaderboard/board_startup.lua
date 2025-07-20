
term.clear()
term.setCursorPos(1, 1)

local execTimer = require("board_timer")
local execBoard = require("board")
local execRedstone = require("board_redstone")
local execPlayerDetection = require("detect_player")
local execBoardUI = require("board_ui")


-- Check if scripts have failed initialization
if not execTimer or not execBoard or not execPlayerDetection then
    return
end

-- Executes the timer and any other scripts in parallel if needed
parallel.waitForAny(
    function() execTimer() end,
    function() execBoard() end,
    function() execRedstone() end,
    function() execPlayerDetection({
        event = "leaderboard",
        action = "set_player_list"
    }) end,
    function() execBoardUI() end
)
