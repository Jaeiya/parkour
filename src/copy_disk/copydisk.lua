local utils = require('utils')
utils.clear()

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


mon.setTextScale(1)
mon.setPaletteColor(colors.black, 0x000000)
mon.setPaletteColor(colors.red, 0xFF0000)
mon.setPaletteColor(colors.orange, 0xFFD800)


---@class CopyDiskDatabase
---@field disksCreated integer
local db = {
    disksCreated = 0,
}
local dbPath = 'copydisk.db'
db = utils.loadConfig(dbPath, db)


local function validateSourceDisk()
    while not sourceDrive.isDiskPresent() do
        mon.setCursorPos(1, 3)
        mon.clearLine()
        utils.print(';red;'..utils.centerText("Insert Source Disk", mon), mon)
        os.pullEvent('disk')
        if #fs.list(sourceDrive.getMountPath()) == 0 or sourceDrive.getDiskLabel() == "" then
            mon.clearLine()
            mon.setCursorPos(1, 3)
            utils.print(';org;'..utils.centerText("Needs Formatted Disk", mon), mon)
            sourceDrive.ejectDisk()
            sleep(2)
        end
    end
end


while true do
    utils.clear()
    utils.clear(mon)
    utils.print(
        "... Running Disk Copier ...\n\n" ..
        "  ;lgy;disks_created: ;cyn;" .. db.disksCreated
    )

    validateSourceDisk()

    -- Clear error message if there is one
    mon.setCursorPos(1, 3)
    mon.clearLine()

    mon.setCursorPos(1, 2)
    local title = "Create " .. sourceDrive.getDiskLabel()
    utils.print(";lbu;"..utils.centerText(title, mon), mon)
    mon.setCursorPos(1, 4)
    mon.clearLine()
    utils.print(";org;"..utils.centerText("Enter Disk", mon), mon)

    os.pullEvent('disk')

    if not destDrive.isDiskPresent() then
        goto continue
    end

    local srcPath = sourceDrive.getMountPath()
    local destPath = destDrive.getMountPath()

    if #fs.list(destPath) > 0 then
        mon.setCursorPos(1, 4)
        mon.clearLine()
        utils.print(';red;'..utils.centerText("Empty Disk Required", mon), mon)
        destDrive.ejectDisk()
        sleep(2)
        goto continue
    end

    local files = fs.list(srcPath)
    for _, file in ipairs(files) do
        fs.copy(fs.combine(srcPath, file), fs.combine(destPath, file))
    end

    destDrive.setDiskLabel(sourceDrive.getDiskLabel())
    db.disksCreated = db.disksCreated + 1
    utils.saveConfig(dbPath, db)
    mon.setCursorPos(1, 4)
    mon.clearLine()
    utils.print(';lim;'..utils.centerText("Disk Created", mon), mon)
    destDrive.ejectDisk()
    sleep(2.5)

    ::continue::
end

