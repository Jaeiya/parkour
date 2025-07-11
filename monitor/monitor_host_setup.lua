local monHostPath = "disk/monhost"
local xmonHostPath = "disk/xmonhost"

local function writeFile(filepath, text)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end

if not fs.exists(monHostPath) then
    error("missing monhost script")
end

if not fs.exists(xmonHostPath) then
    error("missing xmonhost host script")
end

print()
print("Enter monitor host name")
write("> ")
local hostname = read()

print()
print("Enter Constellation Protocol")
write("> ")
local protocol = read()


-- All file operations below, will overwrite
-- any existing files.

writeFile("hostname.txt", hostname)
writeFile("protocol.txt", protocol)

local f = fs.open(monHostPath, "r")
writeFile("/monhost", f.readAll())
f.close()

f = fs.open(xmonHostPath, "r")
writeFile("/startup", f.readAll())
f.close()

