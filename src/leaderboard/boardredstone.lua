local state = require("boardstate")

return function()
    while true do
        os.pullEvent("redstone")

        local right = redstone.getInput("right")
        local left = redstone.getInput("left")

        if right and not state.timer.isActive then
            os.queueEvent("timer", { action = "start" })

        elseif right then
            os.queueEvent("leaderboard", {
                action="try_cancel_run",
                payload = state.timer.milliseconds }
            )

        elseif left and state.timer.isActive then
            os.queueEvent("leaderboard", {
                action  = "save_player_time",
                payload = state.timer.milliseconds,
            })
        end
    end
end
