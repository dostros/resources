Config = {}
Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'
Config.FuelResource = 'LegacyFuel' -- supports any that has a GetFuel() and SetFuel() export



Config.Objects = {
    ['corde'] = { model = `prop_cs_heist_rope`, freeze = true },
}



