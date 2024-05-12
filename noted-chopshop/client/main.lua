local QBCore = exports['qb-core']:GetCoreObject()
local threads = 0
local dropOffZone
local doz = nil
local carIndex = 1
local CurrentVehicles = {}
local blip
local ScrapTime = 2000
local textEntities = {} -- Table to store text entities
local listed = false

local ChopParts = {
        { part = 0, bone = 'door_dside_f', text = 'Front Left Door',  condition = function(v) return GetEntityBoneIndexByName(v, 'door_dside_f') > 0 end},
        { part = 2, bone = 'door_dside_r', text = 'Rear Left Door', condition = function(v) return GetEntityBoneIndexByName(v, 'door_dside_r') > 0 end},
        { part = 3, bone = 'door_pside_r', text = 'Rear Right Door', condition = function(v) return GetEntityBoneIndexByName(v, 'door_pside_r') > 0 end},
        { part = 1, bone = 'door_pside_f', text = 'Front Right Door', condition = function(v) return GetEntityBoneIndexByName(v, 'door_pside_f') > 0 end},
        { part = 4, bone = 'bonnet', text = 'Hood', condition = function(v) return GetEntityBoneIndexByName(v, 'bonnet') > 0 end},
        { part = 5, bone = 'boot', text = 'Trunk', condition  = function(v) return GetEntityBoneIndexByName(v, 'boot') > 0 end},
       -- { part = 0, bone = 'wheel_lf', text = 'Front Left Wheel', isWheel = true, prop = "prop_wheel_01" },
       -- { part = 4, bone = 'wheel_lr', text = 'Rear Left Wheel', isWheel = true, prop = "prop_wheel_01" },
       -- { part = 5, bone = 'wheel_rr', text = 'Rear Right Wheel', isWheel = true, prop = "prop_wheel_01" },
       -- { part = 1, bone = 'wheel_rf', text = 'Front Right Wheel', isWheel = true, prop = "prop_wheel_01" },
}

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

local DrawText3Ds = function(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y+0.015, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
--[[ local function DrawText3Ds(x, y, z, text, id)
    local textEntity = {}
    textEntity.x = x
    textEntity.y = y
    textEntity.z = z
    textEntity.text = text
    textEntity.id = id

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()

    table.insert(textEntities, textEntity) -- Store the text entity
end ]]

--[[ local function DeleteText3Ds(id)
    for i, activeText in ipairs(textEntities) do
        if activeText.id == id then
            table.remove(textEntities, i)  -- Remove the text from the activeTexts table
            break  -- Exit the loop after deleting the text
        end
    end
end ]]

function ChopListFinished()
    if next(CurrentVehicles) ~= nil then
        return
    end
    doz:destroy()
    RemoveBlip(blip)
    listed = false
    -- add reward mechanism here
end

function CreateDropOffZone()
    local i = math.random(1, #Config.Dol)
    dropOffZone = Config.Dol[i]
    doz = BoxZone:Create(dropOffZone, Config.DolLength[i], Config.DolWidth[i], {
        name="drop_zone",
        offset={0.0, 0.0, 0.0},
        scale={1.0, 1.0, 1.0},
        debugPoly=false,
    })
    print("dropOffZone = ", dropOffZone)

    blip = AddBlipForCoord(dropOffZone.x, dropOffZone.y, dropOffZone.z)
    SetBlipSprite(blip, 620)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, math.random(1,84))
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Chop Spot")
    EndTextCommandSetBlipName(blip)

    local isInsidePolyzone = false
    local ped = PlayerPedId()

    doz:onPlayerInOut(function(isPointInside)
        isInsidePolyzone = isPointInside
        if isPointInside then
            CreateThread(function()
                while isInsidePolyzone and IsPedInAnyVehicle(ped, false) do
                    DrawText3Ds(dropOffZone.x, dropOffZone.y-1, dropOffZone.z, "Press [E] to chop vehicle")
                    Wait(8)
                    if IsPedInAnyVehicle(ped) then
                        if IsControlJustPressed(0, 38) then
                            ScrapVehicle()
                            break
                        end
                    end
                end
            end)
        else
            Citizen.Wait(2000)
            isInsidePolyzone = false
        end
    end)
end



function IsInList(name)
    local retval = false
    print("checking Is In List")
    print("car name = ", name)
    if CurrentVehicles ~= nil and next(CurrentVehicles) ~= nil then
        for k in pairs(CurrentVehicles) do
            print("CurrentVehicles[k] = ", CurrentVehicles[k])
            print("CV vs name = ", (CurrentVehicles[k] == name))
            if CurrentVehicles[k] == name then
                print("Called True")
                retval = true
            end
            print("End loop")
        end
    end
    return retval
end

function GenerateVehicleList()
    CurrentVehicles = {}
    local cc = math.random(Config.VehicleCountMin, Config.VehicleCountMax)
    local i = 1
    while i <= cc do
        local randVehicle = Config.Vehicles[math.random(1, #Config.Vehicles)]
        if not IsInList(randVehicle) then
            CurrentVehicles[i] = randVehicle
            i+= 1
        end
    end
    listed = true
end

function CreateChopCard()
    local vlist2 = "Car List:<br />"
    local counter = 1
    for k, v in pairs(CurrentVehicles) do
        if CurrentVehicles[k] ~= nil then
            local vehicleInfo = QBCore.Shared.Vehicles[v]
            if vehicleInfo ~= nil then
                vlist2 = vlist2  .. counter .. ". " .. vehicleInfo["brand"] .. " " .. vehicleInfo["name"] .. "<br />"
            end
            counter = counter + 1
        end
    end
    TriggerServerEvent('noted-chopshop:server:giveChopCard', vlist2)
end

function CreateListEmail()
    if listed then
        if Config.EnableChopCard then
            CreateChopCard()
        end
        QBCore.Functions.Notify(Lang:t('text.list_already_exists'), "error")
        return
    end
    GenerateVehicleList()
    if CurrentVehicles ~= nil and next(CurrentVehicles) ~= nil then
        CreateDropOffZone()
        local vehicleList = "\n"
        local vlist2 = "Car List:<br />"
        local counter = 1
        for k, v in pairs(CurrentVehicles) do
            if CurrentVehicles[k] ~= nil then
                local vehicleInfo = QBCore.Shared.Vehicles[v]
                if vehicleInfo ~= nil then
                    vehicleList = vehicleList  .. counter .. ". " .. vehicleInfo["brand"] .. " " .. vehicleInfo["name"] .. "\n"
                    vlist2 = vlist2  .. counter .. ". " .. vehicleInfo["brand"] .. " " .. vehicleInfo["name"] .. "<br />"
                end
                counter = counter + 1
            end
        end
        if Config.EnableChopCard then
            TriggerServerEvent('noted-chopshop:server:giveChopCard', vlist2)
        else
            TriggerEvent('chat:addMessage', {
                color = {255,255,255},
                multiline = true,
                args = {"Your VehicleList", vehicleList}
            })
        end
    else
        QBCore.Functions.Notify(Lang:t('error.demolish_vehicle'), "error")
    end
end



local IsPlayerNearCoords = function(x, y, z, range)
    local playerx, playery, playerz = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local dist = Vdist(playerx, playery, playerz, x, y, z)
    return dist < range
end

function ScrapVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, true)
    local isIdle = true

    if not QBCore.Functions.HasItem("chopcard", 1) then
        QBCore.Functions.Notify(Lang:t('error.need_list_to_chop'), "error")
        return
    end
    
    if vehicle ~= 0 and vehicle ~= nil then
        if GetPedInVehicleSeat(vehicle, -1) == ped then
            if IsVehicleValid(GetEntityModel(vehicle)) then
                local vehiclePlate = QBCore.Functions.GetPlate(vehicle)
                QBCore.Functions.TriggerCallback('noted-chopshop:checkOwnerVehicle',function(retval)
                    if retval then
                        SetEntityAsMissionEntity(vehicle, true, true)
                        TaskLeaveVehicle(ped, vehicle, 0)
                        FreezeEntityPosition(vehicle, true)
                        SetVehicleDoorsLocked(vehicle, 2)
                        Wait(1500)
                        print("carIndex = ", carIndex)
                        print("CurrentVehicles[carIndex] = ", CurrentVehicles[carIndex])
                        table.remove(CurrentVehicles, carIndex)
                        for _, partInfo in ipairs(ChopParts) do
                            if (not partInfo.condition or partInfo.condition(vehicle)) and not IsVehicleDoorDamaged(vehicle, partInfo.part) then
                                threads +=1
                                CreateThread(function()
                                    print("threads plus 1 = ", threads)
                                    local coords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, partInfo.bone))
                                    local range
                                    if partInfo.bone == 'boot' or partInfo.bone == 'bonnet' then
                                        range = 1.25
                                    else
                                        range = 1
                                    end
                                    while true do
                                        if IsPlayerNearCoords(coords.x, coords.y, coords.z, range) then
                                            Wait(8)
                                            DrawText3Ds(coords.x, coords.y, coords.z, "Press [~g~E~w~] to chop ".. partInfo.text)
                                            if IsPlayerNearCoords(coords.x, coords.y, coords.z, range) and IsControlJustReleased(1, 38) and isIdle then
                                                isIdle = false
                                                break
                                            end
                                        else
                                            Wait(500)
                                        end
                                    end
                                    local playerx, playery, playerz = table.unpack(GetEntityCoords(ped, false))
                                    SetVehicleDoorOpen(vehicle, partInfo.part, false, false)
                                    --[[ if (coords.z-playerz)/(coords.x-playerx) > (playerz-coords.z)/(playerx-coords.x) then
                                        playery = math.atan((coords.z-playerz)/(coords.x-playerx))
                                    else
                                        playery = math.tan((playerz-coords.z)/(playerx-coords.x))
                                    end
                                    SetEntityHeading(ped, playery) ]]
                                    if partInfo.bone == 'boot' or partInfo.bone == 'bonnet' then
                                        LoadAnimDict("mini@repair")
                                        while not HasAnimDictLoaded("mini@repair") do
                                            Wait(100)
                                        end
                                        TaskPlayAnim(ped, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 0, 0, false, false, false)
                                    else
                                        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_WELDING', 0, true)
                                    end
                                    QBCore.Functions.Progressbar("scrap_part", Lang:t('text.demolish_vehicle'), Config.ScrapTime, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {}, {}, {}, function() -- Done
                                        -- Clear the welding task
                                        print("passed point 1")
                                        ClearPedTasks(ped)
                                        print("passed point 2")
                                        if partInfo.isWheel then
                                            SetVehicleTyreBurst(vehicle, partInfo.part, true, 1000.0)
                                        else
                                            SetVehicleDoorBroken(vehicle, partInfo.part, true)
                                        end
                                        print("passed point 3")
                                        threads = threads - 1
                                        isIdle = true
                                        notFinishedChopping = false
                                        print("threads -1 should = ", threads)
                                        TriggerServerEvent("noted-chopshop:server:getSmallRewards")
                                    end, function() -- cancel
                                        ClearPedTasks(ped)
                                        QBCore.Functions.Notify(Lang:t('error.canceled'), "error")
                                        threads = threads - 1
                                        isIdle = true
                                    end)
                                end)
                            end
                        end
                        print("Threads = ", threads)
                        while threads > 0 do
                            Wait(3000)
                        end
                        Wait(3000)
                        DeleteVehicle(vehicle)
                        TriggerServerEvent("noted-chopshop:server:getBigRewards")
                        threads = 0
                        ChopListFinished()
                    else
                        QBCore.Functions.Notify(Lang:t('error.smash_own'), "error")
                    end
                end,vehiclePlate)
            else
                QBCore.Functions.Notify(Lang:t('error.cannot_scrap'), "error")
            end
        else
            QBCore.Functions.Notify(Lang:t('error.not_driver'), "error")
        end
    end
end

function IsVehicleValid(vehicleModel)
    local retval = false
    carIndex = 1
    local counter = 0
    print("starting carIndex = ", carIndex)
    if CurrentVehicles ~= nil and next(CurrentVehicles) ~= nil then
        for k in pairs(CurrentVehicles) do
            print(carIndex .. ".  car = " .. CurrentVehicles[k])
            counter+=1
            if CurrentVehicles[k] ~= nil and GetHashKey(CurrentVehicles[k]) == vehicleModel then
                retval = true
                carIndex = counter
            end
            print("in loop carIndex = ", carIndex)
        end
    end
    return retval
end

CreateThread(function()
	-- sell ped
	local pedModel = 'mp_m_waremech_01'
	RequestModel(pedModel)
	while not HasModelLoaded(pedModel) do Wait(10) end
	local ped = CreatePed(0, pedModel, Config.SellLocation.x, Config.SellLocation.y, Config.SellLocation.z-1.0, Config.SellLocation.w, false, false)
	TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_AA_COFFEE', true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	-- Target
	exports['qb-target']:AddTargetEntity(ped, {
		options = {
			{
				type = "server",
				event = "noted-chopshop:server:sellCarParts",
				icon = 'fas fa-user-secret',
				label = 'Sell Car Parts',
			}
		},
		distance = 2.0
	})
end)

CreateThread(function()
	-- Starter Ped
	local pedModel = 'ig_josef'
	RequestModel(pedModel)
	while not HasModelLoaded(pedModel) do Wait(10) end
	local ped = CreatePed(0, pedModel, Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z-1.0, Config.StartLocation.w, false, false)
	TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	-- Target
	exports['qb-target']:AddTargetEntity(ped, {
		options = {
			{
				type = "client",
				event = "noted-chopshop:client:StartListEmail",
				icon = 'fas fa-user-secret',
				label = 'Start Chop Shop',
			}
		},
		distance = 2.0
	})
end)

RegisterNetEvent("noted-chopshop:client:StartListEmail", function()
	CreateListEmail()
end)

RegisterNetEvent("noted-chopshop:client:checkList")
AddEventHandler("noted-chopshop:client:checkList", function()
    print("checklist has been entered")
    if next(CurrentVehicles) == nil then
        return
    end
    local counter = 1
    local vehicleList = "\n"
    for k, v in pairs(CurrentVehicles) do
        if CurrentVehicles[k] ~= nil then
            local vehicleInfo = QBCore.Shared.Vehicles[v]
            if vehicleInfo ~= nil then
                vehicleList = vehicleList  .. counter .. ". " .. vehicleInfo["brand"] .. " " .. vehicleInfo["name"] .. "\n"
                counter = counter + 1
            end
        end
    end
    TriggerEvent('chat:addMessage', {
        color = {255,255,255},
        multiline = true,
        args = {"Your Chop List", vehicleList}
    })
    print("checklist has finished")
end)



