function CreateLeash(dog)
    local dogId = NetworkGetNetworkIdFromEntity(dog)
    local playerId = NetworkGetNetworkIdFromEntity(cache.ped)
    TriggerServerEvent("fn-k9utils:sv:syncLeash", playerId, dogId)
end

Leashes = {}
RegisterNetEvent("fn-k9utils:cl:syncLeash", function (playerId, dogId)
    local playerPed = NetworkGetEntityFromNetworkId(playerId)
    local dog = NetworkGetEntityFromNetworkId(dogId)
    local dogCoords = GetEntityCoords(dog)
    local playerCoords = GetEntityCoords(playerPed)
    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do Wait(0) end
    local rope = AddRope(
        dogCoords.x,
        dogCoords.y,
        dogCoords.z,
        0.0, -- rotX
        0.0, -- rotY
        0.0, -- rotZ
        Config.LeashMaxDistance or 5.0, -- maxLenth
        4, -- ropeType
        Config.LeashMaxDistance or 5.0, -- initLength
        0.0, -- minLength
        1.0, -- lengthChangeRate
        false, -- onlyPPU
        true, -- collisionOn
        false, -- lockFromFront
        1.0, -- timeMultiplier
        false -- breakable
    )
    Leashes[dog] = rope
    --AttachRopeToEntity(rope, cache.ped, 0.0, 0.0, 0.0, false)
    ActivatePhysics(rope)
    AttachEntitiesToRope(rope, playerPed, dog, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 20.0, false, false, "IK_Root", "IK_Root")
end)


AddEventHandler("onResourceStop", function (resourceName)
    for dog, rope in pairs(Leashes) do
        DeleteRope(rope)
    end
end)


