local utils = require('utils')


local mon = utils.getMonitor()
if not mon then
    utils.print(
        ';red;Installation Aborted\n' ..
        ';org;Attach an ;lim;advanced monitor ;org;to the computer.\n'
    )
    return
end

local modem = utils.getModem('wired', 'bottom')
if not modem then
    utils.print(
        ';red;Installation Aborted\n' ..
        ';org;Attach a ;lim;wired modem ;org;to the ;lim;bottom ;org;of this computer.\n' ..

        ';org;You then need to connect the ;lim;modem ;org;with networking cable to all ' ..
        'other computers running CopyDisk.'
    )
    return
end

utils.installDisk()
