local file = "data.json"

local function LoadData()
    local load = LoadResourceFile(GetCurrentResourceName(), file)
    return json.decode(load) or {}
end

lib.callback.register("fn-k9utils:saveSettings", function (source, setting, option)
    local db = LoadData()
    local player = GetPlayerIdentifiers(source)[1]
    if not db[player] then db[player] = {} end
    
    db[player][setting] = option                                                                -- ADD FUCKING INPUT SANITISATION YOU FUCKING DUMBASS
    SaveResourceFile(GetCurrentResourceName(), file, json.encode(db, {indent = true}), -1)
    return true
end)

lib.callback.register("fn-k9utils:fetchSettings", function (source, setting)
    local db = LoadData()
    local player = GetPlayerIdentifiers(source)[1]
    
    if not db then return nil end
    if not db[player] then return nil end
    return db[player] and db[player][setting] or nil
end)
