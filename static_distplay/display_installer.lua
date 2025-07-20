
local utils = require("utils")

---@class DisplayPaths
---@field display string
---@field utils string

---@type DisplayPaths
local paths = {
    display = "disk/display",
    utils = "disk/utils",
}


--
-- All file operations below will overwrite existing files.
--


utils.writeFile("startup", 'shell.run("display")')

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

