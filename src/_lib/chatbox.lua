local utils = require('utils')

local chatBox = utils.getChatBox()
if not chatBox then
    printError('chat script terminated; missing chat box')
    return nil
end


local function pullChatEvent()
    local _, data = os.pullEvent('send_chat')

    ---@type ChatData
    return data
end


---@type ChatData[]
local msgQueue = {}
local head, tail = 1, 0


local function handleMessages()
    while true do
        if head > tail then
            sleep(0.1)
            goto continue
        end

        local data = msgQueue[head]
        local success, err = false, nil
        if data.username then
            success, err = utils.sendChatTo(
                chatBox,
                data.username,
                data.msg,
                data.prefix,
                data.brackets,
                data.bracketColor
            )
        else
            success, err = utils.sendChat(
                chatBox,
                data.msg,
                data.prefix,
                data.brackets,
                data.bracketColor,
                -1
            )
        end

        if not success then
            error(err)
        end

        if head <= tail then
            msgQueue[head] = nil
            head = head + 1
        end

        sleep(0.1)
        ::continue::
    end
end


local function handleQueue()
    while true do
        local data = pullChatEvent()

        if not data or not data.msg or #data.msg == 0 then
            error('invalid chat data')
        end

        tail = tail + 1
        msgQueue[tail] = data
    end
end


return function()
    parallel.waitForAny(
        handleQueue,
        handleMessages
    )
end
