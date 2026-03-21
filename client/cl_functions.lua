function CheckDog(id)    
    return lib.callback.await("fn-k9utils:sv:checkDog", false, id)
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



function StartStaminaThread()
    CreateThread(function(threadId)
        while true do
            Wait(1000)
            if not IsPedSprinting(cache.ped) then
                while (GetPlayerMaxStamina(cache.playerId) ~= GetPlayerStamina(cache.playerId)) and not IsPedSprinting(cache.ped) do
                    if not CheckDog() then return end
                    if GetPlayerStamina(cache.playerId) ~= GetPlayerMaxStamina(cache.playerId) then
                        if (GetPlayerStamina(cache.playerId) < 50.0) and Config.CriticalRegen then
                            RestorePlayerStamina(cache.playerId, Config.DogStaminaRegen * 5)
                        else
                            RestorePlayerStamina(cache.playerId, Config.DogStaminaRegen)
                        end
                    
                    end
                    Wait(750)
                end
            end
        end
    end)
end

local drop = 0.05
function AttachToUte()
    if IsPedOnVehicle(cache.ped) then
        local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)
        if Config.Utes[string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))] and Config.SitInUte then
            local coords = GetEntityCoords(cache.ped)
            local rot = GetEntityRotation(vehicle, 2)
            local offset = GetOffsetFromEntityGivenWorldCoords(vehicle, coords.x, coords.y, coords.z)
            local dogRot = GetEntityRotation(cache.ped, 2)
            drop = 0.05

            AttachEntityToEntity(cache.ped, vehicle, GetPedBoneIndex(cache.ped, 0x0), offset.x, offset.y, offset.z - drop, dogRot.x, dogRot.y, dogRot.z - rot.z, false, false, true, true, 2, true)

            

            local custom = lib.callback.await("fn-k9utils:fetchSettings", false, "carEmote")
            if custom == nil then custom = "" end

            exports["rpemotes-reborn"]:EmoteCancel(false)
            Wait(10)
            if custom ~= "" then
                exports["rpemotes-reborn"]:EmoteCommandStart(custom, 0)
                Wait(10)
            end
            exports["rpemotes-reborn"]:EmoteCommandStart("bdogsit", 0)

            while not IsEntityAttached(cache.ped) do
                drop = drop + 0.05
                AttachEntityToEntity(cache.ped, vehicle, GetPedBoneIndex(cache.ped, 0x0), offset.x, offset.y, offset.z - drop, dogRot.x, dogRot.y, dogRot.z - rot.z, false, false, true, true, 2, true)
                if drop > 1.0 then 
                    lib.notify({
                        title = "Failed To Attach",
                        description = "Try moving to another spot and try again",
                        type = "error"
                    }) 
                    return false 
                end
            end
        end
    end
end

function DetatchFromUte()
    DetachEntity(cache.ped, false, true)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)
    local coords = GetEntityCoords(cache.ped)
    local rot = GetEntityRotation(vehicle, 2)
    local offset = GetOffsetFromEntityGivenWorldCoords(vehicle, coords.x, coords.y, coords.z)
    local heading = GetEntityHeading(cache.ped)

    AttachEntityToEntity(cache.ped, vehicle, GetPedBoneIndex(cache.ped, 0x0), offset.x, offset.y, offset.z + 0.1 + drop, rot.x, rot.y, heading - rot.z, false, false, true, true, 2, true)
    Wait(10)
    DetachEntity(cache.ped, true, true)
    Wait(250)
    exports["rpemotes-reborn"]:EmoteCancel(false)
end

function StartFallFixThread()
    CreateThread(function(threadId)
        while true do
            Wait(500)
            if IsPedFalling(cache.ped) then
                if GetEntityHeightAboveGround(cache.ped) > 4.0 then
                    SetPedConfigFlag(cache.ped, 164, false)
                    while GetEntityHeightAboveGround(cache.ped) > 1.0 do Wait(0) end
                    SetPedConfigFlag(cache.ped, 164, true)
                end
            end
            if IsPedOnVehicle(cache.ped) then
                local coords = GetEntityCoords(cache.ped)
                local vehicle = lib.getClosestVehicle(coords, 3.0, true)
                if not IsEntityAttachedToAnyVehicle(cache.ped) then
                    local velocity = GetEntityVelocity(cache.ped)
                    local totalVelocity = math.abs(velocity.x) + math.abs(velocity.y) + math.abs(velocity.z)
                    if totalVelocity > (40 / 3.6) then
                        if not IsPedRagdoll(cache.ped) then
                            SetPedToRagdoll(cache.ped, 1000, 1500, 0, false, false, false)
                            ApplyForceToEntityCenterOfMass(cache.ped, 1, velocity.x * -0.5, velocity.y * -0.5, 5, 0, true, false, false)
                        end
                    end
                end
            end
        end
    end)
end

local setFlags = {}
function SetPedFlag(ped, flag, state)
    local initialState = setFlags[flag] and setFlags[flag].initialState or GetPedConfigFlag(cache.ped, flag, true)
    setFlags[flag] = { ped = ped, flag = flag, state = state, initialState = initialState }
    SetPedConfigFlag(ped, flag, state)
end


AddEventHandler("onResourceStop", function (resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, data in pairs(setFlags) do
            SetPedConfigFlag(data.ped, data.flag, data.initialState)
        end
        if GetPlayerMaxStamina(cache.playerId) ~= 100.0 then
            SetPlayerMaxStamina(cache.playerId, 100.0)
            SetPlayerStamina(cache.playerId, 100.0)
        end
        DetachEntity(cache.ped, true, true)
    end
end)