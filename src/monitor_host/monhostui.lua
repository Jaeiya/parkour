local utils = require("utils")
local configFilePath = "monhost.cfg"


---@param config MonhostConfig
local function setHostname(config)
::prompt::
    local hostname = utils.prompt("Enter new host name")
    if utils.trim(hostname) == "" then
        utils.promptError("invalid host name; try again!")
        goto prompt
    end
    config.hostname = hostname
    utils.saveConfig(configFilePath, config)
end


---@param config MonhostConfig
local function setProtocol(config)
::prompt::
    local protocol = utils.prompt("Enter new protocol")
    if utils.trim(protocol) == "" then
        utils.promptError("invalid protocol; try again!")
        goto prompt
    end
    config.protocol = protocol
    utils.saveConfig(configFilePath, config)
end


---@param config MonhostConfig
return function (config)
    while true do
        utils.clear()
        utils.print(
            "... Running Monitor Host ...\n\n" ..
            ";lgy;  host_name: ;cyn;"..config.hostname.."\n"..
            ";lgy;   protocol: ;cyn;"..config.protocol
        )
        print()

        local exiting = utils.promptMenu(
            "Manage Configuration",
            {
                { name = "Set Host Name", exec = function() setHostname(config) end },
                { name = "Set Protocol",  exec = function() setProtocol(config) end }
            },
            false
        )

        if exiting then
            return
        end

        utils.clear()
        utils.print("... Updating Monitor Host ...")
        rednet.host(config.protocol, config.hostname)
    end
end
