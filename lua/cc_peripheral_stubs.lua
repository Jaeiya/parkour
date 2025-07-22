---@diagnostic disable


-- Monitor peripheral proxy methods
---@class Monitor
local Monitor = {}

---Clears the monitor screen.
function Monitor.clear() end

---Sets the cursor position.
---@param x number
---@param y number
function Monitor.setCursorPos(x, y) end

---Gets the cursor position.
---@return number x
---@return number y
function Monitor.getCursorPos() end

---Writes text to the monitor.
---@param text string
function Monitor.write(text) end

---Scrolls the monitor up by the given number of lines.
---@param n number
function Monitor.scroll(n) end

---Gets the size of the monitor.
---@return number width
---@return number height
function Monitor.getSize() end

---Sets the text scale (1 to 5).
---@param scale number
function Monitor.setTextScale(scale) end

---Sets the text color.
---@param color number
function Monitor.setTextColor(color) end

---Sets the background color.
---@param color number
function Monitor.setBackgroundColor(color) end

---Clears the line the cursor is currently on.
function Monitor.clearLine() end

---Sets whether the monitor blinks the cursor.
---@param blink boolean
function Monitor.setCursorBlink(blink) end

---Gets whether the monitor cursor blinks.
---@return boolean
function Monitor.getCursorBlink() end


-- Modem peripheral proxy methods
---@class Modem
local Modem = {}

---Opens a channel.
---@param channel number
function Modem.open(channel) end

---Closes a channel.
---@param channel number
function Modem.close(channel) end

---Checks if a channel is open.
---@param channel number
---@return boolean
function Modem.isOpen(channel) end

---Sends a message over a channel.
---@param channel number
---@param replyChannel number
---@param ... any
function Modem.transmit(channel, replyChannel, ...) end

---Returns the modem's local address.
---@return number
function Modem.getName() end

---Checks if the modem is wireless (true) or wired (false).
---@return boolean
function Modem.isWireless() end


---@class PlayerInfo
---@field dimension string
---@field eyeHeight number
---@field pitch number
---@field health number
---@field maxHealth number
---@field airSupply number
---@field respawnPosition number
---@field respawnDimension number
---@field respawnAngle number
---@field yaw number
---@field x integer
---@field y integer
---@field z integer


---@class PlayerDetector
local playerDetector = {}

---Returns information about the player with the given username.
---@param playerName string
---@return PlayerInfo|nil playerInfo
function playerDetector.getPlayerPos(playerName) end

---Returns a list of all online players.
---@return string[] players
function playerDetector.getOnlinePlayers() end

---Returns a list of players within the given range (centered at the player detector peripheral).
---@param range number
---@return string[] players
function playerDetector.getPlayersInRange(range) end

---Returns a list of players within the two defined positions.
---@param posOne { x: number, y: number, z: number }
---@param posTwo { x: number, y: number, z: number }
---@return string[] players
function playerDetector.getPlayersInCoords(posOne, posTwo) end



---@class Drive
local drive = {}

---Checks whether a disk is present in the drive.
---@return boolean
function drive.isDiskPresent() end

---Checks whether the disk is writable.
---@return boolean
function drive.isDiskWritable() end

---Gets the disk's ID if it is present.
---@return integer
function drive.getDiskID() end

---Gets the mount path of the disk.
---@return string
function drive.getMountPath() end

---Gets the disk's label.
---@return string
function drive.getDiskLabel() end

---Sets the disk's label.
---@param label string
---@return boolean
function drive.setDiskLabel(label) end

---Ejects the disk from the drive.
---@return boolean
function drive.ejectDisk() end

---Plays the audio track stored on the inserted music disc.
---@return boolean
function drive.playAudio() end

---Stops playing audio.
---@return boolean
function drive.stopAudio() end

---Checks whether the music disc is currently playing.
---@return boolean
function drive.isAudioPlaying() end
