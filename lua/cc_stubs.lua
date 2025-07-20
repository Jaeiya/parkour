---@diagnostic disable

---@meta

---The `os` API in CC:Tweaked provides various system-related functions such as time, sleep, shutdown, reboot, and event queueing.
os = {}

---Queues an event for the computer to handle.
---@param event string The event name.
---@param ... any Additional arguments for the event.
function os.queueEvent(event, ...) end

---Pulls an event from the event queue, optionally filtering by event names and with an optional timeout.
---@param filter? string|table<string> Event name or list of event names to filter on.
---@param timeout? number Timeout in seconds to wait for an event.
---@return string eventName The event name.
---@return any ... Additional event parameters.
function os.pullEvent(filter) end

---Pulls an event but does not throw an error on `terminate` event (CTRL+T).
---@param filter? string|table<string> Event name or list of event names to filter on.
---@param timeout? number Timeout in seconds to wait for an event.
---@return string eventName The event name.
---@return any ... Additional event parameters.
function os.pullEventRaw(filter) end

---Starts a timer that queues a `timer` event after the given delay in seconds.
---Returns the timer ID as an integer.
---@param seconds number
---@return integer
function os.startTimer(seconds) end

---Cancels a previously started timer, preventing its event from firing.
---@param timerID integer  # The timer ID returned by os.setTimer().
---@return boolean         # True if the timer was cancelled successfully, false if not found.
function os.cancelTimer(timerID) end

---Pauses execution for a number of seconds.
---@param seconds number Number of seconds to sleep.
function os.sleep(seconds) end

---Returns the uptime of the computer in seconds.
---@return number uptime Time in seconds since the computer started.
function os.uptime() end

---Returns the current time in seconds since the epoch.
---@return number time Current time.
function os.time() end

---Returns the current time in a formatted table.
---@return table timeTable Table with fields year, month, day, hour, min, sec.
function os.date() end

---Shuts down the computer.
function os.shutdown() end

---Reboots the computer.
function os.reboot() end

---Returns the current computer ID.
---@return number id
function os.getComputerID() end

---Returns the label of the computer or nil if none set.
---@return string|nil label
function os.getComputerLabel() end

---Sets the label of the computer.
---@param label string
function os.setComputerLabel(label) end

---Loads and runs a program file.
---@param path string Path to the program.
---@return boolean success
---@return string|nil errorMessage
function os.run(path) end



---@class fs
fs = {}

---Returns whether a file or folder exists at the given path.
---@param path string
---@return boolean exists
function fs.exists(path) end

---Returns whether the given path is a directory.
---@param path string
---@return boolean isDir
function fs.isDir(path) end

---Returns whether the given path is read-only.
---@param path string
---@return boolean readOnly
function fs.isReadOnly(path) end

---Returns the size of the file at the given path, in bytes.
---@param path string
---@return integer size
function fs.getSize(path) end

---Returns the total size used by the file or directory at the given path.
---@param path string
---@return integer size
function fs.getFreeSpace(path) end

---Returns a list of files in the given directory.
---@param path string
---@return string[] files
function fs.list(path) end

---Makes a new directory at the given path.
---@param path string
function fs.makeDir(path) end

---Moves a file or directory from one path to another.
---@param from string
---@param to string
function fs.move(from, to) end

---Copies a file or directory from one path to another.
---@param from string
---@param to string
function fs.copy(from, to) end

---Deletes the file or directory at the given path.
---@param path string
function fs.delete(path) end


---Opens a file in read, write, or append mode.
---@param path string
---@param mode "r"|"w"|"a"
---@return FileHandle|nil handle
function fs.open(path, mode) end

---Returns the drive’s mount path for a given path.
---@param path string
---@return string drive
function fs.getDrive(path) end

---Returns the file name component from the path.
---@param path string
---@return string name
function fs.getName(path) end

---Returns the directory component from the path.
---@param path string
---@return string parent
function fs.getDir(path) end

---Combines multiple path components into a single path.
---@vararg string
---@return string path
function fs.combine(...) end

---Returns the file attributes for a file.
---@param path string
---@return table attributes
function fs.attributes(path) end

---Finds all files matching a wildcard path.
---@param wildcard string
---@return string[] matches
function fs.find(wildcard) end

---Returns whether a given path can be edited (not read-only).
---@param path string
---@return boolean canEdit
function fs.isWritable(path) end



---The `peripheral` API allows interaction with attached peripherals on the computer.
peripheral = {}

---Checks if a peripheral is present on the given side.
---@param side string The side to check (e.g., "left", "right", "top", etc.)
---@return boolean present True if a peripheral is present.
function peripheral.isPresent(side) end

---Returns the type of peripheral attached to the given side, or nil if none.
---@param side string The side to check.
---@return string|nil type The peripheral type (e.g., "monitor", "disk_drive").
function peripheral.getType(side) end

---Wraps the peripheral on the given side, returning a proxy table to call its methods.
---@param side string The side to wrap.
---@return table|nil proxy The peripheral proxy or nil if none present.
function peripheral.wrap(side) end

---Returns a list of all sides that have peripherals attached.
---@return string[] sides List of sides with peripherals.
function peripheral.getNames() end

---Returns the type of the peripheral on the given side, same as getType (alias).
---@param side string The side to check.
---@return string|nil type
function peripheral.getType(side) end

---Finds a peripheral by type and returns a table with 0 or more wrapped peripherals.
---@param typeName string The peripheral type to find.
---@return table ...
function peripheral.find(typeName) end



---@class redstone
redstone = {}

---Sets the redstone output on a given side.
---@param side string # The side ("left", "right", "front", "back", "top", "bottom")
---@param power integer|boolean # Power level 0-15 or boolean (true = 15, false = 0)
function redstone.setOutput(side, power) end

---Gets the redstone input from a given side.
---@param side string
---@return integer power # Power level 0-15
function redstone.getInput(side) end

---Sets the bundled redstone output on a given side.
---@param side string
---@param color integer # Color index 0-15
---@param power boolean|integer # true = power 15, false = 0, or integer power 0-15
function redstone.setBundledOutput(side, color, power) end

---Gets the bundled redstone input from a given side.
---@param side string
---@param color integer
---@return boolean powerOn
function redstone.getBundledInput(side, color) end

---Returns a table of all bundled output colors currently powered on a given side.
---@param side string
---@return table<number, boolean> colors
function redstone.getBundledOutput(side) end


---@class rednet
rednet = {}

---Opens a modem on the specified side for rednet communication.
---@param side string # The side the modem is on ("left", "right", etc.)
function rednet.open(side) end

---Closes the modem on the specified side.
---@param side string
function rednet.close(side) end

---Registers the current computer as a host for a given protocol.
---After hosting, other computers can use `rednet.lookup()` to find this computer under that protocol.
---@param protocol string  # The protocol name to host under.
---@param hostname string  # The host name to advertise as.
---@return boolean success # True if hosting succeeded, false if hosting failed (e.g., invalid arguments).
function rednet.host(protocol, hostname) end

---Sends a message to a specific computer ID.
---@param recipient number # Target computer ID
---@param message any # Message to send (any Lua value)
---@param protocol? string|number # Optional protocol identifier
function rednet.send(recipient, message, protocol) end

---Broadcasts a message to all listening computers.
---@param message any
---@param protocol? string|number
function rednet.broadcast(message, protocol) end

---Receives a message, optionally filtered by protocol and with optional timeout.
---@param protocol? string|number
---@param timeout? number # Seconds to wait before returning nil
---@return number senderId # ID of the sender
---@return any message # The received message
---@return string|number protocol # Protocol used
function rednet.receive(protocol, timeout) end

---Looks up the computer ID of a host broadcasting a specific protocol.
---@param protocol string|number
---@return number|nil hostId
function rednet.lookup(protocol) end

---Searches for all hosts broadcasting a specific protocol.
---@param protocol string|number
---@return number[] hostIds
function rednet.lookupAll(protocol) end



---@class http
http = {}

---Checks if the HTTP API is enabled.
---@return boolean enabled
function http.checkURL() end

---Performs an HTTP GET request.
---@param url string
---@return HTTPResponse|nil responseBody
function http.get(url) end

---Performs an HTTP POST request with optional data.
---@param url string
---@param data? string
---@return string|nil responseBody
function http.post(url, data) end

---Performs an HTTP request with a custom method.
---@param url string
---@param postData? string
---@param headers? table<string, string>
---@param method? string # e.g. "GET", "POST", "PUT"
---@return string|nil responseBody
function http.request(url, postData, headers, method) end

---Performs a HEAD request to the given URL.
---@param url string
---@return table|nil headers
function http.head(url) end

---Checks if a URL is permitted (used in advanced HTTP APIs).
---@param url string
---@return boolean permitted
function http.checkURL(url) end---@class term



---@class term
term = {}

---Clears the terminal screen.
function term.clear() end

---Clears the line the cursor is currently on.
function term.clearLine() end

---Gets the current cursor position.
---@return number x
---@return number y
function term.getCursorPos() end

---Sets the cursor position.
---@param x number
---@param y number
function term.setCursorPos(x, y) end

---Gets the terminal size (width and height).
---@return number width
---@return number height
function term.getSize() end

---Writes text to the terminal without a newline.
---@param text string
function term.write(text) end

---Writes text to the terminal with a newline.
---@param text string
function term.println(text) end

---Sets the text color. Accepts either color number or name.
---@param color number|string
function term.setTextColor(color) end

---Gets the current text color.
---@return number|string
function term.getTextColor() end

---Sets the background color. Accepts either color number or name.
---@param color number|string
function term.setBackgroundColor(color) end

---Gets the current background color.
---@return number|string
function term.getBackgroundColor() end

---Scrolls the terminal up by the given number of lines.
---@param lines number
function term.scroll(lines) end

---Returns whether the terminal supports color output.
---@return boolean
function term.isColor() end

---Returns whether the terminal supports color depth (more colors).
---@return boolean
function term.isColorDepth() end



---@class colors
colors = {}

colors.white = 1
colors.orange = 2
colors.magenta = 4
colors.lightBlue = 8
colors.yellow = 16
colors.lime = 32
colors.pink = 64
colors.gray = 128
colors.lightGray = 256
colors.cyan = 512
colors.purple = 1024
colors.blue = 2048
colors.brown = 4096
colors.green = 8192
colors.red = 16384
colors.black = 32768

---Combines multiple colors (bitwise OR).
---@param ... number
---@return number
function colors.combine(...) end

---Checks if a combined color includes a specific color.
---@param combined number
---@param color number
---@return boolean
function colors.test(combined, color) end



---@class parallel
parallel = {}

---Runs multiple functions in parallel, waiting for all to complete.
---@param ... fun() Functions to run in parallel.
function parallel.waitForAll(...) end

---Runs multiple functions in parallel, returning as soon as any one completes.
---@param ... fun() Functions to run in parallel.
function parallel.waitForAny(...) end



---@class shell
shell = {}

---Runs a command as if it were typed into the shell.
---Returns true if the command ran successfully, false otherwise.
---@param ... string  # Arguments to pass to the command (the command itself and its arguments).
---@return boolean    # True if the command succeeded, false otherwise.
function shell.run(...) end

---Returns the current working directory.
---@return string path
function shell.getWorkingDirectory() end

---Changes the current working directory.
---@param path string
---@return boolean success
function shell.setWorkingDirectory(path) end

---Returns a table of all arguments passed to the shell.
---@return string[] args
function shell.getRunningProgramArgs() end

---Returns the name of the currently running program.
---@return string
function shell.getRunningProgram() end

---Combines the given path segments into a single path.
---@param ... string
---@return string path
function shell.resolve(...) end

---Returns the environment variables as a table.
---@return table<string, string> env
function shell.getEnvironment() end



---@class textutils
textutils = {}

---Serializes a Lua value into a string.
---@param value any
---@param pretty? boolean # If true, output is formatted for readability.
---@return string
function textutils.serialize(value, pretty) end

---Deserializes a string into a Lua value.
---@param serialized string
---@return any
function textutils.unserialize(serialized) end

---Converts a string to lower case.
---@param str string
---@return string
function textutils.toLowerCase(str) end

---Converts a string to upper case.
---@param str string
---@return string
function textutils.toUpperCase(str) end

---Wraps a string to a specified width.
---@param text string
---@param width number
---@return string[]
function textutils.wrap(text, width) end

---Formats a number with commas for thousands.
---@param number number
---@return string
function textutils.formatNumber(number) end

---Serializes a Lua table as JSON.
---@param value any
---@return string
function textutils.serializeJSON(value) end

---Deserializes a JSON string into a Lua value.
---@param json string
---@return any
function textutils.unserializeJSON(json) end



---Reads a line of input from the user.
---Can optionally accept a table of valid characters to restrict input,
---and a mask character for password-style input.
---@param valid? string|table<string> Characters allowed (string or table of chars), or nil for any
---@param history? table<string> A table used to provide input history navigation (optional)
---@param complete? fun(text:string):string[] A completion function to suggest possible completions (optional)
---@param mask? string Character to display instead of actual input characters (optional)
---@return string input The entered text
function read(valid, history, complete, mask) end

---Pauses the program for the specified number of seconds.
---@param seconds number Time to sleep in seconds (can be fractional)
function sleep(seconds) end

---Writes text to the standard output without a newline.
---@param text string The text to write
function write(text) end

---Writes text representations of the given arguments to the standard output, separated by tabs, ending with a newline.
---@param ... any Values to print
function print(...) end


return os, peripheral, fs, redstone, rednet, http, term, colors, parallel, shell, textutils, read, sleep, write, print


