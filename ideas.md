**All implementation details that are prefixed by an asterisk are not implemented yet**

## Medal Acquisition (Theory)

_All difficulties below **normal** are hypothetical and just a potential
improvement to the **normal** vision. The **normal** acquisition will most
likely win out in the end_

### Normal

The player will only complete a level by hitting the finish. The players PB medal
will always be their recognized rank, but a player can still run the course and
get a Mud rank; that mud rank will only be recognized as their latest attempt,
not as a demotion. It just allows them to see how close or how far away they
were from their pb.

### Easy

If a player is about to achieve a lower medal than their pb, then it should
reset the life count, allowing the player to attempt a 0-life run immediately.

- This effectively hobbles the life count since you'll need less and less lives
  to achieve the higher medals
- This also means that you don't have to worry about finishing a level. It will
  auto-reset during a cancel event (life used)

### Comfortable

The player can achieve a high enough medal that it eliminates the lower medal
thresholds. For instance, if a player achieves a Silver rank, the player would
no longer have to worry about Mud rank. We could extend this to Gold and eliminate
Bronze ranks.

- Rewards the effort of those capable of achieving difficult medals
- Does not detract from the overall difficulty of the level since only the lowest
  medal ranges would be eliminated through achieving the most difficult medals.

## False Start (Theory)

A lot of times players will have a bad 'take off' and need to reset their
attempt. Setting this to a reasonable time will prevent players from getting
punished for stupid things.

- Cancelling within the threshold will not increment attempts
- If a player 'falls' within the threshold, that's also counted as a false start
- Internal testing reveals that 4 seconds seems to be a comfortable
  resetting time. Most accidents can be avoided within 4 seconds.
  - 2 seconds was a bit too steep, depending on the course

## Leaderboard

Displays all players who have run a given level, with the time & attempts that
it took. Only their pb will appear on the board.

- Players are sorted by time & attempts
  - \*_If two players match time & attempts, then we sort by earliest time stamp of completion_
- \*_Rainbow name_
  - \*_A player with the fastest time & best medal, will have their name printed in rainbow colors_
- All statistics of a players run are stored in its internal database
- Starting a run
  - Auto-detects player
  - Starts timer
  - Player attempts updated
  - Tracks player position
    - Allows cancelling on actuation-bound
    - \*_Allows cancelling on fail-bound_
- Finishing a run
  - Auto-detects player
  - Stops timer
  - Updates player data
  - Resets player lives so they can go for a better medal on their next run
- Runs can be cancelled
  - Only the player actively running can cancel it
    - It is considered a fail condition to cancel a run
  - Hitting the start-actuator during a run
  - Moving behind the actuator-bound during a run
  - \*_Falling into the fail-bound during a run_
  - Cancelling a run uses a life
    - \*_Unless a false-start_
- \*_Allows false-starts_
  - \*_Activated by cancelling a run_
    - \*_Hitting actuation-bound_
    - \*_Hitting fail-bound_
  - \*_Threshold of 3 - 5 seconds_
  - \*_Player data is not updated_
  - \*_Timer is reset_
- Communicates with the monitor host to display timer
- Communicates with the medal board to retrieve/receive _lives_ info
- Communicates with the stat board to send player statistics

## Medal Board

Displays the available medals that a player can achieve, including the
lives threshold for each medal.

- Using less lives results in getting a better medal
- Board can be configured through the UI to update lives
- Communicates with the leaderboard to transfer _lives_ counts

## Medal Breakdown

Players can earn medals, but the way in which they earn medals is
through lives. This means that there can be different ranks
among medals. The lower the rank, the better the medal.

For instance if the silver rank has a threshold of 3 - 5 lives, then
that means the possible ranks for Silver are S1 - S3. Where an S1 only
used 1 life and an S3 used 3 lives of the Silver rank. Less lives means
higher rank.

## Stats Board

Displays all relevant player data in an easy-to-read format.

- Time Display
  - pb time and attempts it took
  - latest time and attempts
  - total time and attempts (cumulative)
- Name Display
  - Player name is displayed in a default color
  - The highest medal a player has achieved is displayed in rank notation next to the players name
    - `S1` would be Silver 1
    - `G3` would be Gold 3
    - The lower the number, the higher the rank
  - \*_Rainbow name_
    - \*_A player with the fastest time & best medal, will have their name printed in rainbow colors_
- Medal Display
  - pb
    - medal (S1, B3, etc...) colored based on medal color
    - How many lives used
    - How many attempts it took
  - latest (the last medal achieved)
    - medal (S1, B3, etc...) colored based on medal color
    - How many lives used
    - How many attempts it took
  - total (an average of all medals achieved)
    - medal (S1, B3, etc...) colored based on medal color
    - How many lives used
    - How many attempts it took
- Switch between all players statistics using buttons
- Allow player to show their stats immediately
- Communicates with the leaderboard to receive player stats
