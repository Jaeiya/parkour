# CopyDisk

This script was born out of a need to create disks on the fly, especially if two or more
people need to update computers on the map. At a very high level, all this script
does is copy the contents of its source disk into its destination disk, then ejecting
it to the player.

One of the caveats of this script, is that it doesn't allow for automatic updates. If
a disk gets updated, then someone has to manually use the `get` script and update the
source disk.

### Automated Disk Updates

As of version `2.0` this script now supports updates, but not from itself, from a
networked computer designed to send the files to it.

# File Breakdown

All files are documented below this line. The following descriptions are a detailed
paraphrasing of the purpose and priority of each individual script, as well as how
they are connected either to each other or external scripts. Some of the information
may be redundant for certain scripts, as they may have been described in the above
summary.

## `copydisk`

Copies the contents of its source disk, to a detected destination disk. It has
various protection mechanisms so that if the player doesn't insert a valid source
disk or inserts a full destination disk, then it throws an error and tells the
player what's wrong and how to fix it.

Lastly, it listens on the network for update requests. If an update is imminent
then it tells the player to avoid using it until the update is finished.

## `copydiskinstaller`

Installs the CopyDisk scripts to the computer and checks to make sure that all
necessary peripherals are attached before completing the install.
