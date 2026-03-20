function CheckDog()
    return lib.callback.await("fn-k9utils:sv:checkDog", false)
end

function UpdateCarEmote()
    if cache.seat ~= false then
        local custom = lib.callback.await("fn-k9utils:fetchSettings", false, "carEmote")
        if custom == nil then custom = "" end

        exports["rpemotes-reborn"]:EmoteCancel(false)
        Wait(10)
        if custom ~= "" then
            exports["rpemotes-reborn"]:EmoteCommandStart(custom, 0)
            Wait(10)
        end
        exports["rpemotes-reborn"]:EmoteCommandStart("bdogsitcar", 0)
    end
end

local setFlags = {}
function SetPedFlag(ped, flag, state)
    setFlags[#setFlags+1] = { ped = ped, flag = flag, state = state }
    SetPedConfigFlag(ped, flag, state)
end


function StartStaminaThread()
    CreateThread(function(threadId)
        while true do
            Wait(1000)
            if not IsPedSprinting(cache.ped) then
                while (GetPlayerMaxStamina(cache.playerId) ~= GetPlayerStamina(cache.playerId)) and not IsPedSprinting(cache.ped) do
                    print(GetPlayerMaxStamina(cache.playerId), GetPlayerStamina(cache.playerId))
                    if not CheckDog() then return end
                    if GetPlayerStamina(cache.playerId) ~= GetPlayerMaxStamina(cache.playerId) then
                        if (GetPlayerStamina(cache.playerId) < 50.0) and Config.criticalRegen then
                            RestorePlayerStamina(cache.playerId, Config.dogStaminaRegen * 5)
                        else
                            RestorePlayerStamina(cache.playerId, Config.dogStaminaRegen)
                        end
                    
                    end
                    Wait(750)
                end
            end
        end
    end)
end


AddEventHandler("onResourceStop", function (resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, data in pairs(setFlags) do
            local state = not data.state
            SetPedConfigFlag(data.ped, data.flag, state)
        end
        if GetPlayerMaxStamina(cache.playerId) ~= 100.0 then
            SetPlayerMaxStamina(cache.playerId, 100.0)
            SetPlayerStamina(cache.playerId, 100.0)
        end
    end
end)