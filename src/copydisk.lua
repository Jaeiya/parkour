local utils = require('utils')

local disksCreated = 0

---@type Drive|nil
local sourceDrive = peripheral.wrap('back')
if not sourceDrive then
    printError("script terminated; missing source drive")
    return
end

---@type Drive|nil
local destDrive = peripheral.wrap('right')
if not destDrive then
    printError("script terminated; missing destination drive")
    return
end

local mon = utils.getMonitor()
if not mon then
    printError("script terminated; missing monitors")
    return
end


mon.setPaletteColor(colors.black, 0x000000)
mon.setPaletteColor(colors.red, 0xFF0000)
mon.setPaletteColor(colors.orange, 0xFFD800)


while true do
    utils.clear()
    utils.clear(mon)
    utils.print(
        "... Running Disk Copier ...\n\n" ..
        "  ;lgy;disks_created: ;cyn;" .. disksCreated
    )
    utils.print(";lbu;"..utils.centerText(sourceDrive.getDiskLabel(), mon), mon)
    mon.setCursorPos(1, 3)
    utils.print(";org;"..utils.centerText("Enter Disk", mon), mon)

    os.pullEvent('disk')

    if not destDrive.isDiskPresent() then
    elseif #fs.list(destDrive.getMountPath()) > 0 then
        mon.setCursorPos(1, 3)
        mon.clearLine()
        utils.print(';red;'..utils.centerText("Empty Disk Required", mon), mon)
        destDrive.ejectDisk()
        sleep(2)
    else
        local srcPath = sourceDrive.getMountPath()
        local destPath = destDrive.getMountPath()

        local files = fs.list(srcPath)
        for _, file in ipairs(files) do
            fs.copy(fs.combine(srcPath, file), fs.combine(destPath, file))
        end
        destDrive.setDiskLabel(sourceDrive.getDiskLabel())
        disksCreated = disksCreated + 1
        mon.setCursorPos(1, 3)
        mon.clearLine()
        utils.print(';lim;'..utils.centerText("Disk Created", mon), mon)
        destDrive.ejectDisk()
        sleep(2.5)
    end
end

