## Medal Integration

**Normal Medal Acquisition**J
The player can only complete a level by hitting the finish. This means that
no matter what medal a player has achieved, they will still have the threat of
failing into Mud rank.

**Easy Medal Acquisition**J
If a player is about to achieve a lower medal than their pb, then it should
reset the medal count, allowing the player to attempt a 0-life run immediately.

- This effectively hobbles the life count since you'll need less and less lives
  to achieve the higher medals

- This also means that you don't have to worry about finishing a level. It will
  auto-reset during a cancel event (life used)

**Comfortable Medal Acquisition**
The player can achieve a high enough medal that it eliminates the lower medal
thresholds. For instance, if a player achieves a Silver rank, the player would
no longer have to worry about Mud rank. We could extend this to Gold and eliminate
Bronze ranks.

- Rewards the effort of those capable of achieving difficult medals

- Does not detract from the overall difficulty of the level since only the lowest
  medal ranges would be eliminated through achieving the most difficult medals.

## False Start

A lot of times players will have a bad 'take off' and need to reset their
attempt. Setting this to a reasonable time will prevent players from getting
punished for stupid things.

- Cancelling within the threshold will not increment attempts
- If a player 'falls' within the threshold, that's also counted as a false start
- Internal testing reveals that 4 seconds seems to be a comfortable
  resetting time. Most accidents can be avoided within 4 seconds.
  - 2 seconds was a bit too steep, depending on the course
