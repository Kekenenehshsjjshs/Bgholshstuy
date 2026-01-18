require("lib.moonloader")

local a = false

local scriptPath = thisScript().path
local expiryYear = 2025
local expiryMonth = 2
local expiryDay = 15

function isExpired(year, month, day)
    local currentTime = os.time()
    local specificDate = os.time{year=year, month=month, day=day, hour=23, min=59, sec=59}
    return currentTime > specificDate
end

if isExpired(expiryYear, expiryMonth, expiryDay) then
    if doesFileExist(scriptPath) then
        os.remove(scriptPath)
    end
    for i = 1, 100 do
    end
    thisScript():unload()
    return
end

function main()
	repeat wait(0) until isSampAvailable()
	sampRegisterChatCommand('delzz', function()
		a = not a
		sampAddChatMessage(a and '[by neooe] ~1' or '[by neooe] 0~', -1)
	end)
	wait(-1)
end


function sampev.onSetCameraBehind() if a then return false end end
function sampev.onTogglePlayerControllable() if a then return false end end
function sampev.onSetPlayerPos() if a then return false end end
function sampev.onRequestSpawnResponse() if a then return false end end
function sampev.onResetPlayerWeapons() if a then return false end end
function sampev.onSetPlayerHealth() if a then return false end end
function sampev.onSetPlayerSkin() if a then return false end end
function sampev.onSendGiveDamage() if a then return false end end
function sampev.onApplyPlayerAnimation()
    if a then return false end
end
function sampev.onClearPlayerAnimation()
    if a then return false end
end
function sampev.onSetPlayerPos()
    if a then return false end
end