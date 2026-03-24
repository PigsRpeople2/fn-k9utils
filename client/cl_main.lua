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


        local climbTarget = exports.ox_target:addGlobalVehicle({
            label = 'Climb Into Back',
            icon = 'fa-solid fa-car',
            canInteract = function (entity, distance, coords, name, bone)
                return CheckDog() and IsPedOnFoot(cache.ped) and not IsPedHuman(cache.ped) and distance <= 5.0 and GetEntityBoneIndexByName(entity, "boot") ~= -1
            end,
            onSelect = function(data)
                ClimbIntoBack(data)
            end
        })

        
        AddEventHandler('onResourceStop', function (resourceName)
            if resourceName == GetCurrentResourceName() then
                exports.ox_target:removeGlobalVehicle(climbTarget)
            end
        end)






        if Config.DogPreferBackSeat then
            StartBackseat()
        end

        RegisterCommand("clear", function ()
            ClearPedTasks(cache.ped)
            ClearPedSecondaryTask(cache.ped)
        end, false)
    end
--end)