## `medalsboard`

Displays the available medals to a display (medals board) with the amount
if lives that each medal represents. So for instance if a medal says 5 lives,
then that means any player who _uses_ 5 lives, will get that medal.

Using less lives to finish a run, results in a better medal. The lives are
communicated to the leaderboard, so that the leaderboard can track how
many lives the player has used and assign the right medal.

_The lives can be configured through the computer terminal, once this script
is active._

Every time the medal lives are updated through the menu in the terminal, the
updated lives are sent to the leaderboard on a specific channel. This channel is
also waited on by the leaderboard when it attempts to retrieve the medal lives
on startup.

## `medalsboardinstaller`

As the name suggests, this file installs the medals board script to the computer.
Upon first installation, the life configuration will be set to defaults. This is
because the `medalsboard` automatically sets default config values when executed
for the first time.

Any subsequent updates to the installation or `medalsboard` script, will load
the existing configuration.
