## `_statboardstartup`

The startup script for the stat board. It executes all necessary scripts for the stat
board when the computer starts up.

## `statboardinstaller`

Installs all the necessary statboard scripts onto the computer. On first installation,
it will prompt for necessary config information. Any subsequent installs or updates
to the scripts, will result in loading the existing configuration unless its manually
deleted.

## `statboard`

Handles all rendering of player stats to the connected monitor. Listens on a specific
channel to receive player stats from the `leaderboard`. It does **NOT** store any data
itself.

## `statboardredstone`

This handles any redstone signal sent to the computer, however it assumes that a
pressure plate is placed in front of the stat board, which would be just in front of
a player detector. That player detector will be used to display that specific players
stats when a player steps on the pressure plate.

If the redstone trigger (pressure plate) is not placed within the vicinity of the connected
player detector, it will not work as intended, as the player will not be found.

## `statboardui`

This is the user interface script for the statboard. Allows on-the-fly update
of the host name and protocol, from the computer terminal.
