-- Executes the timer and any other scripts in parallel if needed
parallel.waitForAny(
    function ()
        print("")
        print("... Running Timer ...")
        print("")
        shell.run("timer")
    end
)
