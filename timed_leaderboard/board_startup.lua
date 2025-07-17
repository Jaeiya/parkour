local execBoard = require("board")
local execTimer = require("board_timer")
local execRedstone = require("board_redstone")
local execPlayerDetection = require("detect_player")

-- Executes the timer and any other scripts in parallel if needed
parallel.waitForAny(
    function() execTimer() end,
    function() execBoard() end,
    function() execRedstone() end,
    function() execPlayerDetection() end
)
