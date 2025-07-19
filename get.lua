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

if args[1] == "disk" then
    return promptDisk()
end

if args[1] == "clean" then
    return cleanDisk()
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


