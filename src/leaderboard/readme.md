## `_boardstartup`

As the name suggests, this is the file that will execute all other leaderboard processes.
Unless a file is imported as a library, all other files in this directory should be considered
modules, that will be imported and executed by this startup file.

## `boardinstaller`

Again, as the name suggests, this is the install script for the leaderboard. During the
installation process, the user will be prompted to configure the leaderboard. The user
will only be prompted for configuration info if the configuration doesn't already
exist on the computer.

## `board`

Handles all events for updating and displaying the leaderboard. This includes player
interaction events.

The leaderboard differentiates between a players time & attempts, such that two
players with the same time will be sorted using their attempts. If both players have
the same time & attempts, then the players will be sorted by who got the fastest time
first. This might seem unfair at first, but if we assume two players are taking
turns on a course, then they both had an equal chance of being the first to achieve
that time.

A player is also considered for a medal, on each run. The life thresholds are updated
through the medals board and communicated to the leaderboard through the
`boardmedalbridge`.

Depending on the amount of lives used, the player can be eligible for a specific medal.
The finished-attempts, lives used, and medals achieved are all tracked internally on
each players run. The players order on the leaderboard is **NOT** affected by the medal
they achieve. A `Mud` medal player can still be above a `Gold` medal player on the same
leaderboard; assuming they have a better time & attempt ratio.

After each completed run, a players life-count is reset and they can try again for a
better medal. This can be done as many times as they wish. If they achieve a lower
medal than their PB medal, the player is **not** demoted to that medal. A player
will retain their PB medal until they achieve a new PB.

## `boardtimer`

Handles events for starting, stopping, and cancelling the timer. It also controls how
the timer is sent to the monitor host.

Currently, the time is broken up into this format: `hh:mm:ss.tt` where `h` is hours,
`m` is minutes,`s` is seconds, and `t` is ticks. Computer craft does not allow for
a sleep period smaller than a single _tick_. A tick is 50ms (milliseconds), therefore
we cannot differentiate runs in terms of milliseconds, only ticks.

There are 20 ticks in a second, so as the timer is updated, the smallest increment
of time possible is `1 tick` or `50ms`. So the closest that two runners can ever
be to one another, is one tick. If two players were to run and one of them achieves
a 100ms run and the second achieves a 149ms run, the leaderboard would see both
runs as identical. Clearly the player that ran the 100ms is faster, but because
we can only differentiate ticks, not milliseconds, that precision is lost.

In order to compensate for this, we also factor in attempts, as discussed in the `board`
section. Unfortunately, we just have to accept that there is lost precision here, but
in most cases, because `50ms` is so quick, it should only really apply to the easiest
maps. As the maps get harder, the speed gap between players will be more distinguished.

## `boardlib`

This is the library code for all board functionality. It contains all methods required
for updating/saving player data, as well as some string methods. Any methods required
to interact with leaderboard data, will be in this file.

## `boardstate`

As the name suggests, this is state information for the leaderboard. Any data that
needs to be read/updated in more than one file, will be in this file.

## `boardredstone`

This file acts as a bridge between the player and the leaderboard. When a player
steps on a pressure plate, this file handles that interaction and sends the
correct event to either the `boardtimer` or `board`.

Both sides of the computer must be set up such that a pressure plate can send
a redstone signal to either the left or right side of the computer. Left side
means the player is attempting to finish a run, while the right side is a player
attempting to start a run.

That being said, even if the signals are correct, when the leaderboard disk is
being installed, the plate positions are required for proper activation, otherwise
they will be ignored. So if the plate coordinates entered during install are incorrect,
then it will appear as though nothing is happening.

## `boardplayertracker`

Tracks the players position for use when setting the cancel-bound threshold and
the fail-bound threshold. The cancel-bound is an `x` or `z` coord around the start
position. For instance, if you select `x = 1` and the start position happens
to be `x = 0`, then if the player moves to a coordinate who's x is `>= 1` at any
point, their run is auto-cancelled.

So it is effectively a range 'behind' where the player would be activating the their
run. You would always select the coordinate that is behind where the player will be
moving 'forward'. For instance, if the course is setup to be run from East to west,
then you would pick the cancel-bound coordinate to be **one** coordinate East of the start
position. Likewise if the course was designed to be run from South to North, then you
would set the cancel-bound coordinate to **one** coordinate South of the start position.

The fail-bound is much more intuitive. It's the height at which a player will
be considered 'out'. A run will be auto-cancelled the moment a player falls/steps
within the fail-bound. They will then have to run back to the start and try
again.

## `boardui`

This is a very important file, as it displays the management interface and allows
the update of existing configuration information, from the computers terminal.

If the start/end positions (where the pressure plates are) need to be changed,
you would do it through this interface, along with other config options.

## `boardstats`

A very simple module that sends all player data to the statboard every `n`
seconds.

## `boardmedalbridge`

Retrieves the medal information from the medals board. If it does not get a response
from the medals board within a reasonable time, it keeps trying until it does. This
will block the leaderboard from fully starting up.

The reason we block, is because this information is vital to the normal functionality
of the leaderboard. Without the medal information, we won't be able to update the
medal stats for a player.

You might be thinking, well why not cache the medal data then? Because if we cache
the data, it could potentially cause an info mismatch between the medal board and
the leaderboard.

Imagine this scenario: the leaderboard is turned off and the medals board has its
medal lives updated. Since the leaderboard is not active, it doesn't receive the
new information from the medals board. When the leaderboard is started up, it
will think that its cache is up to date; we now have a data mismatch.
