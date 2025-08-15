# Disk Updater

Updating scripts while troubleshooting is very easy, but having to go through the
process of updating all disks touched by script updates is tedious. This is where
the Disk Updater comes into play.

The `CopyDisk` script now accepts a request for updates. This means that through
the terminal on the `diskupdater` computer, you can navigate a couple menus to not
only update disks, but discover them on the network if any are added later.

Any computers running `CopyDisk` will be discoverable on the connected network.

# File Breakdown

All files are documented below this line. The following descriptions are a detailed
paraphrasing of the purpose and priority of each individual script, as well as how
they are connected either to each other or external scripts. Some of the information
may be redundant for certain scripts, as they may have been described in the above
summary.

## `diskupdater`

Allows a player, through the terminal, to discover `copydisk` computers that are ready
to receive disk updates. The `get` script can also be updated through the terminal, which
is necessary when a disk requires a version update. When updating a disk through
the terminal, you'll get a progress bar not only in the terminal, but also on the
attached monitor.

Furthermore, if a previously detected `copydisk` computer is no longer available on
the network, an update request will yield an error message letting the player know
that it failed to connect to that computer.
