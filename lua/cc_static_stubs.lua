---@diagnostic disable


---Specifically for fs.open()
---@class FileHandle
local FileHandle = {}

---Reads a line from the file.
---@return string|nil line
function FileHandle.readLine() end

---Reads all remaining content from the file.
---@return string content
function FileHandle.readAll() end

---Writes text to the file.
---@param text string
function FileHandle.write(text) end

---Writes text to the file followed by a newline.
---@param text string
function FileHandle.writeLine(text) end

---Closes the file.
function FileHandle.close() end



---Specifically for http.get()
---@class HTTPResponse
local HTTPResponse = {}

---Reads a line of the response body.
---@return string|nil line The next line, or nil if at the end.
function HTTPResponse.readLine() end

---Reads the entire response body as a string.
---@return string|nil body The full response body, or nil if already read.
function HTTPResponse.readAll() end

---Closes the HTTP connection.
function HTTPResponse.close() end



---Used for passing messages between modules
---@class MessageEvent
---@field action string The action that should be taken by the receiver
---@field payload? any Any data that is pertinent to the action


---@alias Side 'right'|'left'|'top'|'bottom'|'front'|'back'
