---@diagnostic disable



---@class FileHandle
local FileHandle = {}

---Reads a line from the file.
---@return string|nil line
function FileHandle.readLine() end

---Reads all remaining content from the file.
---@return string|nil content
function FileHandle.readAll() end

---Writes text to the file.
---@param text string
function FileHandle.write(text) end

---Writes text to the file followed by a newline.
---@param text string
function FileHandle.writeLine(text) end

---Closes the file.
function FileHandle.close() end
