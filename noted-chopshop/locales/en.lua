local Translations = {
    error = {
        smash_own = "You can't smash a vehicle that owns it.",
        cannot_scrap = "This Vehicle Cannot Be Scrapped.",
        not_driver = "You Are Not The Driver",
        demolish_vehicle = "You Are Not Allowed To Demolish Vehicles Now",
        canceled = "Canceled",
        need_list_to_chop = "You need your choplist to chop cars",
    },
    text = {
        demolish_vehicle = "Demolish Vehicle",
        list_already_exists = "You already have a list.",
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
