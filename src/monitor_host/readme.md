## `monhost`

Currently used to display the timer and nothing else. It uses a unique protocol
to host itself, so that multiple monitor hosts can be set up on the same course
and show the same time.

I may end up calling this the `timer_display` at some point, if I add more timer-
specific functionality.

## `monhostinstaller`

Installs the monitor host to a computer. Will prompt for configuration information,
but only if there is no existing configuration file found.

## `monhostui`

This is the user interface script for the monitor host. Allows on-the-fly update
of the host name and protocol, from the computer terminal.
