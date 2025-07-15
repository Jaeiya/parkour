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
    get          = "LYJdFKns",
    timer        = "t3ka7Qfc",
    xtimer       = "Knhfg3fM",
    setuptimer   = "YHxwpyMa",
    monhost      = "UFStnxDa",
    xmonhost     = "xN6qzppK",
    setupmonhost = "ywQ78fsZ",
    board        = "9eU7yHT7",
    boarddata    = "2SuQAVdT",
    utils        = "FjGC63m3",
}

local scriptNameMap = {
    get          = "get",
    timer        = "timer",
    xtimer       = "xtimer",
    setuptimer   = "setuptimer",
    monhost      = "monhost",
    xmonhost     = "xmonhost",
    setupmonhost = "setupmonhost",
    board        = "board",
    boarddata    = "board_data",
    utils        = "utils",
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
    else
        print("command failed to download file")
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

    downloadScript(code, scriptName)

    -- Overwrite existing file
    if fs.exists(rootPath) then
        fs.delete(rootPath)
    end

    fs.copy("/disk/" .. scriptNameMap[scriptName], rootPath)
    print("Updated '" .. scriptName .. "' on Computer")

else
    local scriptName = args[1]

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
end


