
local utils = require("utils")

local configFile = "board.cfg"
local config = {
    protocol = "",
    startPos = {
        x = 0,
        y = 0,
        z = 0,
    },
    endPos = {
        x = 0,
        y = 0,
        z = 0,
    },
}
config = utils.loadConfig(configFile, config)

local function promptMonitorProtocol()
    print()
    print("Enter Monitor Protocol")
    print()
    write("> ")
    return utils.read()
end



local choices = {
    function()
        config.startPos = utils.promptCoords("Enter Start Pos")
        utils.saveConfig(configFile, config)
        os.queueEvent("leaderboard", {action = "set_start_pos", payload = config.startPos})
    end,
    function ()
        config.endPos = utils.promptCoords("Enter End Pos")
        utils.saveConfig(configFile, config)
        os.queueEvent("leaderboard", {action = "set_end_pos", payload = config.endPos})
    end,
    function ()
        config.protocol = promptMonitorProtocol()
        utils.saveConfig(configFile, config)
        os.queueEvent("timer", {action = "new_protocol", payload = config.protocol })
    end,
}


return function()
::menu::
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.cyan)
    print("Current Values")
    print()
    term.setTextColor(colors.lightGray)
    write("  start_pos: ")
    term.setTextColor(colors.white)
    print(config.startPos.x .. ", " .. config.startPos.y .. ", " .. config.startPos.z)
    term.setTextColor(colors.lightGray)
    write("    end_pos: ")
    term.setTextColor(colors.white)
    print(config.endPos.x .. ", " .. config.endPos.y .. ", " .. config.endPos.z)
    term.setTextColor(colors.lightGray)
    write("   protocol: ")
    term.setTextColor(colors.white)
    print(config.protocol)
    print()
    print()
    term.setTextColor(colors.orange)
    print("Manage Configuration")
    print()
    term.setTextColor(colors.yellow)
    write(" 1. ")
    term.setTextColor(colors.white)
    print("Set Start Pos")
    term.setTextColor(colors.yellow)
    write(" 2. ")
    term.setTextColor(colors.white)
    print("Set End Pos")
    term.setTextColor(colors.yellow)
    write(" 3. ")
    term.setTextColor(colors.white)
    print("Set Monitor Protocol")
    print()
    write("> ")
    local choice = tonumber(utils.read())

    if not choices[choice] then
        term.setTextColor(colors.red)
        print("invalid choice")
        print()
        term.setTextColor(colors.lightGray)
        print("Enter to continue...")
        read()
        goto menu
    end

    choices[choice]()
    goto menu
end
