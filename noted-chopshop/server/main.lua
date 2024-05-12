local QBCore = exports['qb-core']:GetCoreObject()


QBCore.Functions.CreateCallback('noted-chopshop:checkOwnerVehicle', function(_, cb, plate)
    local result = MySQL.scalar.await("SELECT `plate` FROM `player_vehicles` WHERE `plate` = ?",{plate})
    if result then
        cb(false)
    else
        cb(true)
    end
end)

--[[ local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end 
end ]]

RegisterNetEvent('noted-chopshop:server:sellCarParts', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    --[[ print("Player = ")
    dump(Player) ]]
    local i = 1
    while i <= #Config.SellableItems do
        local itemName = Config.SellableItems[i].itemName
        if itemName then
            local item = Player.Functions.GetItemByName(itemName)
            if item then
                Wait(100)
                Player.Functions.RemoveItem(itemName, item.amount)
                if Config.SellableItems[i].paymentType == "cash" then
                    Player.Functions.AddMoney('cash', item.amount * (Config.SellableItems[i].price), 'sold-carparts')
                else
                    Player.Functions.AddItem(Config.SellableItems[i].paymentType, item.amount * Config.SellableItems[i].price)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.SellableItems[i].paymentType], 'add', item.amount * (Config.SellableItems[i].price))
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'remove', item.amount)
                end
            end
            i = i + 1
        end
    end
end)

RegisterNetEvent('noted-chopshop:server:getSmallRewards', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local total = math.random(Config.SmallRewardsMin, Config.SmallRewardsMax)
    local itemIndex = 0
    local itemAmount = 0
    while total > 0 do
        itemIndex = math.random(1, #Config.SmallRewardsTable)
        itemAmount = math.random(Config.SmallRewardsTable[itemIndex].min, Config.SmallRewardsTable[itemIndex].max)
        Player.Functions.AddItem(Config.SmallRewardsTable[itemIndex].itemName, itemAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.SmallRewardsTable[itemIndex].itemName], 'add', itemAmount)
        total = total - 1
    end
end)

if Config.EnableChopCard then
    RegisterNetEvent('noted-chopshop:server:giveChopCard', function(text)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        info = {}
        info.text = text
        Player.Functions.AddItem("chopcard", 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["chopcard"], 'add', 1)
    end)
end

RegisterNetEvent('noted-chopshop:server:getBigRewards', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local total = math.random(Config.BigRewardsMin, Config.BigRewardsMax)
    local itemIndex = 0
    local itemAmount = 0
    while total > 0 do
        itemIndex = math.random(1, #Config.BigRewardsTable)
        itemAmount = math.random(Config.BigRewardsTable[itemIndex].min, Config.BigRewardsTable[itemIndex].max)
        Player.Functions.AddItem(Config.BigRewardsTable[itemIndex].itemName, itemAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.BigRewardsTable[itemIndex].itemName], 'add', itemAmount)
        total = total - 1
    end
end)


if Config.Testing then
    RegisterCommand("cs", function(source, CurrentVehicles)
        TriggerClientEvent("noted-chopshop:client:StartListEmail", source)
    end, false)
end


if Config.EnableChopCard == false then
    RegisterCommand(Config.CheckListCommand, function(source)
        TriggerClientEvent("noted-chopshop:client:checkList", source)
    end, false)
end
