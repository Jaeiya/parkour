local utils = require("utils")
utils.clear()

local execTimer = require("boardtimer")
local execBoard = require("board")
local execBoardMedalBridge = require('boardmedalbridge')
local lib = require('boardlib')
local execRedstone = require("boardredstone")
local execPlayerDetection = require("detectplayer")
local execBoardStats = require('boardstats')
local execBoardUI = require("boardui")
local execPlayerTracker = require("boardplayertracker")

local config = lib.loadConfig()

---
---
---Starts all necessary scripts to run the leaderboard.
---
---When installed, this file is renamed to 'startup', which causes
---the computer to execute this script every time the computer is
---turned on.
---
---The conditions for turning on the computer can either be through
---player interaction or chunk loading. If the computer is left 'on'
---when the world is closed, it will start 'on' when the chunk
---is loaded again.
---
---



-- Check if scripts have failed initialization
if not execTimer or
   not execBoard or
   not execPlayerDetection or
   not execPlayerTracker or
   not execBoardMedalBridge
        then return
end

-- Executes the timer and any other scripts in parallel if needed
parallel.waitForAny(
    function() execTimer(config) end,
    function() execBoard(config) end,
    function() execBoardMedalBridge() end,
    function() execRedstone() end,
    function() execPlayerDetection({
        event = "leaderboard",
        action = "set_player_list",
    }) end,
    function() execBoardStats(config) end,
    function() execPlayerTracker(config) end,
    function() execBoardUI(config) end
)
