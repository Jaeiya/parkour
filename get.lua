--
-- Gets or updates known scripts on a floppy disk
--
-- This removes the need to constantly be calling the
-- pastebin function, with a code, every time I need
-- to update a script.
--
-- This also facilitates creating multiple setup floppy
-- disks very quickly, if needed.
--

local scriptCodes = {
    get            = "XZBmRq0B",

    boardinstaller = "YHxwpyMa",
    board          = "9eU7yHT7",
    boardlib       = "2SuQAVdT",
    boardredstone  = "LZFAu3Kx",
    boardui        = "VnanGgbh",
    boardstartup   = "Knhfg3fM",
    boardtimer     = "t3ka7Qfc",

    monhostinstaller = "ywQ78fsZ",
    monhoststartup   = "xN6qzppK",
    monhost          = "UFStnxDa",

    display          = "uCHiLgtd",
    displayinstaller = "cMiyZkQv",

    utils         = "FjGC63m3",
    detectplayer  = "GnQkWuaX"
}

local scriptNameMap = {
    get            = "get",

    boardinstaller = "install_board",
    board          = "board",
    boardlib       = "board_lib",
    boardredstone  = "board_redstone",
    boardstartup   = "board_startup",
    boardtimer     = "board_timer",
    boardui        = "board_ui",

    monhostinstaller = "install_monhost",
    monhoststartup   = "monhost_startup",
    monhost          = "monhost",

    display          = "display",
    displayinstaller = "install_display",

    utils          = "utils",
    detectplayer   = "detect_player"
}


local function getScript(code)
    local req = http.get("https://pastebin.com/raw/" .. code)
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
    -- Creates new line when progress is finished
    if math.floor(step) >= maxBarSize then
        print()
    end
end


local function writeFile(filepath, text)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end


local function finalizeDisk(label, name)
    print()
    local d = peripheral.find("drive")
    if d then
        d.setDiskLabel(label)
    end
    term.setTextColor(colors.lime)
    print(name .. " disk created!")
    print()
end


local function masterDiskInfo()
    local diskInfo = {}
    for key, val in pairs(scriptCodes) do
        diskInfo[#diskInfo+1] = {
            code = val,
            fileName = scriptNameMap[key]
        }
    end
    return diskInfo
end


local function leaderboardDiskInfo()
    local diskInfo = {
        { code = scriptCodes.board,          fileName = scriptNameMap.board },
        { code = scriptCodes.boardlib,       fileName = scriptNameMap.boardlib },
        { code = scriptCodes.boardui,        fileName = scriptNameMap.boardui },
        { code = scriptCodes.boardredstone,  fileName = scriptNameMap.boardredstone },
        { code = scriptCodes.boardinstaller, fileName = scriptNameMap.boardinstaller },
        { code = scriptCodes.boardstartup,   fileName = scriptNameMap.boardstartup },
        { code = scriptCodes.boardtimer,     fileName = scriptNameMap.boardtimer },
        { code = scriptCodes.utils,          fileName = scriptNameMap.utils },
        { code = scriptCodes.detectplayer,   fileName = scriptNameMap.detectplayer },
    }
    return diskInfo
end


local function monhostDiskInfo()
    return {
        { code = scriptCodes.monhost,          fileName = scriptNameMap.monhost },
        { code = scriptCodes.monhoststartup,   fileName = scriptNameMap.monhoststartup },
        { code = scriptCodes.monhostinstaller, fileName = scriptNameMap.monhostinstaller },
        { code = scriptCodes.utils,            fileName = scriptNameMap.utils },
    }
end


local function displayDiskInfo()
    return {
        { code = scriptCodes.display,          fileName = scriptNameMap.display},
        { code = scriptCodes.displayinstaller, fileName = scriptNameMap.displayinstaller},
        { code = scriptCodes.utils,            fileName = scriptNameMap.utils},
    }
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


local function createDisk(diskInfo)
    print()
    writeProgress("Creating Disk", 0, #diskInfo)
    -- A disk should have ONLY the files created
    -- by this function.
    cleanDisk(true)
    for i, item in ipairs(diskInfo) do
        local content = getScript(item.code)
        writeFile("/disk/" .. item.fileName, content)
        writeProgress("Creating Disk", i, #diskInfo)
    end
end

local function promptDisk()
::restart::
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
    print(" Disk Selection")
    print()
    print("   1. Leaderboard")
    print("   2. Monitor Host")
    print("   3. Display")
    print("   4. Master")
    print()
    term.setTextColor(colors.red)
    print("   5. Exit")
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
        info = leaderboardDiskInfo()
        label = "Setup Leaderboard"
        name = "Leaderboard"
    elseif choice == 2 then
        info = monhostDiskInfo()
        label = "Setup Monitor Host"
        name = "Monitor Host"
    elseif choice == 3 then
        info = displayDiskInfo()
        label = "Setup Display"
        name = "Display"
    elseif choice == 4 then
        info = masterDiskInfo()
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
    print()
    term.setTextColor(colors.purple)
    print("Usage:")
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
    return
end


if #args > 1 then
    local flag = args[1]
    local scriptName = args[2]

    if flag ~= "l" or not scriptName then
       print("Usage: get <flag> <script_name>")
       return
    end

    local code = scriptCodes[scriptName]
    if not code then
        print("'"..scriptName.."' could not be found")
        return
    end

    if not scriptNameMap[scriptName] then
        print("'" .. scriptName .. "' could not be found")
        return
    end

    print()
    term.setTextColor(colors.orange)
    write(" Getting: ")
    term.setTextColor(colors.cyan)
    write(scriptName)
    print()

    local content = getScript(code)
    writeFile("/disk/" .. scriptNameMap[scriptName], content)
    writeFile(scriptNameMap[scriptName], content)

    term.setTextColor(colors.orange)
    write("Saved To: ")
    term.setTextColor(colors.lime)
    write("/disk/" .. scriptNameMap[scriptName])
    print()
    term.setTextColor(colors.orange)
    write("Saved To: ")
    term.setTextColor(colors.lime)
    write("/" .. scriptNameMap[scriptName])
    print()
    print()
    return
end

if args[1] == "disk" then
    return promptDisk()
end

if args[1] == "clean" then
    return cleanDisk()
end

local scriptName = args[1]
local code = scriptCodes[scriptName]
if not code then
    print("'"..scriptName.."' could not be found")
    return
end

print()
term.setTextColor(colors.orange)
write(" Getting: ")
term.setTextColor(colors.cyan)
write(scriptName)
print()
local content = getScript(code)
writeFile("/disk/" .. scriptNameMap[scriptName], content)
term.setTextColor(colors.orange)
write("Saved To: ")
term.setTextColor(colors.lime)
write("/disk/" .. scriptNameMap[scriptName])
print()
print()


