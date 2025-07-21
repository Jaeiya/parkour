
local utils = require("utils")

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

