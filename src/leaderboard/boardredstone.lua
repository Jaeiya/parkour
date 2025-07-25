local state = require("boardstate")

return function()
    while true do
        os.pullEvent("redstone")

        local right = redstone.getInput("right")
        local left = redstone.getInput("left")

        if right and not state.timer.isActive then
            os.queueEvent("timer", { action = "start" })

        elseif right then
            -- The run will only be canceled if the active runner
            -- is the same player who triggered this action.
            os.queueEvent("leaderboard", {
                action="try_cancel_run",
                payload = state.timer.milliseconds }
            )

        elseif left and state.timer.isActive then
            -- This action will be ignored entirely, if the player who
            -- triggered this action, is not the active runner.
            --
            -- Otherwise...if the active runner does not have a time on
            -- record, one will be created for them. If the active runner
            -- already has a faster time, a slower time will not be saved.
            os.queueEvent("leaderboard", {
                action  = "save_player_time",
                payload = state.timer.milliseconds,
            })
        end
    end
end
