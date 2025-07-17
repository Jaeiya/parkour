
local utils = require("utils")
local paths = {
    display = "/disk/display",
    utils = "/disk/utils",
}

if not fs.exists(paths.display) then
    error("missing display script")
end

if not fs.exists(paths.utils) then
    error("missing utils script")
end

utils.writeFile("startup", 'shell.run("display")')



-- All files operations below will overwrite existing
-- files.

local f = fs.open(paths.display, "r")
utils.writeFile("display", f.readAll())
f.close()

f = fs.open(paths.utils, "r")
utils.writeFile("utils", f.readAll())
f.close()

os.reboot()

