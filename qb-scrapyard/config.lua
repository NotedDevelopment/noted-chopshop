Config = {}

Config.StartLocation = vector4(2339.44, 3051.93, 48.15, 273.39)
Config.SellLocation = vector4(2343.44, 3051.93, 48.15, 273.39)

Config.ScrapTime = 2000
Config.HoodScrapAnimation = 'mini@repair'
Config.DoorScrapAnimation = 'amb@world_human_welding@male@base'
Config.EnableChopCard = true
Config.Testing = true

Config.SellableItems = {
    {itemName = "metalscrap", paymentType = "cash", price = 100},
    {itemName = "plastic", paymentType = "loosenotes", price = 25},
    {itemName = "copper", paymentType = "loosenotes", price = 10},
    {itemName = "glass", paymentType = "loosenotes", price = 30},
    {itemName = "rubber", paymentType = "cash", price = 50},
}

Config.SmallRewardsMin = 1
Config.SmallRewardsMax = 3
Config.SmallRewardsTable = {
    {itemName = "metalscrap", min = 2, max = 4},
    {itemName = "plastic",  min = 3, max = 6},
    {itemName = "copper",  min = 1, max = 3},
    {itemName = "glass",  min = 2, max = 2},
    {itemName = "rubber",  min = 1, max = 3},
}

Config.BigRewardsMin = 2
Config.BigRewardsMax = 5
Config.BigRewardsTable = {
    {itemName = "metalscrap", min = 2, max = 4},
    {itemName = "plastic",  min = 3, max = 6},
    {itemName = "copper",  min = 1, max = 3},
    {itemName = "glass",  min = 2, max = 2},
    {itemName = "rubber",  min = 1, max = 3},
}

Config.Dol = {
    vector3(-378.5, 184.5, 80.75), -- #1
    vector3(1132.5, -795, 57.6), -- #2 
    vector3(-187, -1362, 31.26), -- #3
    vector3(-1346, -892.5, 13.6), -- #4
    vector3(947, -1697.8, 30), -- #5
    vector3(1507, -2100.5, 77), -- #6
}
Config.DolLength = {
    24.0, -- #1
    12.0, -- #2 
    14.0, -- #3
    14.0, -- #4
    6.0, -- #5
    18.0, -- #6
}
Config.DolWidth = {
    18.0, -- #1
    17.0, -- #2 
    12.0, -- #3
    9.0,  -- #4
    7.0, -- #5
    23.0, -- #6
}

Config.CheckListCommand = "checklist"

Config.VehicleCountMin = 4
Config.VehicleCountMax = 6
Config.CurrentVehicles = {}

Config.Vehicles = {
    [1] = "ninef",
    [2] = "ninef2",
    [3] = "banshee",
    [4] = "alpha",
    [5] = "baller",
    [6] = "bison",
    [7] = "huntley",
    [8] = "f620",
    [9] = "asea",
    [10] = "pigalle",
    [11] = "bullet",
    [12] = "turismor",
    [13] = "zentorno",
    [14] = "dominator",
    [15] = "blade",
    [16] = "chino",
    [17] = "sabregt",
    [18] = "bati",
    [19] = "carbonrs",
    [20] = "akuma",
    [21] = "thrust",
    [22] = "exemplar",
    [23] = "felon",
    [24] = "sentinel",
    [25] = "blista",
    [26] = "fusilade",
    [27] = "jackal",
    [28] = "blista2",
    [29] = "rocoto",
    [30] = "seminole",
    [31] = "landstalker",
    [32] = "picador",
    [33] = "prairie",
    [34] = "bobcatxl",
    [35] = "gauntlet",
    [36] = "virgo",
    [37] = "fq2",
    [38] = "jester",
    [39] = "rhapsody",
    [40] = "feltzer2",
    [41] = "buffalo",
    [42] = "buffalo2",
    [43] = "stretch",
    [44] = "ratloader2",
    [45] = "ruiner",
    [46] = "rebel",
    [47] = "slamvan",
    [48] = "zion",
    [49] = "zion2",
    [50] = "tampa",
    [51] = "sultan",
    [52] = "asbo",
    [53] = "panto",
    [54] = "oracle",
    [55] = "oracle2",
    [56] = "sentinel2",
    [57] = "baller2",
    [58] = "schafter2",
    [59] = "schwarzer",
    [60] = "cavalcade",
    [61] = "cavalcade2",
    [62] = "comet2",
    [63] = "serrano",
    [64] = "tailgater",
    [65] = "sandking",
    [66] = "sandking2",
    [67] = "cognoscenti",
    [68] = "stanier",
    [69] = "washington",
}
