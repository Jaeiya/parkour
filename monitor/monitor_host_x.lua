-- Executes the monitor host and any other scripts in parallel if needed
parallel.waitForAny(
    function ()
        print("")
        print("... Running Monitor Host ...")
        print("")
        shell.run("monhost")
    end
)

