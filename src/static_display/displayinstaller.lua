
local utils = require("utils")


print()
local modem = utils.getModem('wired')
if not modem then
    utils.print(
        ";red;Installation Aborted\n" ..

        ";org;Attach a ;lim;wired modem ;org;to this computer and connect it " ..
        "(with ;lim;networking cable;org;) to another ;lim;modem;org;, attached to an " ..
        ";lim;advanced monitor\n\n" ..

        ";org;Make sure you ;lim;right click ;org;the modems to activate them, once you've " ..
        "finished connecting them\n\n"
    )
    return
end

local mon = utils.getMonitor()
if not mon then
    utils.print(
        ";red;Installation Aborted\n" ..

        ";org;Attach an ;lim;advanced monitor ;org;to the modem on the other side of " ..
        "the networking cable.\n" ..

        "Make sure both modems are ;lim;right clicked ;org;and glowing red.\n"
    )
    return
end

utils.installDisk()

