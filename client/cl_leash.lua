local leashTarget = exports.ox_target:addGlobalPlayer({
    label = 'Leash Dog',
    icon = 'fa-solid fa-dog',
    items = Config.LeashItem,
    canInteract = function (entity, distance, coords, name, bone)
        return CheckDog(GetPlayerServerId(NetworkGetEntityOwner(entity))) and distance <= Config.LeashInteractDistance and IsPedOnFoot(entity) and IsPedHuman(cache.ped)
    end,
    onSelect = function(data)
        CreateLeash(data.entity)
    end
})



AddEventHandler('onResourceStop', function (resourceName)
    if resourceName == GetCurrentResourceName() then
        exports.ox_target:removeGlobalPlayer(leashTarget)
    end
end)