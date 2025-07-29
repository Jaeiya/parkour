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
local version = "2.6.0"


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
    get            = { slug = "get.lua", fileName = "get" },

    boardinstaller = { slug = "boardinstaller.lua", fileName = "installboard" },
    board          = { slug = "board.lua",          fileName = "board"},
    boardlib       = { slug = "boardlib.lua",       fileName = "boardlib" },
    boardredstone  = { slug = "boardredstone.lua",  fileName = "boardredstone" },
    boardui        = { slug = "boardui.lua",        fileName = "boardui" },
    boardstartup   = { slug = "boardstartup.lua",   fileName = "boardstartup" },
    boardtimer     = { slug = "boardtimer.lua",     fileName = "boardtimer" },
    boardstate     = { slug = "boardstate.lua",     fileName = "boardstate" },
    boardstats     = { slug = "boardstats.lua",     fileName = "boardstats" },

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

    utils         = { slug = "utils.lua",        fileName = "utils" },
    detectplayer  = { slug = "detectplayer.lua", fileName = "detectplayer" },

    copydisk          = { slug = "copydisk.lua",          fileName = "copydiskstartup" },
    copydiskinstaller = { slug = "copydiskinstaller.lua", fileName = "installcopydisk" },
}


---@class FormattedDisk
---@field version string
---@field scripts Script[]


---@class DiskMap
local diskMap = {
    leaderboard = {
        version = "3.1",
        scripts = {
            scriptMap.board,
            scriptMap.boardlib,
            scriptMap.boardui,
            scriptMap.boardredstone,
            scriptMap.boardinstaller,
            scriptMap.boardstartup,
            scriptMap.boardtimer,
            scriptMap.boardstate,
            scriptMap.boardstats,
            scriptMap.utils,
            scriptMap.detectplayer,
        }
    },
    statboard = {
        version = "1.0",
        scripts = {
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
        scripts = {
            scriptMap.monhost,
            scriptMap.monhostinstaller,
            scriptMap.monhostui,
            scriptMap.utils,
        }
    },
    display = {
        version = "2.2",
        scripts = {
            scriptMap.display,
            scriptMap.displayinstaller,
            scriptMap.utils,
        }
    },
    medals = {
        version = "1.1",
        scripts = {
            scriptMap.medals,
            scriptMap.medalsinstaller,
            scriptMap.utils,
        }
    },
    copydisk = {
        version = "1.1",
        scripts = {
            scriptMap.copydisk,
            scriptMap.copydiskinstaller,
            scriptMap.utils,
        }
    }
}


---@param script Script
local function getScriptFile(script)
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
        local content = getScriptFile(script)
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
        ";lgy;  6. ;wht;Copy Disk\n\n" ..

        ";red;  7. ;wht;Exit\n"
    )
    term.setTextColor(colors.yellow)
    write("> ")
    term.setTextColor(colors.lime)
    local choice = tonumber(read())

    if not choice or choice > 7 or choice < 1 then
        printError("invalid choice; try again!\n")
        printAdv(";lgy;Enter to continue...")
        read()
        goto restart
    end

    local name = ""
    ---@type FormattedDisk
    local selectedDisk

    if choice == 1 then
        selectedDisk = diskMap.leaderboard
        name = "Leaderboard"
    elseif choice == 2 then
        selectedDisk = diskMap.monhost
        name = "Monitor Host"
    elseif choice == 3 then
        selectedDisk = diskMap.display
        name = "Display"
    elseif choice == 4 then
        selectedDisk = diskMap.medals
        name = "Medals"
    elseif choice == 5 then
        selectedDisk = diskMap.statboard
        name = "Stat Board"
    elseif choice == 6 then
        selectedDisk = diskMap.copydisk
        name = "CopyDisk"
    end

    if choice == 7 then
        return
    end

    local diskLabel = name .. " v"..selectedDisk.version
    createDisk(selectedDisk)
    finalizeDisk(diskLabel, name)
end


---@type string[]
local args = {...}

if not args[1] then
    printHelp()
    return
end

local arg1 = args[1]
local arg2 = arg[2]

if arg1 == "disk" then
    return promptDisk()
end

if arg1 == "clean" then
    return cleanDisk()
end

if arg1 == "l" and arg2 == "clean" then
    return cleanComputer()
end


if #args > 1 then
    local flag = arg1
    local scriptName = arg2

    if flag ~= "l" and flag ~= "sl" and flag ~= "s" and flag ~= "ls" or not scriptName then
        printHelp()
        return
    end

    local script = scriptMap[scriptName]
    if not script then
        printAdv(";cyn;'"..scriptName.."' ;org;could not be found\n")
        return
    end

    printAdv("\n ;org;Getting: ;cyn;"..scriptName)

    if flag == "s" or flag == 'sl' or flag == 'ls' then
        script.fileName = "startup"
    end

    local content = getScriptFile(script)
    writeFile("/disk/" .. script.fileName, content)

    if flag == "l" or flag == "sl" or flag == "ls" then
        writeFile(script.fileName, content)
    end

    if flag == "l" or flag == "sl" or flag == "ls" then
        printAdv(
            ";org;Saved To: ;lim;/disk/"..script.fileName ..
            "\n;org;Saved To: ;lim;/"..script.fileName.."\n"
        )
    else
        printAdv(";org;Saved To: ;lim;/"..script.fileName.."\n")
    end
    return
end


local scriptName = arg1
local script = scriptMap[scriptName]
if not script then
    printAdv(";cyn;'"..scriptName.."' ;org;could not be found\n")
    return
end


printAdv( "\n ;org;Getting: ;cyn;"..scriptName)

local content = getScriptFile(script)
writeFile("/disk/" .. script.fileName, content)

printAdv(";org;Saved To: ;lim;/disk/"..script.fileName.."\n")
