
local utils = {}
utils.splitString = function(str)
    local result = {}
    for word in str:gmatch("%S+") do
        table.insert(result, word)
    end
    return result
end


utils.writeFile = function(filepath, text)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end

utils.getTimerStr = function(milliseconds)
    local ticks   = math.floor(milliseconds / 50)
    local seconds = math.floor(milliseconds / 1000)
    local minutes = math.floor(seconds / 60)
    local hours   = math.floor(minutes / 60)


    local str = string.format(
        "%02d:%02d:%02d.%02d",
        hours   % 60,
        minutes % 60,
        seconds % 60,
        ticks   % 20
    )
    return str
end


return utils
