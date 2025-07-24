
local utils = require("utils")

local mon = utils.getMonitor()
if not mon then
    utils.print(
        "\n;red;Installation Aborted\n" ..
        ";org;Attach an ;lim;advanced monitor ;org;to this computer\n"
    )
    return
end

mon.setTextScale(2)
local width, height = mon.getSize()
if width < 30 or width > 30 or height > 10 or height < 10 then
    utils.print(
        "\n;red;Installation Aborted\n" ..
        ";org;Expected a ;lim;6 block ;org;wide and ;lim;4 block ;org;tall monitor\n"
    )
    return
end

utils.installDisk()
