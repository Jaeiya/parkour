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

    utils          = "FjGC63m3",
    display        = "uCHiLgtd",
    detectplayer   = "GnQkWuaX"
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

    utils          = "utils",
    display        = "display",
    detectplayer   = "detect_player"
}

local function downloadScript(code, scriptName)
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

local args = {...}

if not args[1] then
    print("Get overwrites an existing script with the one specified.")
    print()
    print("Usage: get <flag> <script_name>")
    return
end

if #args > 1 then
    local flag       = args[1]
    local scriptName = args[2]

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

    local success = downloadScript(code, scriptName)
    if not success then
        return
    end

    -- Overwrite existing file
    if fs.exists(rootPath) then
        fs.delete(rootPath)
    end

    fs.copy("/disk/" .. scriptNameMap[scriptName], rootPath)
    print("Updated '" .. scriptName .. "' on Computer")
    return
end

local scriptName = args[1]

if scriptName == "display_disk" then
    downloadScript(scriptCodes.display, "display")
    downloadScript(scriptCodes.utils,   "utils")
    term.setTextColor(colors.lime)
    shell.run("rename", "/disk/" .. scriptNameMap.display, "/disk/run")
    local d = peripheral.find("drive")
    if d then
        d.setDiskLabel("Display Setup")
    end
    print("Display disk created!")
    if fs.exists("/disk/get") then
        fs.delete("/disk/get")
    end
    return
end

if scriptName == "leaderboard_disk" then
    downloadScript(scriptCodes.board,          "board")
    downloadScript(scriptCodes.boardlib,       "boardlib")
    downloadScript(scriptCodes.boardinstaller, "boardinstaller")
    downloadScript(scriptCodes.boardstartup,   "boardstartup")
    downloadScript(scriptCodes.boardtimer,     "boardtimer")
    downloadScript(scriptCodes.utils,          "utils")
    downloadScript(scriptCodes.detectplayer,   "detectplayer")
    term.setTextColor(colors.lime)
    local d = peripheral.find("drive")
    if d then
        d.setDiskLabel("Setup Leaderboard")
    end
    print("Leaderboard disk created!")
    if fs.exists("/disk/get") then
        fs.delete("/disk/get")
    end
    return
end

if scriptName == "monhost_disk" then
    downloadScript(scriptCodes.monhost,          "monhost")
    downloadScript(scriptCodes.monhoststartup,   "monhoststartup")
    downloadScript(scriptCodes.monhostinstaller, "monhostinstaller")
    term.setTextColor(colors.lime)
    local d = peripheral.find("drive")
    if d then
        d.setDiskLabel("Setup Monitor Host")
    end
    print("Leaderboard disk created!")
    if fs.exists("/disk/get") then
        fs.delete("/disk/get")
    end
    return
end

if scriptName == "all" then
    for key, val in pairs(scriptCodes) do
        downloadScript(val, key)
    end
    return
end

local code = scriptCodes[scriptName]
if not code then
    print("'"..scriptName.."' could not be found")
    return
end

downloadScript(code, scriptName)


