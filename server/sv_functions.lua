lib.callback.register("fn-k9utils:sv:checkDog", function (source, id)
    local player
    if id then
        player = id
    else
        player = source
    end
    for _, model in ipairs(Config.WhitelistedModels) do
        local playerPed = GetPlayerPed(player)
        if GetEntityModel(playerPed) == GetHashKey(model) then
            return true
        end
    end
    for _, group in ipairs(Config.WhitelistedGroups) do
        if exports.qbx_core:HasGroup(player, group) then
            return true
        end
    end
    return false
end)