local leaving, entering, enterDoublePressed = false, false, false
local doors = {
    --["-1"] = { name = "Front Driver", seatIndex = -1, throughSeatIndex = 0 },
    --["0"] = { name = "Front Passenger", seatIndex = 0, throughSeatIndex = -1},
    ["1"] = { name = "Front Driver", seatIndex = 1, throughSeatIndex = 2 },
    ["2"] = { name = "Front Passenger", seatIndex = 2, throughSeatIndex = 1 },
}

local function checkMoves()
    local moveKeys, currentGameTimer = {32, 33, 34, 35}, GetGameTimer()
    repeat
        Wait(50)
        for _, v in pairs(moveKeys) do
            if IsControlPressed(0, v) then
                ClearPedTasks(cache.ped)
                return
            end
        end
    until IsPedSittingInAnyVehicle(cache.ped) or GetGameTimer() > currentGameTimer + 5000
end

local function GetNumberOfVehicleSeats(vehicle)
    local seats, numberOfSeats = { "seat_r", "seat_dside_r", "seat_dside_r1", "seat_dside_r2", "seat_dside_r3", "seat_dside_r4", "seat_dside_r5", "seat_dside_r6", "seat_dside_r7", "seat_pside_r", "seat_pside_r1", "seat_pside_r2", "seat_pside_r3", "seat_pside_r4", "seat_pside_r5", "seat_pside_r6", "seat_pside_r7" }, 0

    for _, v in pairs(seats) do
        if GetEntityBoneIndexByName(vehicle, v) ~= -1 then
            numberOfSeats = numberOfSeats + 1
        end
    end

    return numberOfSeats
end

local function GetNumberOfVehicleRegularSeats(vehicle)
    local seats, numberOfSeats = { "seat_r", "seat_dside_r", "seat_pside_r" }, 0

    for _, v in pairs(seats) do
        if GetEntityBoneIndexByName(vehicle, v) ~= -1 then
            numberOfSeats = numberOfSeats + 1
        end
    end

    return numberOfSeats
end

local function GetNumberOfFrontSeats(vehicle)
    local seats, numberOfSeats = { "seat_f", "seat_dside_f", "seat_pside_f" }, 0

    for _, v in pairs(seats) do
        if GetEntityBoneIndexByName(vehicle, v) ~= -1 then
            numberOfSeats = numberOfSeats + 1
        end
    end

    return numberOfSeats
end

local function GetNumberOfVehicleExtraSeats(vehicle)
    local seatsExtra, numberOfExtraSeats = { "seat_dside_r1", "seat_dside_r2", "seat_dside_r3", "seat_dside_r4", "seat_dside_r5", "seat_dside_r6", "seat_dside_r7", "seat_pside_r1", "seat_pside_r2", "seat_pside_r3", "seat_pside_r4", "seat_pside_r5", "seat_pside_r6", "seat_pside_r7" }, 0

    for _, v in pairs(seatsExtra) do
        if GetEntityBoneIndexByName(vehicle, v) ~= -1 then
            numberOfExtraSeats = numberOfExtraSeats + 1
        end
    end

    return numberOfExtraSeats
end

-- Updated it for you :p (I LOVE YOU AND I WANTTED TO HELPPP)
-- Made it prioritize backseats, It'll loop through the back ones first and then passenger, checking if it can get in. It ONLY checks the driver seat if no other seat is available 
local function enteringCar(veh)
    local coords = GetEntityCoords(cache.ped)

    if (veh == nil or veh == 0) or GetVehicleDoorLockStatus(veh) == 2 or IsEntityDead(cache.ped) then return end
    ClearPedTasks(cache.ped)
    ClearPedSecondaryTask(cache.ped)

    if entering then return end
    entering = true

    local targetSeat = nil
    local totalSeats = GetNumberOfVehicleSeats(veh)
    
    -- Check back seats first before front doors
    local rearSeats = {1, 2, 3, 4, 5, 6} 
    for _, seatIndex in ipairs(rearSeats) do
        if seatIndex < totalSeats then
            if IsVehicleSeatFree(veh, seatIndex) then
                targetSeat = seatIndex
                break 
            end
        end
    end

    -- If no back seats, try the front passenger
    if targetSeat == nil and IsVehicleSeatFree(veh, 0) then
        targetSeat = 0
    end
    -- Last resort, the driver seat
    if targetSeat == nil and IsVehicleSeatFree(veh, -1) then
        targetSeat = -1
    end
    if targetSeat ~= nil then
        SetPedFlag(cache.ped, 261, false)
        TaskEnterVehicle(cache.ped, veh, 10000, targetSeat, 1.0, 1, 0)
        checkMoves()
    end

    Wait(1000)
    entering = false
end

function StartBackseat()
    RegisterCommand('dogentercar', function ()

        Wait(0)

        if not IsPedInAnyVehicle(cache.ped, false) then
            local veh = GetVehiclePedIsTryingToEnter(cache.ped)
            enteringCar(veh)
        end
    end, false)
    RegisterKeyMapping('dogentercar', 'Dog Enter Vehicle', 'KEYBOARD', 'F')
end