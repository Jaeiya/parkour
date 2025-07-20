
term.clear()
term.setCursorPos(1, 1)

-- Executes the monitor host and any other scripts in parallel if needed
term.clear()
parallel.waitForAny(
    function ()
        print("")
        print("... Running Monitor Host ...")
        print("")
        shell.run("monhost")
    end
)

