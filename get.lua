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
    leaderboard  = "9eU7yHT7",
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
    leaderboard  = "leaderboard",
    utils        = "utils",
}

local function downloadScript(code, scriptName)
    local targetFile = "/disk/" .. scriptNameMap[scriptName]

    if fs.exists(targetFile) then
        fs.delete(targetFile)
    end

    local success = shell.run(
        "pastebin get " .. code .. " " .. targetFile
    )

    if success then
        print(scriptName .. " Updated!")
    else
        print("command failed to download file")
    end
end

local scriptName = ...
if not scriptName then
    print("Usage: get <script_name>")
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

