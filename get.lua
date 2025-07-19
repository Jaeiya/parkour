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

if not fs.exists("/disk/get") then
    print()
    term.setTextColor(colors.red)
    print("Invalid Install Location")
    print()
    term.setTextColor(colors.orange)
    print("Please import or copy me to a disk")
    print()
    return
end

local scriptMap = {
    get            = { code = "XZBmRq0B", fileName = "get" },

    boardinstaller = { code = "YHxwpyMa", fileName = "install_board" },
    board          = { code = "9eU7yHT7", fileName = "board"},
    boardlib       = { code = "2SuQAVdT", fileName = "board_lib" },
    boardredstone  = { code = "LZFAu3Kx", fileName = "board_redstone" },
    boardui        = { code = "VnanGgbh", fileName = "board_ui" },
    boardstartup   = { code = "Knhfg3fM", fileName = "board_startup" },
    boardtimer     = { code = "t3ka7Qfc", fileName = "board_timer" },

    monhostinstaller = { code = "ywQ78fsZ", fileName = "install_monhost" },
    monhoststartup   = { code = "xN6qzppK", fileName = "monhost_startup" },
    monhost          = { code = "UFStnxDa", fileName = "monhost" },

    display          = { code = "uCHiLgtd", fileName = "display" },
    displayinstaller = { code = "cMiyZkQv", fileName = "install_display" },

    utils         = { code = "FjGC63m3", fileName = "utils" },
    detectplayer  = { code = "GnQkWuaX", fileName = "detect_player" },
}

local diskMap = {
    master = {
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
    },
    leaderboard = {
        scriptMap.board,
        scriptMap.boardlib,
        scriptMap.boardui,
        scriptMap.boardredstone,
        scriptMap.boardinstaller,
        scriptMap.boardstartup,
        scriptMap.boardtimer,
        scriptMap.utils,
        scriptMap.detectplayer,
    },
    monhost = {
        scriptMap.monhost,
        scriptMap.monhoststartup,
        scriptMap.monhostinstaller,
        scriptMap.utils,
    },
    display = {
        scriptMap.display,
        scriptMap.displayinstaller,
        scriptMap.utils,
    },

}


local function getScriptFile(script)
    local req = http.get("https://pastebin.com/raw/" .. script.code)
    if not req then
        error("failed to get script")
    end
    return req.readAll()
end


local function writeProgress(text, step, limit)
    if step > limit then
        error("step should never be greater than max")
    end
    local _, y = term.getCursorPos()
    local maxBarSize = 20
    step = (maxBarSize / limit) * step
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


local function writeFile(filepath, text)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end


local function finalizeDisk(label, name)
    local d = peripheral.find("drive")
    if d then
        d.setDiskLabel(label)
    end
    term.setTextColor(colors.lime)
    print(name .. " disk created!")
    print()
end


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


local function createDisk(diskData)
    print()
    writeProgress("Creating Disk", 0, #diskData)
    -- A disk should have ONLY the files created
    -- by this function.
    cleanDisk(true)
    for i, script in ipairs(diskData) do
        local content = getScriptFile(script)
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
    print("  Select disk formatting (ex: master, display)")
    term.setTextColor(colors.orange)
    write("    get ")
    term.setTextColor(colors.cyan)
    write("disk")
    print("\n")
    term.setTextColor(colors.lightGray)
    print("  Deletes all files on disk.")
    term.setTextColor(colors.orange)
    write("    get ")
    term.setTextColor(colors.cyan)
    write("clean")
    print("\n")
    term.setTextColor(colors.lightGray)
    print("  Downloads a script by name to disk")
    term.setTextColor(colors.orange)
    write("    get ")
    term.setTextColor(colors.cyan)
    write("<script_name>")
    print("\n")
    term.setTextColor(colors.lightGray)
    print("  Downloads script by name to disk and computer")
    term.setTextColor(colors.orange)
    write("    get ")
    term.setTextColor(colors.cyan)
    write("l <script_name>")
    print()
    print()
end


local function promptDisk()
::restart::
    print()
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
    local choice = read()
    choice = tonumber(choice)

    if not choice or choice > 5 or choice < 1 then
        term.setTextColor(colors.red)
        print("invalid choice; try again!")
        print()
        term.setTextColor(colors.lightGray)
        print("Enter to continue...")
        read()
        goto restart
    end

    local info = {}
    local label = ""
    local name = ""

    if choice == 1 then
        info = diskMap.leaderboard
        label = "Setup Leaderboard"
        name = "Leaderboard"
    elseif choice == 2 then
        info = diskMap.monhost
        label = "Setup Monitor Host"
        name = "Monitor Host"
    elseif choice == 3 then
        info = diskMap.display
        label = "Setup Display"
        name = "Display"
    elseif choice == 4 then
        info = diskMap.master
        label = "Master Disk"
        name = "Master"
    else
        return
    end

    createDisk(info)
    finalizeDisk(label, name)

end



local args = {...}

if not args[1] then
    printHelp()
    return
end


if args[1] == "disk" then
    return promptDisk()
end

if args[1] == "clean" then
    return cleanDisk()
end


if #args > 1 then
    local flag = args[1]
    local scriptName = args[2]

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


local scriptName = tostring(args[1])
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


