
local utils = require("utils")


print()
local modem = utils.getModem()
if not modem then
    printError("Installation Aborted")
    term.setTextColor(colors.orange)
    write("Attach a ")
    term.setTextColor(colors.lime)
    write("wired modem ")
    term.setTextColor(colors.orange)
    write("to this computer and connect it (with ")
    term.setTextColor(colors.lime)
    write("networking cable")
    term.setTextColor(colors.orange)
    write(") to another modem, attached to an ")
    term.setTextColor(colors.lime)
    write("advanced monitor\n\n")
    term.setTextColor(colors.orange)
    write("Make sure you ")
    term.setTextColor(colors.lime)
    write("right click ")
    term.setTextColor(colors.orange)
    write("the modems to activate them, once you've finished connecting them.\n\n")
    return
end


---@type Monitor|nil
local mon = nil

-- Find the monitor connected through the modem
for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "monitor" then
        mon = peripheral.wrap(name)
        break
    end
end

if not mon then
    printError("Installation Aborted")
    term.setTextColor(colors.orange)
    write("Attach an ")
    term.setTextColor(colors.lime)
    write("advanced monitor ")
    term.setTextColor(colors.orange)
    write("to the modem on the other side of the networking cable.\n\n")
    write("Make sure you ")
    term.setTextColor(colors.lime)
    write("right clicked ")
    term.setTextColor(colors.orange)
    write("the modem on the other side.\n\n")
    return
end


---@class DisplayPaths
---@field display string
---@field utils string

---@type DisplayPaths
local paths = {
    display = "disk/display",
    utils = "disk/utils",
}

---We manually write the startup directly to disk
---because it's too simple to require its own file.
utils.writeFile("startup", 'term.clear()\nterm.setCursorPos(1, 1)\nshell.run("display")')

for _, path in pairs(paths) do
    local f = fs.open(path, "r")
    if not f then
        error("could not find install file: " .. path)
    end

    local installPath = string.gsub(path, "disk/", "")
    utils.writeFile(installPath, f.readAll())

    f.close()
end


os.reboot()

