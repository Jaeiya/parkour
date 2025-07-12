-- Executes the timer and any other scripts in parallel if needed
parallel.waitForAny(
    function ()
        print("")
        print("... Running Timer ...")
        shell.run("timer")
    end,
    function ()
        print()
        print("... Running Leader Board ...")
        shell.run("leaderboard")
    end
)
