
local utils = require('utils')

utils.clear()

if not utils.getDrive('back') then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Attach a ;lim;disk drive ;org;to the back of the computer.\n"
    )
    return
end

if not utils.getDrive('right') then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Attach a ;lim;disk drive ;org;to the right side of the computer.\n"
    )
    return
end

local mon = utils.getMonitor()
if not mon then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Attach an ;lim;advanced monitor ;org;to the computer.\n"
    )
    return
end

mon.setTextScale(1)
local width, height = mon.getSize()
if width ~= 29 or height ~= 5 then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;The ;lim;monitor ;org;needs to be ;lim;3 ;org;blocks wide and ;lim;1 ;org;block tall\n"
    )
    return
end

if not utils.getModem('wired', 'bottom') then
    utils.print(
        ';red;Installation Aborted\n' ..
        ';org;Attach a ;lim;Modem ;org;to the ;lim;bottom ;org;of the computer.\n'
    )
    return
end

utils.installDisk()
