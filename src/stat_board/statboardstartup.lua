local utils = require('utils')
local execStats = require('statboard')
local execUI = require('statboardui')
local execRedstone = require('statboardredstone')

local configFilePath = "statboard.cfg"

---@class StatBoardConfig
local config = { protocol = "stats_w1lv1", hostname = "stats_1" }
config = utils.loadConfig(configFilePath, config)

if not execStats or not execRedstone then
    return
end

parallel.waitForAny(
    function() execStats(config) end,
    function() execUI(config) end,
    execRedstone
)
