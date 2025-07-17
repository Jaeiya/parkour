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
    get            = "LYJdFKns",

    boardinstaller = "YHxwpyMa",
    board          = "9eU7yHT7",
    boardlib       = "2SuQAVdT",
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
    boardstartup   = "board_startup",
    boardtimer     = "board_timer",

    monhostinstaller = "install_monhost",
    monhoststartup   = "monhost_startup",
    monhost          = "monhost",

    display          = "display",
    displayinstaller = "install_display",

    utils          = "utils",
    detectplayer   = "detect_player"
}


local function getScript(code, scriptName)
    local diskPath = "/disk/" .. scriptNameMap[scriptName]

    -- Overwrite existing file
    if fs.exists(diskPath) then
        fs.delete(diskPath)
    end

    local success = shell.run(
        "pastebin get " .. code .. " " .. diskPath
    )

    if success then
        print("Updated '" .. scriptName .. "' on Disk")
        return true
    else
        print("command failed to download file")
        return false
    end
end


local function finalizeDisk(label, name)
    local d = peripheral.find("drive")
    if d then
        d.setDiskLabel(label)
    end
    term.setTextColor(colors.lime)
    print(name .. " disk created!")
    if fs.exists("/disk/get") then
        fs.delete("/disk/get")
    end
end


local function createDisplayDisk()
    getScript(scriptCodes.display,          "display")
    getScript(scriptCodes.displayinstaller, "displayinstaller")
    getScript(scriptCodes.utils,            "utils")
end


local function createLeaderboardDisk()
    getScript(scriptCodes.board,          "board")
    getScript(scriptCodes.boardlib,       "boardlib")
    getScript(scriptCodes.boardinstaller, "boardinstaller")
    getScript(scriptCodes.boardstartup,   "boardstartup")
    getScript(scriptCodes.boardtimer,     "boardtimer")
    getScript(scriptCodes.utils,          "utils")
    getScript(scriptCodes.detectplayer,   "detectplayer")
end


local function createMonHostDisk()
    getScript(scriptCodes.monhost,          "monhost")
    getScript(scriptCodes.monhoststartup,   "monhoststartup")
    getScript(scriptCodes.monhostinstaller, "monhostinstaller")
    getScript(scriptCodes.utils,            "utils")
end


local args = {...}

if not args[1] then
    print("Get overwrites an existing script with the one specified.")
    print()
    print("Usage: get <flag> <script_name>")
    return
end

local scriptName = args[1]

if #args > 1 then
    local flag = args[1]
    scriptName = args[2]

    if flag ~= "l" or not scriptName then
       print("Usage: get <flag> <script_name>")
       return
    end

    if not scriptNameMap[scriptName] then
        print("'" .. scriptName .. "' could not be found")
        return
    end

    local rootPath = "/" .. scriptNameMap[scriptName]

    local code = scriptCodes[scriptName]
    if not code then
        print("'"..scriptName.."' could not be found")
        return
    end

    local success = getScript(code, scriptName)
    if not success then return end

    -- Overwrite existing file
    if fs.exists(rootPath) then
        fs.delete(rootPath)
    end

    fs.copy("/disk/" .. scriptNameMap[scriptName], rootPath)
    print("Updated '" .. scriptName .. "' on Computer")

elseif scriptName == "display_disk" then
    createDisplayDisk()
    finalizeDisk("Setup Display", "Display")

elseif scriptName == "leaderboard_disk" then
    createLeaderboardDisk()
    finalizeDisk("Setup Leaderboard", "Leaderboard")

elseif scriptName == "monhost_disk" then
    createMonHostDisk()
    finalizeDisk("Display Setup", "Display")

elseif scriptName == "all" then
    for key, val in pairs(scriptCodes) do
        getScript(val, key)
    end

else
    local code = scriptCodes[scriptName]
    if not code then
        print("'"..scriptName.."' could not be found")
        return
    end
    getScript(code, scriptName)
end


