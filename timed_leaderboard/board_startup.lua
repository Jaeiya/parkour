-- Executes the timer and any other scripts in parallel if needed
parallel.waitForAny(
    function()
        print()
        print("... Running Player Detection ...")
        shell.run("detect_player")
    end,
    function ()
        print("")
        print("... Running Timer ...")
        shell.run("timer")
    end,
    function ()
        print()
        print("... Running Leader Board ...")
        shell.run("board")
    end
)
