--AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    if CheckDog() then
        Wait(1000)
        print("Player is a dog, applying dog stats.")
        if Config.quickerStaminaRegen then
            StartStaminaThread()
        end

        if GetPlayerMaxStamina(cache.playerId) ~= Config.DogStamina then
            SetPlayerMaxStamina(cache.playerId, Config.DogStamina)
            SetPlayerStamina(cache.playerId, Config.DogStamina)
        end

        if Config.SprintInside then
            SetPedFlag(cache.ped, 427, true)
        end
        if Config.NotWimpy then
            SetPedFlag(cache.ped, 160, true)
        end
        if Config.SurviveWater then
            SetPedFlag(cache.ped, 3, false)
        end
        if Config.Swim then
            SetPedFlag(cache.ped, 163, true)
            SetPedFlag(cache.ped, 164, true)
            StartFallFixThread()
        end
        if Config.CanFall and not Config.Swim then
            SetPedFlag(cache.ped, 164, true)
            StartFallFixThread()
        end

        if Config.AutoCarEmote then
            lib.onCache("seat", function (value, oldValue)

                Wait(10)
                if value == false then
                    exports["rpemotes-reborn"]:EmoteCancel(false)
                else
                    local custom = lib.callback.await("fn-k9utils:fetchSettings", false, "carEmote")
                    if custom == nil then custom = "" end
                    
                    if custom ~= "" then
                        exports["rpemotes-reborn"]:EmoteCommandStart(custom, 0)
                        Wait(10)
                    end
                    exports["rpemotes-reborn"]:EmoteCommandStart("bdogsitcar", 0)
                end
            end)
        end

        RegisterCommand("setcaremote", function()
            TriggerEvent("fn-k9utils:openDogCustomMenu")
        end, false)


        RegisterCommand("attach", function()
            AttachToUte()
        end, false)

        RegisterCommand("detach", function()
            DetatchFromUte()
        end, false)


        if Config.DogPreferBackSeat then
            lib.onCache("vehicle", function (value, oldValue)
                if value then
                   print(value) 
                end
            end)
        end
    end
--end)