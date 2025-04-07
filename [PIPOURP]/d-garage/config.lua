Config = {}

Config.VehicleClass = {
    all = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22 },
    car = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 18, 22 },
    air = { 15, 16 },
    sea = { 14 },
    rig = { 10, 11, 17, 19, 20 }
}

Config.GaragePed = {
    default = {'{"components":{"7":[22,4],"8":[26,7],"9":[0,0],"3":[1,0],"4":[22,7],"5":[0,0],"6":[21,0],"0":[0,0],"1":[0,0],"2":[7,4],"11":[4,2],"10":[0,0]},"model":1885233650,"props":{"7":[-1,-1],"0":[-1,-1],"1":[6,0],"2":[-1,-1],"3":[-1,-1],"4":[-1,-1],"5":[-1,-1],"6":[-1,-1]}}'},
    ballas = {"csb_ballasog"},
    vagos = {"g_m_y_mexgoon_01"},
    families = {"g_m_y_famdnf_01"},
    lostmc = {"g_m_y_lost_02"},
    cartel = {"cs_martinmadrazo"},
    police = {"s_m_y_cop_01"},
    government = {"cs_fbisuit_01"},
    timber = {"a_m_m_farmer_01"},
}

Config.Garages = {
    motelgarage = {
        label = 'Motel Parking',
        takeVehicle = vector4(275.42, -345.58, 45.15, 341.76),
        spawnPoint = {
            vector4(265.96, -332.3, 44.51, 250.68)
        },
        getinpoint = vector3(276.54, -339.77, 44.92),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public', -- public, gang, job, depot
        
    },
    casinogarage = {
        label = 'Casino Parking',
        takeVehicle = vector4(886.7, -0.31, 78.76, 149.08),
        spawnPoint = {
            vector4(895.39, -4.75, 78.35, 146.85)
        },
        getinpoint = vector3(894.39, -5.83, 78.76),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    sapcounsel = {
        label = 'San Andreas Parking',
        takeVehicle = vector4(-330.82, -780.95, 33.97, 30.89),
        spawnPoint = {
            vector4(-341.57, -767.45, 33.56, 92.61)
        },
        getinpoint = vector3(-357.28, -775.79, 33.97),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
    },
    -- spanishave = {
    --     label = 'Spanish Ave Parking',
    --     takeVehicle = vector3(-1160.86, -741.41, 19.63),
    --     spawnPoint = {
    --         vector4(-1145.2, -745.42, 19.26, 108.22)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- caears24 = {
    --     label = 'Caears 24 Parking',
    --     takeVehicle = vector3(69.84, 12.6, 68.96),
    --     spawnPoint = {
    --         vector4(60.8, 17.54, 68.82, 339.7)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- caears242 = {
    --     label = 'Caears 24 Parking',
    --     takeVehicle = vector3(-453.7, -786.78, 30.56),
    --     spawnPoint = {
    --         vector4(-472.39, -787.71, 30.14, 180.52)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- lagunapi = {
    --     label = 'Laguna Parking',
    --     takeVehicle = vector3(364.37, 297.83, 103.49),
    --     spawnPoint = {
    --         vector4(375.09, 294.66, 102.86, 164.04)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- airportp = {
    --     label = 'Airport Parking',
    --     takeVehicle = vector3(-773.12, -2033.04, 8.88),
    --     spawnPoint = {
    --         vector4(-779.77, -2040.18, 8.47, 315.34)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- beachp = {
    --     label = 'Beach Parking',
    --     takeVehicle = vector3(-1185.32, -1500.64, 4.38),
    --     spawnPoint = {
    --         vector4(-1188.14, -1487.95, 3.97, 124.06)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- themotorhotel = {
    --     label = 'The Motor Hotel Parking',
    --     takeVehicle = vector3(1137.77, 2663.54, 37.9),
    --     spawnPoint = {
    --         vector4(1127.7, 2647.84, 37.58, 1.41)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- liqourparking = {
    --     label = 'Liqour Parking',
    --     takeVehicle = vector3(883.99, 3649.67, 32.87),
    --     spawnPoint = {
    --         vector4(898.38, 3649.41, 32.36, 90.75)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- shoreparking = {
    --     label = 'Shore Parking',
    --     takeVehicle = vector3(1737.03, 3718.88, 34.05),
    --     spawnPoint = {
    --         vector4(1725.4, 3716.78, 34.15, 20.54)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- haanparking = {
    --     label = 'Bell Farms Parking',
    --     takeVehicle = vector3(76.88, 6397.3, 31.23),
    --     spawnPoint = {
    --         vector4(62.15, 6403.41, 30.81, 211.38)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- dumbogarage = {
    --     label = 'Dumbo Private Parking',
    --     takeVehicle = vector3(165.75, -3227.2, 5.89),
    --     spawnPoint = {
    --         vector4(168.34, -3236.1, 5.43, 272.05)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    pillboxgarage = {
        label = 'Pillbox Garage Parking',
        takeVehicle = vector4(214.0, -808.61, 31.00, 155.53),
        spawnPoint = {
            vector4(222.02, -804.19, 30.26, 248.19),
            vector4(223.93, -799.11, 30.25, 248.53),
            vector4(226.46, -794.33, 30.24, 248.29),
            vector4(232.33, -807.97, 30.02, 69.17),
            vector4(234.42, -802.76, 30.04, 67.2)
        },
        getinpoint = vector3(208.56, -795.93, 30.96),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    -- grapeseedgarage = {
    --     label = 'Grapeseed Parking',
    --     takeVehicle = vector3(2552.68, 4671.8, 33.95),
    --     spawnPoint = {
    --         vector4(2550.17, 4681.96, 33.81, 17.05)
    --     },
    --     showBlip = true,
    --     blipName = 'Public Parking',
    --     blipNumber = 357,
    --     blipColor = 3,
    --     type = 'public',
        
    -- },
    -- depotLot = {
    --     label = 'Depot Lot',
    --     takeVehicle = vector3(401.76, -1632.57, 29.29),
    --     spawnPoint = {
    --         vector4(396.55, -1643.93, 28.88, 321.91)
    --     },
    --     showBlip = true,
    --     blipName = 'Depot Lot',
    --     blipNumber = 68,
    --     blipColor = 3,
    --     type = 'depot',
        
    -- },
    ballas = {
        label = 'Ballas',
        takeVehicle = vector4(109.18, -1952.87, 20.8, 85.64),
        spawnPoint = {
            vector4(93.78, -1961.73, 20.34, 319.11)
        },
        getinpoint = vector3(104.76, -1956.29, 20.75),
        showBlip = false,
        blipName = 'Ballas',
        blipNumber = 357,
        blipColor = 3,
        type = 'gang',
        gang = 'ballas',
    },
    families = {
        label = 'Families',
        takeVehicle = vector4(-184.56, -1581.65, 35.3, 178.77),
        spawnPoint = {
            vector4(-185.2, -1586.08, 35.0, 232.89)
        },
        getinpoint =vector3(-185.28, -1593.11, 34.47),
        showBlip = false,
        blipName = 'Families',
        blipNumber = 357,
        blipColor = 3,
        type = 'gang',
        gang = 'families'
    },
    lostmc = {
        label = 'Lost MC',
        takeVehicle = vector4(977.53, -136.68, 74.12, 110.04),
        spawnPoint = {
            vector4(977.65, -133.02, 73.34, 59.39)
        },
        getinpoint =vector3(974.05, -140.06, 74.26),
        showBlip = false,
        blipName = 'Lost MC',
        blipNumber = 357,
        blipColor = 3,
        type = 'gang',
        job = 'lostmc',
        gang = 'lostmc'
    },
    cartel = {
        label = 'Cartel',
        takeVehicle = vector4(1410.4, 1114.99, 114.84, 354.5),
        spawnPoint = {
            vector4(1403.01, 1118.25, 114.84, 88.69)
        },
        getinpoint = vector3(1414.62, 1120.75, 114.84),
        showBlip = false,
        blipName = 'Cartel',
        blipNumber = 357,
        blipColor = 3,
        type = 'gang',
        gang = 'cartel'
    },
    police = {
        label = 'Police',
        takeVehicle = vector4(457.91, -1024.96, 28.42, 31.28),
        spawnPoint = {
            vector4(446.16, -1025.79, 28.23, 6.59)
        },
        getinpoint = vector3(450.69, -1025.58, 28.56),
        showBlip = false,
        blipName = 'Police',
        blipNumber = 357,
        blipColor = 3,
        type = 'job',
        job = 'police',
        jobType = 'leo'
    },
    -- intairport = {
    --     label = 'Airport Hangar',
    --     takeVehicle = vector3(-979.06, -2995.48, 13.95),
    --     spawnPoint = {
    --         vector4(-998.37, -2985.01, 13.95, 61.09)
    --     },
    --     showBlip = true,
    --     blipName = 'Hangar',
    --     blipNumber = 360,
    --     blipColor = 3,
    --     type = 'public',
    --     category = "air"
    -- },
    -- higginsheli = {
    --     label = 'Higgins Helitours',
    --     takeVehicle = vector3(-722.15, -1472.79, 5.0),
    --     spawnPoint = {
    --         vector4(-745.22, -1468.72, 5.39, 319.84),
    --         vector4(-724.36, -1443.61, 5.39, 135.78)
    --     },
    --     showBlip = true,
    --     blipName = 'Hangar',
    --     blipNumber = 360,
    --     blipColor = 3,
    --     type = 'public',
    --     category = "air"
    -- },
    -- airsshores = {
    --     label = 'Sandy Shores Hangar',
    --     takeVehicle = vector3(1737.89, 3288.13, 41.14),
    --     spawnPoint = {
    --         vector4(1742.83, 3266.83, 41.24, 102.64)
    --     },
    --     showBlip = true,
    --     blipName = 'Hangar',
    --     blipNumber = 360,
    --     blipColor = 3,
    --     type = 'public',
    --     category = "air"
    -- },
    -- airzancudo = {
    --     label = 'Fort Zancudo Hangar',
    --     takeVehicle = vector3(-1828.25, 2975.44, 32.81),
    --     spawnPoint = {
    --         vector4(-1828.25, 2975.44, 32.81, 57.24)
    --     },
    --     showBlip = true,
    --     blipName = 'Hangar',
    --     blipNumber = 360,
    --     blipColor = 3,
    --     type = 'public',
    --     category = "air"
    -- },
    -- airdepot = {
    --     label = 'Air Depot',
    --     takeVehicle = vector3(-1270.01, -3377.53, 14.33),
    --     spawnPoint = {
    --         vector4(-1270.01, -3377.53, 14.33, 329.25)
    --     },
    --     showBlip = true,
    --     blipName = 'Air Depot',
    --     blipNumber = 359,
    --     blipColor = 3,
    --     type = 'depot',
    --     category = "air"
    -- },
    -- lsymc = {
    --     label = 'LSYMC Boathouse',
    --     takeVehicle = vector3(-785.95, -1497.84, -0.09),
    --     spawnPoint = {
    --         vector4(-796.64, -1502.6, -0.09, 111.49)
    --     },
    --     showBlip = true,
    --     blipName = 'Boathouse',
    --     blipNumber = 356,
    --     blipColor = 3,
    --     type = 'public',
    --     category = "sea"
    -- },
    -- paleto = {
    --     label = 'Paleto Boathouse',
    --     takeVehicle = vector3(-278.21, 6638.13, 7.55),
    --     spawnPoint = {
    --         vector4(-289.2, 6637.96, 1.01, 45.5)
    --     },
    --     showBlip = true,
    --     blipName = 'Boathouse',
    --     blipNumber = 356,
    --     blipColor = 3,
    --     type = 'public',
    --     category = "sea"
    -- },
    -- millars = {
    --     label = 'Millars Boathouse',
    --     takeVehicle = vector3(1298.56, 4212.42, 33.25),
    --     spawnPoint = {
    --         vector4(1297.82, 4209.61, 30.12, 253.5)
    --     },
    --     showBlip = true,
    --     blipName = 'Boathouse',
    --     blipNumber = 356,
    --     blipColor = 3,
    --     type = 'public',
    --     category = "sea"
    -- },
    -- seadepot = {
    --     label = 'LSYMC Depot',
    --     takeVehicle = vector3(-742.95, -1407.58, 5.5),
    --     spawnPoint = {
    --         vector4(-729.77, -1355.49, 1.19, 142.5)
    --     },
    --     showBlip = true,
    --     blipName = 'LSYMC Depot',
    --     blipNumber = 356,
    --     blipColor = 3,
    --     type = 'depot',
    --     category = "sea"
    -- },
    -- rigdepot = {
    --     label = 'Big Rig Depot',
    --     takeVehicle = vector3(2334.42, 3118.62, 48.2),
    --     spawnPoint = {
    --         vector4(2324.57, 3117.79, 48.21, 4.05)
    --     },
    --     showBlip = true,
    --     blipName = 'Big Rig Depot',
    --     blipNumber = 68,
    --     blipColor = 2,
    --     type = 'depot',
    --     category = "all"
    -- },
    -- dumborigparking = {
    --     label = 'Dumbo Big Rig Parking',
    --     takeVehicle = vector3(161.23, -3188.73, 5.97),
    --     spawnPoint = {
    --         vector4(167.0, -3203.89, 5.94, 271.27)
    --     },
    --     showBlip = true,
    --     blipName = 'Big Rig Parking',
    --     blipNumber = 357,
    --     blipColor = 2,
    --     type = 'public',
    --     category = "all"
    -- },
    -- popsrigparking = {
    --     label = 'Pop\'s Big Rig Parking',
    --     takeVehicle = vector3(137.67, 6632.99, 31.67),
    --     spawnPoint = {
    --         vector4(127.69, 6605.84, 31.93, 223.67)
    --     },
    --     showBlip = true,
    --     blipName = 'Big Rig Parking',
    --     blipNumber = 357,
    --     blipColor = 2,
    --     type = 'public',
    --     category = "all"
    -- },
    -- ronsrigparking = {
    --     label = 'Ron\'s Big Rig Parking',
    --     takeVehicle = vector3(-2529.37, 2342.67, 33.06),
    --     spawnPoint = {
    --         vector4(-2521.61, 2326.45, 33.13, 88.7)
    --     },
    --     showBlip = true,
    --     blipName = 'Big Rig Parking',
    --     blipNumber = 357,
    --     blipColor = 2,
    --     type = 'public',
    --     category = "all"
    -- },
    -- ronsrigparking2 = {
    --     label = 'Ron\'s Big Rig Parking',
    --     takeVehicle = vector3(2561.67, 476.68, 108.49),
    --     spawnPoint = {
    --         vector4(2561.67, 476.68, 108.49, 177.86)
    --     },
    --     showBlip = true,
    --     blipName = 'Big Rig Parking',
    --     blipNumber = 357,
    --     blipColor = 2,
    --     type = 'public',
    --     category = "all"
    -- },
    -- ronsrigparking3 = {
    --     label = 'Ron\'s Big Rig Parking',
    --     takeVehicle = vector3(-41.24, -2550.63, 6.01),
    --     spawnPoint = {
    --         vector4(-39.39, -2527.81, 6.08, 326.18)
    --     },
    --     showBlip = true,
    --     blipName = 'Big Rig Parking',
    --     blipNumber = 357,
    --     blipColor = 2,
    --     type = 'public',
    --     category = "all"
    -- },

    govgarage = {
        label = 'Government Parking',
        takeVehicle = vector4(-557.72, -165.86, 38.31, 21.58),
        spawnPoint = {
            vector4(-558.7, -161.7, 38.17, 290.4)
        },
        getinpoint = vector3(-571.86, -167.74, 37.99),
        showBlip = true,
        blipName = 'Gov Parking',
        blipNumber = 357,
        blipColor = 1,
        type = 'job', -- public, gang, job, depot
        job='government',
        
    },

    govhelipad = {
        label = 'Government Helipad',
        takeVehicle = vector4(-511.88, -221.52, 36.75, 219.1),
        spawnPoint = {
            vector4(-500.48, -237.98, 36.24, 212.79)
        },
        getinpoint = vector3(-505.41, -231.09, 36.43),
        showBlip = true,
        blipName = 'Gov Helipad',
        blipNumber = 357,
        blipColor = 1,
        type = 'job', -- public, gang, job, depot
        job='government',
        category="air"
    },

    -- restaurantgarage = {
    --     label = 'Restaurant Parking',
    --     takeVehicle = vector4(-1339.08, -1099.44, 6.72, 193.59),
    --     spawnPoint = {
    --         vector4(-1344.44, -1105.93, 5.53, 289.35)
    --     },
    --     showBlip = false,
    --     blipName = 'Restaurant Parking',
    --     blipNumber = 357,
    --     blipColor = 2,
    --     type = 'job', -- public, gang, job, depot
    --     job='restaurant',
        
    -- },

    timbergarage = {
        label = 'timber Parking',
        takeVehicle = vector4(-570.93, 5364.8, 70.2, 250.64),
        spawnPoint = {
            vector4(-574.94, 5373.8, 70.24, 258.72)
        },
        getinpoint = vector3(-568.01, 5378.23, 70.18),
        showBlip = false,
        blipName = 'timber Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'job', -- public, gang, job, depot
        job='timber',
    },
}


