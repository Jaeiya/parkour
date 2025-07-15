
if not fs.exists("/disk/utils") then
    term.setTextColor(colors.red)
    print("missing utils file")
end

if not fs.exists("/disk/display") then
    term.setTextColor(colors.red)
    print("missing display file")
end

fs.copy("/disk/display", "/startup")
fs.copy("/disk/utils", "/utils")

term.setTextColor(colors.lime)
print("Install Successful! Restart Computer.")
