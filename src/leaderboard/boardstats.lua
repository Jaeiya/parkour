local lib = require('boardlib')


---@param config BoardConfig
return function(config)
    while true do
        sleep(1.5)
        local players = lib.get()
        if #players > 0 then
            rednet.broadcast(
                {
                    action  = "update_player_data",
                    payload = lib.get()
                },
                config.statsProto
            )
        end
    end
end
