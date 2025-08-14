local utils = require('utils')

local mon = utils.getMonitor()
if not mon then
    printError('update disk terminated; missing monitor')
    return
end

local modem = utils.getModem('wired', 'bottom')
if not modem then
    printError('update disk terminated; missing modem')
    return
end


local receiveChannel = 1337
local announceChannel = 1338
local confirmChannel = 1339

utils.clear(mon)
modem.open(receiveChannel)
modem.open(confirmChannel)

local configPath = 'updatedisk.cfg'
---@type table<string, integer> The name of the disk maps to the channel
local config = utils.loadConfig(configPath, {})

---@class DiskNameMap
local diskNameMap = {
    ['Leaderboard']  = 'leaderboard',
    ['Monitor Host'] = 'monhost',
    ['Stat Board']   = 'statboard',
    ['Display']      = 'display',
    ['Medals Board'] = 'medalsboard',
    ['CopyDisk']     = 'copydisk',
    ['Disk Updater'] = 'diskupdater',
}


local function lookupDisks()
    utils.transmit(modem, announceChannel, receiveChannel, {
        action = 'send_address'
    })
end


local function waitForAddresses()
    while true do
        local eventData = utils.pullModemEvent()

        if eventData.message.action == 'update_address' then
            ---@type string
            local payload = eventData.message.payload
            local existingChannel = config[payload]

            if not existingChannel or existingChannel ~= eventData.replyChannel then
                config[payload] = eventData.replyChannel
                utils.saveConfig(configPath, config)
            end
        end
    end
end


local function waitForDiskProgress(diskName)
    local state = {
        diskVersion = '',
        fileCount = 0,
        progress = 0,
        isUpdating = false,
    }

    local diskStorePath = '/disk_store'

    ---@type Disk
    local disk = {
        files = {},
        name = diskName
    }

    utils.clear(mon)

    while true do
        if not state.isUpdating then
            local f = fs.open(fs.combine(diskStorePath, 'disk_info.txt'), 'r')
            if f then
                local fileParts = utils.splitString(f.readAll())
                state.diskVersion = fileParts[1]
                state.fileCount = tonumber(fileParts[2])
                state.isUpdating = true
                f.close()
            end
        end

        if state.isUpdating and state.progress < state.fileCount then
            local fileList = fs.list(diskStorePath)
            state.progress = 0
            for _, file in ipairs(fileList) do
                if not string.find(file, '.', 1, true) then
                    state.progress = state.progress + 1
                end
            end
            utils.renderProgressBar('Updating: '..diskName, 1, 2, state.progress, state.fileCount, mon)

            -- Allow player to see 100% progress
            if state.progress == state.fileCount then
                sleep(0.2)
                disk.name = disk.name..' '..state.diskVersion
                fileList = fs.list(diskStorePath)
                for _, file in ipairs(fileList) do
                    local f = fs.open(fs.combine(diskStorePath, file), 'r')
                    if not f then error('could not find disk file: ' .. file) end
                    disk.files[#disk.files+1] = {
                        name = file,
                        data = f.readAll()
                    }
                end
            end
        end

        if state.isUpdating and state.progress >= state.fileCount then
            utils.clear(mon)
            mon.setCursorPos(1, 3)
            utils.print(utils.centerText(';lim;'..diskName..' Updated!', mon), mon)
            utils.transmit(modem, config[diskName], receiveChannel, {
                action = 'update_disk',
                payload = disk
            })
            sleep(1.5)
            utils.clear(mon)
            return
        end

        sleep(0.05)
    end
end


local function promptUpdateDisk()
    utils.clear()

    ---@type PromptMenuChoice[]
    local choices = {}

    for key in pairs(config) do
        choices[#choices+1] = {
            name = key,
            exec = function()
                utils.clear()
                utils.print('... Confirming Connection ...')
                utils.transmit(modem, config[key], confirmChannel, { action = 'confirm_address' })
                local confirmed = false

                parallel.waitForAny(
                    function() sleep(1.5) end,
                    function ()
                        local eventData = utils.pullModemEvent()
                        if eventData.message.action == 'address_confirmed' then
                            confirmed = true
                        end
                    end
                )

                term.setCursorPos(1, 1)
                term.clearLine()

                if confirmed then
                    utils.print('... Updating '..key..' ...')
                    parallel.waitForAll(
                        function() waitForDiskProgress(key) end,
                        function() shell.run('disk/get d '..diskNameMap[key]) end
                    )
                else
                    utils.promptError('Failed to connect to "'..key..' Disk" computer')
                end

            end
        }
    end

    if utils.promptMenu('Select Disk to Update', choices) then
        return
    end
end


local function execUserInterface()
    ::prompt::
    utils.clear(mon)
    mon.setCursorPos(1, 2)
    utils.print(utils.centerText(';lbu;Disk Updater', mon), mon)
    mon.setCursorPos(1, 4)
    utils.print(utils.centerText(';ylw;Open Terminal to Use', mon), mon)

    ---@type PromptMenuChoice[]
    local choices = {
        -- Whenever a disk updates, we'll need to use this command to get the proper
        -- version of the disk.
        { name = 'Update Get', exec = function () shell.run('disk/get get') end},
        { name = 'Lookup Disks', exec = lookupDisks },
        { name = 'Update Disk', exec = promptUpdateDisk },
    }

    if utils.promptMenu('Disk Updater', choices) then
        return
    end

    goto prompt
end


-- Make sure we always get the latest addresses on startup
lookupDisks()


parallel.waitForAny(
    waitForAddresses,
    execUserInterface
)
