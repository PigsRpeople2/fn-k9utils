lib.callback.register("fn-k9utils:sv:checkDog", function (source)
    for _, model in ipairs(Config.whitelistedModels) do
        local playerPed = GetPlayerPed(source)
        if GetEntityModel(playerPed) == GetHashKey(model) then
            return true
        end
    end
    for _, group in ipairs(Config.whitelistedGroups) do
        if exports.qbx_core:HasGroup(source, group) then
            return true
        end
    end
    return false
end)