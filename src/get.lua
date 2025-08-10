---
---
--- The starting point for working with all the automated functions
--- of the parkour map.
---
--- What this script does:
---   - Format disks for setting up specific parkour functionality
---   - Update scripts on disks or computers
---   - Cleaning disks
---
--- To import the script into computer craft, execute this command:
--- pastebin get XZBmRq0B get
---
--- Once this script is imported, you can execute the 'get' command
--- without any arguments, to see the help display. This script
--- is designed to execute from a disk, not a computer.
---
---


-- Should be kept up to date with latest tagged version of repository
local version = "3.0.0"


---Color code map designed strictly for use with utils.printColor()
local colorCodes = {
    [";wht;"] = colors.white,
    [";org;"] = colors.orange,
    [";mgt;"] = colors.magenta,
    [";lbu;"] = colors.lightBlue,
    [";ylw;"] = colors.yellow,
    [";lim;"] = colors.lime,
    [";pnk;"] = colors.pink,
    [";gry;"] = colors.gray,
    [";lgy;"] = colors.lightGray,
    [";cyn;"] = colors.cyan,
    [";ppl;"] = colors.purple,
    [";blu;"] = colors.blue,
    [";bwn;"] = colors.brown,
    [";grn;"] = colors.green,
    [";red;"] = colors.red,
    [";blk;"] = colors.black,
}

---
---A more advanced version of print, that allows embedded color codes
---to change the terminals color on-the-fly.
---@param text string The text to print with supported color codes
---@param newLine? boolean Whether or not to add a new line at end of text (default: true)
local function printAdv(text, newLine)
    ---Track where we are in the string
    local pos = 1

    if newLine == nil then
        newLine = true
    end

    for i = 1, #text do
        if i + 4 > #text then break end

        local code = string.sub(text, i, i + 4)
        local color = colorCodes[code]
        if color then
            write(string.sub(text, pos, i-1))
            text = string.gsub(text, code, "", 1)
            term.setTextColor(color)
            pos = i
        end
    end

    write(string.sub(text, pos, #text))
    if newLine then
        write("\n")
    end
end



if not term.isColor() then
    printAdv(
        "\n;red;Invalid Environment\n" ..
        ";org;You can only run me on an advanced computer\n"
    )
    return
end

if not fs.exists("/disk/get") then
    printAdv(
        "\n;red;Invalid Install Location\n" ..
        ";org;Please import or copy me to a disk\n"
    )
    local d = peripheral.find("drive")
    if not d then
        printAdv("You'll need to attach a ;lim;drive ;org;to this computer and insert a ;lim;disk\n")
    end
    return
end


---@class Script
---@field slug string The gist slug (ex: name-of-file)
---@field fileName string The filename the script should have when saved


---@class ScriptMap
local scriptMap = {
    get = { slug = "get.lua", fileName = "get" },

    utils         = { slug = "utils.lua",        fileName = "utils" },
    detectplayer  = { slug = "detectplayer.lua", fileName = "detectplayer" },

    boardinstaller     = { slug = "boardinstaller.lua",     fileName = "installboard" },
    board              = { slug = "board.lua",              fileName = "board"},
    boardlib           = { slug = "boardlib.lua",           fileName = "boardlib" },
    boardredstone      = { slug = "boardredstone.lua",      fileName = "boardredstone" },
    boardui            = { slug = "boardui.lua",            fileName = "boardui" },
    boardstartup       = { slug = "boardstartup.lua",       fileName = "boardstartup" },
    boardmedalbridge   = { slug = "boardmedalbridge.lua",   fileName = "boardmedalbridge" },
    boardtimer         = { slug = "boardtimer.lua",         fileName = "boardtimer" },
    boardstate         = { slug = "boardstate.lua",         fileName = "boardstate" },
    boardstats         = { slug = "boardstats.lua",         fileName = "boardstats" },
    boardplayertracker = { slug = "boardplayertracker.lua", fileName = "boardplayertracker" },

    statboard          = { slug = "statboard.lua",          fileName = "statboard" },
    statboardstartup   = { slug = "statboardstartup.lua",   fileName = "statboardstartup" },
    statboardredstone  = { slug = "statboardredstone.lua",  fileName = "statboardredstone" },
    statboardui        = { slug = "statboardui.lua",        fileName = "statboardui" },
    statboardinstaller = { slug = "statboardinstaller.lua", fileName = "installstatboard" },

    monhostinstaller = { slug = "monhostinstaller.lua", fileName = "installmonhost" },
    monhost          = { slug = "monhost.lua",          fileName = "monhoststartup" },
    monhostui        = { slug = "monhostui.lua",        fileName = "monhostui"},

    display          = { slug = "display.lua",          fileName = "displaystartup" },
    displayinstaller = { slug = "displayinstaller.lua", fileName = "installdisplay" },

    medals          = { slug = "medals.lua",          fileName = "medalsstartup" },
    medalsinstaller = { slug = "medalsinstaller.lua", fileName = "installmedals" },

    copydisk          = { slug = "copydisk.lua",          fileName = "copydiskstartup" },
    copydiskinstaller = { slug = "copydiskinstaller.lua", fileName = "installcopydisk" },

    diskupdater          = { slug = 'diskupdater.lua',          fileName = 'diskupdaterstartup' },
    diskupdaterinstaller = { slug = 'diskupdaterinstaller.lua', fileName = 'diskupdaterinstaller' }
}


---@class FormattedDisk
---@field version string
---@field scripts Script[]
---@field name string

---@type table<string, FormattedDisk>
local diskMap = {
    leaderboard = {
        version = "4.0",
        name = "Leaderboard",
        scripts = {
            scriptMap.get,
            scriptMap.board,
            scriptMap.boardlib,
            scriptMap.boardui,
            scriptMap.boardredstone,
            scriptMap.boardinstaller,
            scriptMap.boardmedalbridge,
            scriptMap.boardstartup,
            scriptMap.boardtimer,
            scriptMap.boardstate,
            scriptMap.boardstats,
            scriptMap.boardplayertracker,
            scriptMap.utils,
            scriptMap.detectplayer,
        }
    },
    statboard = {
        version = "2.1",
        name = "Stat Board",
        scripts = {
            scriptMap.get,
            scriptMap.statboard,
            scriptMap.statboardstartup,
            scriptMap.statboardredstone,
            scriptMap.statboardui,
            scriptMap.statboardinstaller,
            scriptMap.utils,
        }
    },
    monhost = {
        version = "2.5",
        name = "Monitor Host",
        scripts = {
            scriptMap.get,
            scriptMap.monhost,
            scriptMap.monhostinstaller,
            scriptMap.monhostui,
            scriptMap.utils,
        }
    },
    display = {
        version = "2.2",
        name = "Display",
        scripts = {
            scriptMap.get,
            scriptMap.display,
            scriptMap.displayinstaller,
            scriptMap.utils,
        }
    },
    medals = {
        version = "1.1",
        name = "Medal Board",
        scripts = {
            scriptMap.get,
            scriptMap.medals,
            scriptMap.medalsinstaller,
            scriptMap.utils,
        }
    },
    copydisk = {
        version = "1.1",
        name = "CopyDisk",
        scripts = {
            scriptMap.get,
            scriptMap.copydisk,
            scriptMap.copydiskinstaller,
            scriptMap.utils,
        }
    },
    diskupdater = {
        version = '1.0',
        name = 'Disk Updater',
        scripts = {
            scriptMap.get,
            scriptMap.diskupdater,
            scriptMap.diskupdaterinstaller,
            scriptMap.utils,
        }
    }
}


---@param script Script
local function getScriptContent(script)
    local apiURL =  "https://gist.githubusercontent.com/Jaeiya/74884f82055c3ac1f3ce09674e011a57/raw/"
    -- Prevents getting a cached version
    local cacheBustFragment = "?bust=" .. tostring(os.epoch("utc"))
    local resp = http.get(apiURL .. script.slug .. cacheBustFragment)

    if not resp then
        error("failed to get script: " .. script.slug)
    end

    local content = resp.readAll()
    if not content then
        error("github responded with an empty body")
    end
    return content
end


---Writes a progress bar to the screen.
---@param text string
---@param step integer The current progress step (0 to limit)
---@param maxSteps integer The total number of steps to complete (max progress)
local function writeProgress(text, step, maxSteps)
    if step > maxSteps then
        error("step should never be greater than max")
    end
    local _, y = term.getCursorPos()
    local maxBarSize = 20
    step = (maxBarSize / maxSteps) * step
    local barSize = math.floor((step / maxBarSize) * maxBarSize)
    local bar = string.rep("=", barSize)
    local barMargin = maxBarSize - barSize
    term.setCursorPos(1, y)
    printAdv(";org;"..text..";wht; [;cyn;"..bar..string.rep(" ", barMargin)..";wht;]", false)
    -- Clears progress bar so it can be overwritten
    -- with flavor text.
    if math.floor(step) >= maxBarSize then
        -- Give time for user to see completed bar before clear
        sleep(0.2)
        term.setCursorPos(1, y)
        term.clearLine()
    end
end


---Creates or overwrites the specified file path
---@param filepath string The full path of the file to create
---@param text string The content to write to the file
local function writeFile(filepath, text)
    local file = fs.open(filepath, "w")
    if not file then
        error("probably an invalid path: " .. filepath)
    end
    file.write(text)
    file.close()
end


---Sets the disk label and prints the 'name' of the disk
---that was created.
---@param label string
---@param name string
local function finalizeDisk(label, name)
    local d = peripheral.find("drive")
    if d then
        d.setDiskLabel(label)
    end
    printAdv(";lim;" .. name .. " disk created!\n")
end


---Deletes all files except the 'get' script
---from the disk.
---@param silent? boolean Whether or not to print confirmation `(default: false)`
local function cleanDisk(silent)
    local fileList = fs.list("/disk")
    for _, file in ipairs(fileList) do
        if file ~= "get" then
            fs.delete("/disk/" .. file)
        end
    end
    if not silent then
        printAdv("\n;org;Disk has been cleaned\n")
    end
end


local function cleanComputer()
    local fileList = fs.list(".")
    for _, file in ipairs(fileList) do
        if file ~= "rom" and file ~= "disk" then
            fs.delete(file)
        end
    end
    printAdv("\n;org;Computer has been cleaned\n")
end


---Cleans and downloads all scripts required to
---create a specific disk.
---@param diskData FormattedDisk
local function createDisk(diskData)
    print()
    writeProgress("Creating Disk", 0, #diskData.scripts)
    -- A disk should have ONLY the files created by this function.
    cleanDisk(true)
    for i, script in ipairs(diskData.scripts) do
        local content = getScriptContent(script)
        if string.find(script.fileName, "install") then
            -- Do not allow disks startup to interfere with computers
            content = [[
-- Auto-injected by disk creator
if fs.exists("startup") then return shell.run("startup") end
]] .. content
            script.fileName = "startup"
        elseif string.find(script.fileName, "startup") then
            -- We do not want the disk to startup with the computer
            script.fileName = "startup_"
        end
        writeFile("/disk/" .. script.fileName, content)
        writeProgress("Creating Disk", i, #diskData.scripts)
    end
end


---Downloads all scripts required to store the
---specified disk data.
---@param diskData FormattedDisk
local function createDiskStore(diskData)
    print()
    writeProgress("Storing Disk", 0, #diskData.scripts)
    local storePath = '/disk_store'
    if fs.exists(storePath) then
        fs.delete(storePath)
    end


    local diskInfoPath = fs.combine(storePath, 'disk_info.txt')
    writeFile(diskInfoPath, 'v'..diskData.version..' '..tostring(#diskData.scripts))

    -- Give enough time to read file_count
    sleep(0.1)

    for i, script in ipairs(diskData.scripts) do
        local content = getScriptContent(script)

        if string.find(script.fileName, "install") then
            -- Do not allow disks startup to interfere with computers
            content = [[
-- Auto-injected by disk creator
if fs.exists("startup") then return shell.run("startup") end
]] .. content
            script.fileName = "startup"

        elseif string.find(script.fileName, "startup") then
            -- We do not want the disk to startup with the computer
            script.fileName = "startup_"
        end

        writeFile(fs.combine(storePath, script.fileName), content)
        writeProgress("Storing Disk", i, #diskData.scripts)
    end

    fs.delete(diskInfoPath)
end


local function printHelp()
    term.clear()
    term.setCursorPos(1, 1)
    printAdv(
        ";ppl;Get (;ylw;v"..version..";ppl;) Usage:\n" ..

        ";lgy;  Formats a disk to a specific type (ex: master)\n" ..
        ";org;    get ;cyn;disk\n\n" ..

        ";lgy;  Deletes all files on a disk ;pnk;except ;lgy;'get'\n" ..
        ";org;    get ;cyn;clean\n\n" ..

        ";lgy;  Deletes all files on the computer\n" ..
        ";org;    get ;cyn;l clean\n\n" ..

        ";lgy;  Downloads script to disk\n" ..
        ";org;    get ;cyn;<script_name>\n\n" ..

        ";lgy;  Downloads a script to disk and computer\n" ..
        ";org;    get ;cyn;l <script_name>\n"
    )
end


local function promptDisk()
::restart::
    term.clear()
    term.setCursorPos(1, 1)
    printAdv(
        ";ylw;Format Disk\n\n" ..
        ";lgy;  1. ;wht;Leaderboard\n" ..
        ";lgy;  2. ;wht;Monitor Host\n" ..
        ";lgy;  3. ;wht;Display\n" ..
        ";lgy;  4. ;wht;Medals\n" ..
        ";lgy;  5. ;wht;Stat Board\n" ..
        ";lgy;  6. ;wht;Copy Disk\n" ..
        ";lgy;  7. ;wht;Disk Updater\n\n" ..

        ";red;  8. ;wht;Exit\n"
    )
    term.setTextColor(colors.yellow)
    write("> ")
    term.setTextColor(colors.lime)
    local choice = tonumber(read())

    if not choice or choice > 8 or choice < 1 then
        printError("invalid choice; try again!\n")
        printAdv(";lgy;Enter to continue...")
        read()
        goto restart
    end

    ---@type FormattedDisk
    local selectedDisk

    if     choice == 1 then selectedDisk = diskMap.leaderboard
    elseif choice == 2 then selectedDisk = diskMap.monhost
    elseif choice == 3 then selectedDisk = diskMap.display
    elseif choice == 4 then selectedDisk = diskMap.medals
    elseif choice == 5 then selectedDisk = diskMap.statboard
    elseif choice == 6 then selectedDisk = diskMap.copydisk
    elseif choice == 7 then selectedDisk = diskMap.diskupdater
    end

    if choice == 8 then
        return
    end

    local diskLabel = selectedDisk.name .. " v"..selectedDisk.version
    createDisk(selectedDisk)
    finalizeDisk(diskLabel, selectedDisk.name)
end


---@param scriptName string
---@param isLocal? boolean
---@param isStartup? boolean
local function writeScript(scriptName, isLocal, isStartup)
    printAdv("\n ;org;Getting: ;cyn;"..scriptName)
    local script = scriptMap[scriptName]
    if not script then
        printAdv(";cyn;'"..scriptName.."' ;org;could not be found\n")
        return
    end

    local content = getScriptContent(script)
    if isStartup then
        script.fileName = 'startup'
    end

    writeFile("/disk/" .. script.fileName, content)
    printAdv(";org;Saved To: ;lim;/disk/"..script.fileName)

    if isLocal then
        writeFile(script.fileName, content)
        printAdv(";org;Saved To: ;lim;/"..script.fileName.."\n")
    else
        print()
    end
end




---@param args string[]
local function handleSingleArgs(args)
    local arg1 = args[1]

    if arg1 == "disk" then
        promptDisk()
        return true
    end

    if arg1 == "clean" then
        cleanDisk()
        return true
    end

    return false
end


local flagMap = {
    ["l clean"] = cleanComputer,

    ---@param scriptName string
    l = function (scriptName) writeScript(scriptName, true)  end,

    ---@param scriptName string
    s  = function (scriptName) writeScript(scriptName, false, true) end,

    ---@param scriptName string
    sl = function (scriptName) writeScript(scriptName, true, true) end,

    ---@param scriptName string
    ls = function (scriptName) writeScript(scriptName, true, true) end,
}


---Adds all disk flags for creating a disk storage folder:
---"get d <script_name>"
for scriptName in pairs(diskMap) do
    flagMap['d '..scriptName] = function() createDiskStore(diskMap[scriptName]) end
end


---@param args string[]
local function handleMultipleArgs(args)
    local arg1 = args[1]
    local arg2 = args[2]

    if #args > 1 then
        local flag = arg1

        -- Check for constant flag-function
        if flagMap[flag.." "..arg2] then
            flagMap[flag.." "..arg2]()
            return true
        end

        local flagFunc = flagMap[flag]
        if not flagFunc then
            printHelp()
            return true
        end

        local scriptName = arg2
        flagFunc(scriptName)
        return true
    end

    return false
end



---@type string[]
local args = {...}

if not args[1] then
    printHelp()
    return
end

if handleSingleArgs(args) then
    return
end

if handleMultipleArgs(args) then
    return
end

writeScript(args[1])



