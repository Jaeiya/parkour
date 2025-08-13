local utils = require("utils")
utils.clear()

local execTimer = require("boardtimer")
local execBoard = require("board")
local lib = require('boardlib')
local execBoardMedalBridge = require('boardmedalbridge')
local execRedstone = require("boardredstone")
local execPlayerDetection = require("detectplayer")
local execBoardStats = require('boardstats')
local execBoardUI = require("boardui")
local execPlayerTracker = require("boardplayertracker")

local config = lib.loadConfig()


-- Check if scripts have failed initialization
if not execTimer or
   not execBoard or
   not execPlayerDetection or
   not execPlayerTracker or
   not execBoardMedalBridge
        then return
end


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
