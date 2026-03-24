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

function MovePlayerPed(targetCoords, duration, threaded)
    if threaded then
        Citizen.CreateThread(function (threadId)
            local startPos = GetEntityCoords(cache.ped)
            local startTime = GetGameTimer()
            local endTime = startTime + duration

            while GetGameTimer() < endTime do
                local now = GetGameTimer()
                local elapsed = now - startTime
                local t = math.max(0.0, math.min(1.0, elapsed / duration))

                local newX, newY, newZ = table.unpack(vec3(
                    startPos.x + (targetCoords.x - startPos.x) * t,
                    startPos.y + (targetCoords.y - startPos.y) * t,
                    startPos.z + (targetCoords.z - startPos.z) * t
                ))

                SetEntityCoordsNoOffset(cache.ped, newX, newY, newZ, true, true, false)

                Wait(0)
            end

            SetEntityCoordsNoOffset(cache.ped, targetCoords.x, targetCoords.y, targetCoords.z, true, true, false)
        end)
    else
        local startPos = GetEntityCoords(cache.ped)
        local startTime = GetGameTimer()
        local endTime = startTime + duration

        while GetGameTimer() < endTime do
            local now = GetGameTimer()
            local elapsed = now - startTime
            local t = math.max(0.0, math.min(1.0, elapsed / duration))

            local newX, newY, newZ = table.unpack(vec3(
                startPos.x + (targetCoords.x - startPos.x) * t,
                startPos.y + (targetCoords.y - startPos.y) * t,
                startPos.z + (targetCoords.z - startPos.z) * t
            ))

            SetEntityCoordsNoOffset(cache.ped, newX, newY, newZ, true, true, false)

            Wait(0)
        end

        SetEntityCoordsNoOffset(cache.ped, targetCoords.x, targetCoords.y, targetCoords.z, true, true, false)
        Wait(10)
        return true
    end
end

function ClimbIntoBack(data)
    local bonePos = GetWorldPositionOfEntityBone(data.entity, GetEntityBoneIndexByName(data.entity, "boot"))
    if bonePos == vec3(0.0, 0.0, 0.0) then 
        lib.notify({title = "Unable to climb", description = "Could not find boot position", type = "error"})
        ClearPedTasks(cache.ped)
        ClearPedSecondaryTask(cache.ped)
        return
    end
    local rearOffset = GetOffsetFromEntityGivenWorldCoords(data.entity, bonePos.x, bonePos.y, bonePos.z)
    TaskGotoEntityOffsetXy(cache.ped, data.entity, -1, 0.0, 0.0, rearOffset.y - 2.0, 1.0, 1)
    SetVehicleDoorOpen(data.entity, 5, false, false)

    repeat
        Wait(0) 
        local distance = GetOffsetFromEntityGivenWorldCoords(data.entity, GetEntityCoords(cache.ped).x, GetEntityCoords(cache.ped).y, GetEntityCoords(cache.ped).z) - GetOffsetFromEntityGivenWorldCoords(data.entity, bonePos.x, bonePos.y, bonePos.z)
    until (distance.y > -2.1) and (distance.y < -1.9) and (distance.x < 0.25) and (distance.x > -0.25) or IsPedDeadOrDying(cache.ped, true)

    ClearPedTasks(cache.ped)
    ClearPedSecondaryTask(cache.ped)

    local targetHeading = GetHeadingFromVector_2d(
        GetEntityCoords(data.entity).x - GetEntityCoords(cache.ped).x,
        GetEntityCoords(data.entity).y - GetEntityCoords(cache.ped).y
    )

    TaskAchieveHeading(cache.ped, targetHeading, -1)



    Wait(3000)
    ClearPedTasks(cache.ped)
    ClearPedSecondaryTask(cache.ped)

    local coords = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)
    local zdistance = bonePos.z - (coords.z - 0.75)
    local pos = GetOffsetFromCoordAndHeadingInWorldCoords(coords.x, coords.y, coords.z, heading, 0.0, 1.5, zdistance)
    lib.playAnim(cache.ped, "creatures@rottweiler@in_vehicle@4x4", "get_in", 8.0, 8.0, -1, 4)
    Wait(400)
    repeat Wait(0) until MovePlayerPed(pos, 400, false)
    MovePlayerPed(vec3(bonePos.x, bonePos.y, bonePos.z + 0.1), 200, true)
    ClearPedTasks(cache.ped)
    ClearPedSecondaryTask(cache.ped)
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