

---
---
---Starts all necessary scripts to run the monitor host.
---
---When installed, this file is renamed to 'startup', which causes
---the computer to execute this script every time the computer is
---turned on.
---
---The conditions for turning on the computer can either be through
---player interaction or chunk loading. If the computer is left 'on'
---when the world is closed, it will start 'on' when the chunk
---is loaded again.
---
---


term.clear()
term.setCursorPos(1, 1)

-- Executes the monitor host and any other scripts in parallel if needed
parallel.waitForAny(
    function ()
        print("... Starting Monitor Host...")
        shell.run("monhost")
    end
)

