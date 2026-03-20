RegisterNetEvent("fn-k9utils:openDogCustomMenu", function()
    local options = {}

    for _, item in ipairs(Config.carEmoteCustomisationOptions) do
        table.insert(options, {
            label = item.label,
            args = { emote = item.emote }
        })
    end

    lib.registerMenu({
        id = 'dog_car_menu',
        title = "K9 Vehicle Emote",
        position = 'bottom-right',
        options = options,
        onClose = function() end,
    }, function(selected, args)
        local emote = options[selected].args.emote
        if lib.callback.await("fn-k9utils:saveSettings", false, "carEmote", emote) then
            UpdateCarEmote()
        end
    end)

    lib.showMenu('dog_car_menu')
end)