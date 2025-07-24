local utils = require("utils")


local mon = utils.getMonitor()
if not mon then
    error("whoops no monitor")
end


mon.setPaletteColor(colors.black, 0x000000)  -- Force true-black background

mon.setPaletteColor(colors.brown,     0xAE7F52) -- Mud
mon.setPaletteColor(colors.gray,      0xCD7F32) -- Bronze
mon.setPaletteColor(colors.white,     0xF1F8FF) -- Silver
mon.setPaletteColor(colors.orange,    0xFFD800) -- Gold
mon.setPaletteColor(colors.pink,      0xFC00FF) -- Heart
mon.setPaletteColor(colors.lightGray, 0x444444) -- Lives

utils.clear(mon)
mon.setTextScale(2)

local x, y = mon.getCursorPos()
mon.setTextColor(colors.brown)
mon.setCursorPos(x, y+1)
utils.print("   ;bwn;Mud Medal     ;gry;Bronze Medal", mon)
mon.setCursorPos(1, y+2)
utils.print("    ;lgy;4 Lives         ;lgy;3 Lives", mon)

mon.setCursorPos(1, y+4)
utils.print(";wht;  Silver Medal    ;org;Gold Medal", mon)
mon.setCursorPos(1, y+5)
utils.print("    ;lgy;2 Lives         ;lgy;1 Life", mon)

mon.setCursorPos(1, y+7)
utils.print(";pnk;" .. utils.centerText("Heart Medal", mon), mon)
mon.setCursorPos(1, y+8)
utils.print(";lgy;" .. utils.centerText("No Lives Lost", mon), mon)
