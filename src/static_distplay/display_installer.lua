
local utils = require("utils")


print()
local modem = utils.getModem()
if not modem then
    utils.printColor(
        ";red;Installation Aborted\n" ..

        ";org;Attach a ;lim;wired modem ;org;to this computer and connect it " ..
        "(with ;lim;networking cable;org;) to another ;lim;modem;org;, attached to an " ..
        ";lim;advanced monitor\n\n" ..

        ";org;Make sure you ;lim;right click ;org;the modems to activate them, once you've " ..
        "finished connecting them\n\n"
    )
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
    utils.printColor(
        ";red;Installation Aborted\n" ..

        ";org;Attach an ;lim;advanced monitor ;org;to the modem on the other side of " ..
        "the networking cable.\n\n" ..

        "Make sure both modems are ;lim;right clicked;org; and glowing red.\n\n"
    )
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

