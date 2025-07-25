
local utils = require('utils')

utils.clear()

---@type Drive|nil
local sourceDrive = peripheral.wrap('back')
if not sourceDrive then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Missing disk drive on the ;lim;back ;org;of the computer\n"
    )
    return
end

local destDrive = peripheral.wrap('right')
if not destDrive then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Missing disk drive on the ;lim;right ;org;of the computer\n"
    )
    return
end

local mon = utils.getMonitor()
if not mon then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;A monitor needs to be attached to the computer\n"
    )
    return
end

mon.setTextScale(1)
local width, height = mon.getSize()
if width ~= 29 or height ~= 5 then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Monitor needs to be ;lim;3 ;org;blocks wide and ;lim;1 ;org;block tall\n"
    )
    return
end

utils.installDisk()
