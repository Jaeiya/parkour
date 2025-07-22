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


if not term.isColor() then
    print()
    term.setTextColor(colors.red)
    print("Invalid Environment\n")
    term.setTextColor(colors.orange)
    print("You can only run me on an advanced computer")
    print()
    return
end

if not fs.exists("/disk/get") then
    print()
    term.setTextColor(colors.red)
    print("Invalid Install Location")
    print()
    term.setTextColor(colors.orange)
    print("Please import or copy me to a disk")
    local d = peripheral.find("drive")
    if not d then
        print()
        write("You'll need to attach a ")
        term.setTextColor(colors.lime)
        write("drive ")
        term.setTextColor(colors.orange)
        write("to this computer and insert a ")
        term.setTextColor(colors.lime)
        write("disk\n")
    end
    print()
    return
end


---@class Script
---@field slug string The gist slug (ex: name-of-file)
---@field fileName string The filename the script should have when saved

---@class ScriptMap
---@field get Script
---
---@field boardinstaller Script
---@field board Script
---@field boardlib Script
---@field boardredstone Script
---@field boardui Script
---@field boardstartup Script
---@field boardtimer Script
---@field boardstate Script
---
---@field monhostinstaller Script
---@field monhoststartup Script
---@field monhost Script
---
---@field display Script
---@field displayinstaller Script
---@field detectplayer Script
---
---@field utils Script
local scriptMap = {
    get            = { slug = "get.lua", fileName = "get" },

    boardinstaller = { slug = "boardinstaller.lua", fileName = "install_board" },
    board          = { slug = "board.lua",          fileName = "board"},
    boardlib       = { slug = "boardlib.lua",       fileName = "board_lib" },
    boardredstone  = { slug = "boardredstone.lua",  fileName = "board_redstone" },
    boardui        = { slug = "boardui.lua",        fileName = "board_ui" },
    boardstartup   = { slug = "boardstartup.lua",   fileName = "board_startup" },
    boardtimer     = { slug = "boardtimer.lua",     fileName = "board_timer" },
    boardstate     = { slug = "boardstate.lua",     fileName = "board_state" },

    monhostinstaller = { slug = "monhostinstaller.lua", fileName = "install_monhost" },
    monhoststartup   = { slug = "monhoststartup.lua",   fileName = "monhost_startup" },
    monhost          = { slug = "monhost.lua",          fileName = "monhost" },

    display          = { slug = "display.lua",          fileName = "display" },
    displayinstaller = { slug = "displayinstaller.lua", fileName = "install_display" },

    utils         = { slug = "utils.lua",        fileName = "utils" },
    detectplayer  = { slug = "detectplayer.lua", fileName = "detect_player" },
}


---@class FormattedDisk
---@field version string
---@field scripts Script[]


---@class DiskMap
---@field master FormattedDisk
---@field leaderboard FormattedDisk
---@field monhost FormattedDisk
---@field display FormattedDisk
local diskMap = {
    master = {
        version = "2.0",
        scripts ={
            scriptMap.get,
            scriptMap.boardlib,
            scriptMap.boardui,
            scriptMap.boardredstone,
            scriptMap.boardinstaller,
            scriptMap.boardstartup,
            scriptMap.boardtimer,
            scriptMap.monhost,
            scriptMap.monhoststartup,
            scriptMap.monhostinstaller,
            scriptMap.display,
            scriptMap.displayinstaller,
            scriptMap.detectplayer,
            scriptMap.utils,
        }
    },
    leaderboard = {
        version = "2.0",
        scripts = {
            scriptMap.board,
            scriptMap.boardlib,
            scriptMap.boardui,
            scriptMap.boardredstone,
            scriptMap.boardinstaller,
            scriptMap.boardstartup,
            scriptMap.boardtimer,
            scriptMap.boardstate,
            scriptMap.utils,
            scriptMap.detectplayer,
        }
    },
    monhost = {
        version = "2.0",
        scripts = {
            scriptMap.monhost,
            scriptMap.monhoststartup,
            scriptMap.monhostinstaller,
            scriptMap.utils,
        }
    },
    display = {
        version = "2.0",
        scripts = {
            scriptMap.display,
            scriptMap.displayinstaller,
            scriptMap.utils,
        }
    },
}



---Downloads the specified script and returns its content
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
    term.setTextColor(colors.orange)
    write(text)
    term.setTextColor(colors.white)
    write(" [")
    term.setTextColor(colors.cyan)
    write(bar .. string.rep(" ", barMargin))
    term.setTextColor(colors.white)
    write("]")
    -- Clears progress bar so it can be overwritten
    -- with flavor text.
    if math.floor(step) >= maxBarSize then
        term.setCursorPos(1, y)
        write(string.rep(" ", 40))
        term.setCursorPos(1, y)
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
    term.setTextColor(colors.lime)
    print(name .. " disk created!")
    print()
end


---Deletes all files except the 'get' script
---from the disk.
---@param silent? boolean Will not print confirmation if true
local function cleanDisk(silent)
    local fileList = fs.list("/disk")
    for _, file in ipairs(fileList) do
        if file ~= "get" then
            fs.delete("/disk/" .. file)
        end
    end
    if not silent then
        term.setTextColor(colors.orange)
        print()
        print("Deleted all files on disk")
        print()
    end
end


---Cleans and downloads all scripts required to
---create a specific disk.
---@param diskData Script[]
local function createDisk(diskData)
    print()
    writeProgress("Creating Disk", 0, #diskData)
    -- A disk should have ONLY the files created
    -- by this function.
    cleanDisk(true)
    for i, script in ipairs(diskData) do
        local content = getScriptFile(script)
        if string.find(script.fileName, "install") then
           script.fileName = "install"
        end
        writeFile("/disk/" .. script.fileName, content)
        writeProgress("Creating Disk", i, #diskData)
    end
end

local function printHelp()
    print()
    term.setTextColor(colors.purple)
    print("Usage:")
    term.setTextColor(colors.yellow)
    print("  (WARNING: All file ops overwrite existing files)")
    print()
    term.setTextColor(colors.lightGray)
    print("  Formats a disk to a specific type (ex: master)")
    term.setTextColor(colors.orange)
    write("    get ")
    term.setTextColor(colors.cyan)
    write("disk")
    print("\n")
    term.setTextColor(colors.lightGray)
    print("  Deletes all files on disk, EXCEPT 'get'")
    term.setTextColor(colors.orange)
    write("    get ")
    term.setTextColor(colors.cyan)
    write("clean")
    print("\n")
    term.setTextColor(colors.lightGray)
    print("  Downloads script to disk")
    term.setTextColor(colors.orange)
    write("    get ")
    term.setTextColor(colors.cyan)
    write("<script_name>")
    print("\n")
    term.setTextColor(colors.lightGray)
    print("  Downloads script to disk and computer")
    term.setTextColor(colors.orange)
    write("    get ")
    term.setTextColor(colors.cyan)
    write("l <script_name>")
    print()
    print()
end


local function promptDisk()
::restart::
    term.clear()
    term.setCursorPos(1, 1)
    print()
    term.setTextColor(colors.yellow)
    print("Format Disk")
    print()
    term.setTextColor(colors.lightGray)
    write("  1. ")
    term.setTextColor(colors.white)
    write("Leaderboard\n")
    term.setTextColor(colors.lightGray)
    write("  2. ")
    term.setTextColor(colors.white)
    write("Monitor Host\n")
    term.setTextColor(colors.lightGray)
    write("  3. ")
    term.setTextColor(colors.white)
    write("Display\n")
    term.setTextColor(colors.lightGray)
    write("  4. ")
    term.setTextColor(colors.white)
    write("Master\n")
    print()
    term.setTextColor(colors.red)
    write("  5. ")
    term.setTextColor(colors.white)
    write("Exit\n")
    print()
    term.setTextColor(colors.yellow)
    write("> ")
    local choice = tonumber(read())

    if not choice or choice > 5 or choice < 1 then
        term.setTextColor(colors.red)
        print("invalid choice; try again!")
        print()
        term.setTextColor(colors.lightGray)
        print("Enter to continue...")
        read()
        goto restart
    end

    ---@type Script[]
    local info = {}
    local label = ""
    local name = ""

    if choice == 1 then
        info = diskMap.leaderboard.scripts
        label = "Setup Leaderboard v1.0"
        name = "Leaderboard"
    elseif choice == 2 then
        info = diskMap.monhost.scripts
        label = "Setup Monitor Host v1.0"
        name = "Monitor Host"
    elseif choice == 3 then
        info = diskMap.display.scripts
        label = "Setup Display v1.0"
        name = "Display"
    elseif choice == 4 then
        info = diskMap.master.scripts
        label = "Master Disk v1.0"
        name = "Master"
    else
        return
    end

    createDisk(info)
    finalizeDisk(label, name)

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


if #args > 1 then
    local flag = arg1
    local scriptName = arg2

    if flag ~= "l" or not scriptName then
        printHelp()
        return
    end

    local script = scriptMap[scriptName]
    if not script then
        print("'"..scriptName.."' could not be found")
        return
    end

    print()
    term.setTextColor(colors.orange)
    write(" Getting: ")
    term.setTextColor(colors.cyan)
    write(scriptName)
    print()

    local content = getScriptFile(script)
    writeFile("/disk/" .. script.fileName, content)
    writeFile(script.fileName, content)

    term.setTextColor(colors.orange)
    write("Saved To: ")
    term.setTextColor(colors.lime)
    write("/disk/" .. script.fileName)
    print()
    term.setTextColor(colors.orange)
    write("Saved To: ")
    term.setTextColor(colors.lime)
    write("/" .. script.fileName)
    print()
    print()
    return
end


local scriptName = arg1
local script = scriptMap[scriptName]
if not script then
    print("'"..scriptName.."' could not be found")
    return
end

print()
term.setTextColor(colors.orange)
write(" Getting: ")
term.setTextColor(colors.cyan)
write(scriptName)
print()
local content = getScriptFile(script)
writeFile("/disk/" .. script.fileName, content)
term.setTextColor(colors.orange)
write("Saved To: ")
term.setTextColor(colors.lime)
write("/disk/" .. script.fileName)
print()
print()
