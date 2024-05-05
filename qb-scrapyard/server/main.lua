local QBCore = exports['qb-core']:GetCoreObject()


QBCore.Functions.CreateCallback('qb-scrapyard:checkOwnerVehicle', function(_, cb, plate)
    local result = MySQL.scalar.await("SELECT `plate` FROM `player_vehicles` WHERE `plate` = ?",{plate})
    if result then
        cb(false)
    else
        cb(true)
    end
end)

RegisterNetEvent('qb-scrapyard:server:sellCarParts', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
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

RegisterNetEvent('qb-scrapyard:server:getSmallRewards', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local total = math.random(Config.SmallRewardsMin, Config.SmallRewardsMax)
    local itemIndex = 0
    local itemAmount = 0
    while total > 0 do
        itemIndex = math.random(1, #Config.SmallRewardsTable)
        itemAmount = math.random(Config.SmallRewardsTable[total].min, Config.SmallRewardsTable[total].max)
        Player.Functions.AddItem(Config.SmallRewardsTable[total].itemName, itemAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.SmallRewardsTable[total].itemName], 'add', itemAmount)
        total = total - 1
    end
end)

if Config.EnableChopCard then
    RegisterNetEvent('qb-scrapyard:server:giveChopCard', function(text)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        info = {}
        info.text = text
        Player.Functions.AddItem("chopcard", 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["chopcard"], 'add', 1)
    end)
end

RegisterNetEvent('qb-scrapyard:server:getBigRewards', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local total = math.random(Config.BigRewardsMin, Config.BigRewardsMax)
    local itemIndex = 0
    local itemAmount = 0
    while total > 0 do
        itemIndex = math.random(1, #Config.BigRewardsTable)
        itemAmount = math.random(Config.BigRewardsTable[total].min, Config.BigRewardsTable[total].max)
        Player.Functions.AddItem(Config.BigRewardsTable[total].itemName, itemAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.BigRewardsTable[total].itemName], 'add', itemAmount)
        total = total - 1
    end
end)


if Config.Testing then
    RegisterCommand("cs", function(source, CurrentVehicles)
        TriggerClientEvent("qb-scrapyard:client:StartListEmail", source)
    end, false)
end


if Config.EnableChopCard == false then
    RegisterCommand(Config.CheckListCommand, function(source)
        TriggerClientEvent("qb-scrapyard:client:checkList", source)
    end, false)
end
