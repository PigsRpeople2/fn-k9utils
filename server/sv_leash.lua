RegisterNetEvent("fn-k9utils:sv:syncLeash", function (playerPed, dogPed)
    TriggerClientEvent("fn-k9utils:cl:syncLeash", -1, playerPed, dogPed)
end)