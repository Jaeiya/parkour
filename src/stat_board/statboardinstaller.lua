local utils = require('utils')


utils.clear()
print()


local mon = utils.getMonitor()
if not mon then
    printError("Installation Aborted")
    utils.print(";org;Attach an ;lim;advanced monitor ;org;to this computer\n")
    return
end


---We can't calculate the size without knowing the scale
mon.setTextScale(1.5)
local monW, monH = mon.getSize()
if monW < 33 or monH < 17 then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;The ;lim;monitor ;org;needs to be at least ;lim;5 ;org;blocks wide " ..
        "and ;lim;4 ;org;blocks tall\n\n"
    )
    return
end


if not utils.getPlayerDetector() then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Attach a ;lim;player detector ;org;to this computer\n\n"
    )
    return
end


local modem = utils.getModem()
if not modem then
    utils.print(
        ";red;Installation Aborted\n" ..
        ";org;Attach an ;lim;ender modem ;org;to this computer\n\n"
    )
    return
end


if not modem.isWireless() then
    utils.print(
        ";red;Installation Aborted\n" ..
        "The attached ;lim;modem ;org;needs to be ;lim;wireless;\n\n"
    )
    return
end


local hostname = utils.prompt("Enter Host Name ;org;(unique)")
local protocol = utils.prompt("Enter Listener Protocol ")

utils.saveConfig("statboard.cfg", {
    hostname = hostname,
    protocol = protocol
})

utils.installDisk()
