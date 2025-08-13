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

local modem = utils.getModem('wired', 'bottom')
if not modem then
    printError('script terminated; missing bottom modem')
    return
end


mon.setTextScale(1)
mon.setPaletteColor(colors.black, 0x000000)
mon.setPaletteColor(colors.red, 0xFF0000)
mon.setPaletteColor(colors.orange, 0xFFD800)


local function getUniqueChannel()
    local uniqueChan = os.epoch('utc') % 65535
    ---These channels are reserved already
    if uniqueChan >= 1337 or uniqueChan <= 1347 then
        return uniqueChan + math.random(10, 1000)
    end
    return uniqueChan
end


---@class Disk
---@field files DiskFile[]
---@field name string

---@class DiskFile
---@field name string
---@field data string


---@class CopyDiskDatabase
---@field disksCreated integer
---@field channel integer
local db = {
    disksCreated = 0,
    -- Generate a relatively unique channel
    channel = getUniqueChannel(),
}
local dbPath = 'copydisk.db'
db = utils.loadConfig(dbPath, db)
local announceChannel = 1338

local SourceState = {
    MISSING = 1,
    INVALID = 2,
    GOOD    = 3
}

local state = {
    source = SourceState.MISSING
}

modem.open(db.channel)
modem.open(announceChannel)


local function validateSourceDisk()
    if not sourceDrive.isDiskPresent() then
        state.source = SourceState.MISSING
        utils.clear(mon)
        mon.setCursorPos(1, 3)
        utils.print(';red;'..utils.centerText("Insert Source Disk", mon), mon)

    elseif #fs.list(sourceDrive.getMountPath()) == 0 or sourceDrive.getDiskLabel() == "" then
        state.source = SourceState.INVALID
        mon.clearLine()
        mon.setCursorPos(1, 3)
        utils.print(';org;'..utils.centerText("Needs Formatted Disk", mon), mon)
        sourceDrive.ejectDisk()
        sleep(2)
    else
        state.source = SourceState.GOOD
    end
end


local function validateOnEjection()
    while true do
        local side = utils.pullDiskEvent('eject')

        if side == 'back' and state.source ~= SourceState.INVALID then
            state.source = SourceState.MISSING
            utils.clear(mon)
            mon.setCursorPos(1, 3)
            utils.print(';red;'..utils.centerText("Insert Source Disk", mon), mon)
        end
    end
end


local function waitForDisk()
    while true do
        utils.clear()
        utils.print(
            "... Running Disk Copier ...\n\n" ..
            "  ;lgy;disks_created: ;cyn;" .. db.disksCreated
        )

        validateSourceDisk()
        if state.source ~= SourceState.GOOD then
            ---Poll for valid source disk
            sleep(0.15)
            goto continue
        end

        utils.clear(mon)
        mon.setCursorPos(1, 2)
        local title = "Create " .. sourceDrive.getDiskLabel()
        utils.print(";lbu;"..utils.centerText(title, mon), mon)
        mon.setCursorPos(1, 4)
        mon.clearLine()
        utils.print(";org;"..utils.centerText("Enter Disk", mon), mon)

        local side = utils.pullDiskEvent('insert')

        ---We have received a source drive insertion event so we
        ---force a validation
        if side == 'back' then
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
end


local function waitForUpdate()
    while true do
        local eventData = utils.pullModemEvent()
        local isAnnouncing = eventData.channel == announceChannel
        local isUpdating = eventData.channel == db.channel

        if isAnnouncing and eventData.message.action == 'send_address' then
            local nameParts = utils.splitString(sourceDrive.getDiskLabel())
            ---Ignore the version string on the end
            nameParts[#nameParts] = nil

            utils.transmit(modem, eventData.replyChannel, db.channel, {
                action = 'update_address',
                payload = table.concat(nameParts, ' ')
            })
        end

        if isUpdating and eventData.message.action == 'confirm_address' then
            utils.clear(mon)
            mon.setCursorPos(1, 2)
            utils.print(utils.centerText(';ylw;Updating Source Disk',mon), mon)
            mon.setCursorPos(1, 4)
            utils.print(utils.centerText(';red;Do Not Interact', mon), mon)
            utils.transmit(modem, eventData.replyChannel, db.channel, { action = 'address_confirmed' })
        end

        if isUpdating and eventData.message.action == 'update_disk' then
            ---@type Disk
            local disk = eventData.message.payload
            if not disk or #disk.files == 0 then
                error('invalid disk payload')
            end

            local path = sourceDrive.getMountPath()
            utils.cleanScripts(path)
            sourceDrive.setDiskLabel(disk.name)

            for _, file in ipairs(disk.files) do
                utils.writeFile(fs.combine(path, file.name), file.data)
            end

            ---Force a refresh by simulating a disk event
            os.queueEvent('disk', 'back')
        end
    end
end


parallel.waitForAny(
    validateOnEjection,
    waitForDisk,
    waitForUpdate
)
