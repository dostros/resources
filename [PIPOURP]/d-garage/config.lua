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
    restaurant = {"a_m_y_business_01"},
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
    divinparking = {
        label = 'Divin Parking',
        takeVehicle = vector4(101.25, -1073.55, 29.37, 73.33),
        spawnPoint = {
            vector4(111.74, -1080.35, 29.19, 346.44)
        },
        getinpoint = vector3(124.56, -1081.82, 29.19),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
    },
    spanishave = {
        label = 'Spanish Ave Parking',
        takeVehicle = vector4(-1159.46, -739.41, 19.89, 225.21),
        spawnPoint = {
            vector4(-1164.29, -748.7, 19.27, 37.22)
        },
        getinpoint = vector3(-1186.02, -742.5, 20.11),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    caears24 = {
        label = 'Caears 24 Parking',
        takeVehicle = vector4(67.72, 12.39, 69.21, 333.16),
        spawnPoint = {
            vector4(59.29, 27.21, 69.87, 246.28)
        },
        getinpoint = vector3(60.5, 17.41, 69.18),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    lagunapi = {
        label = 'Laguna Parking',
        takeVehicle = vector4(362.13, 297.74, 103.88, 332.79),
        spawnPoint = {
            vector4(378.87, 293.94, 103.2, 174.78)
        },
        getinpoint = vector3(360.09, 290.09, 103.5),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    airportp = {
        label = 'Airport Parking',
        takeVehicle = vector4(-796.68, -2022.87, 9.17, 237.22),
        spawnPoint = {
            vector4(-776.4, -2024.69, 8.87, 237.28)
        },
        getinpoint = vector3(-779.31, -2039.54, 8.88),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    beachp = {
        label = 'Beach Parking',
        takeVehicle = vector4(-1184.91, -1510.02, 4.65, 307.14),
        spawnPoint = {
            vector4(-1188.14, -1487.95, 3.97, 124.06)
        },
        getinpoint = vector3(-1182.74, -1495.6, 4.38),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    themotorhotel = {
        label = 'The Motor Hotel Parking',
        takeVehicle = vector4(1141.13, 2664.6, 38.16, 97.18),
        spawnPoint = {
            vector4(1113.47, 2657.76, 38.0, 274.95)
        },
        getinpoint = vector3(1131.79, 2648.34, 38.0),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    liqourparking = {
        label = 'Liqour Parking',
        takeVehicle = vector4(902.66, 3642.86, 32.7, 91.92),
        spawnPoint = {
            vector4(890.11, 3659.89, 32.83, 182.42)
        },
        getinpoint = vector3(899.72, 3645.7, 32.76),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    haanparking = {
        label = 'Bell Farms Parking',
        takeVehicle = vector4(57.0, 6394.93, 31.39, 218.77),
        spawnPoint = {
            vector4(62.15, 6403.41, 30.81, 211.38)
        },
        getinpoint = vector3(66.26, 6379.78, 31.24),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
    dumbogarage = {
        label = 'Dumbo Private Parking',
        takeVehicle = vector4(160.1, -3227.21, 5.99, 270.63),
        spawnPoint = {
            vector4(166.8, -3236.18, 5.87, 269.36)
        },
        getinpoint = vector3(166.26, -3217.74, 5.88),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
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
    grapeseedgarage = {
        label = 'Grapeseed Parking',
        takeVehicle = vector4(2551.06, 4668.99, 34.08, 10.06),
        spawnPoint = {
            vector4(2550.17, 4681.96, 33.81, 17.05)
        },
        getinpoint = vector3(2558.01, 4689.12, 33.96),
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        
    },
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
    ronsrigparking = {
        label = 'Ron\'s Big Rig Parking',
        takeVehicle = vector4(-2524.16, 2319.31, 33.22, 358.13),
        spawnPoint = {
            vector4(-2531.81, 2337.2, 33.06, 207.43)
        },
        getinpoint = vector3(-2524.12, 2343.63, 33.06),
        showBlip = true,
        blipName = 'Big Rig Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'public',
        category = "all"
    },
    ronsrigparking2 = {
        label = 'Ron\'s Big Rig Parking',
        takeVehicle = vector4(2591.88, 417.54, 108.46, 104.44),
        spawnPoint = {
            vector4(2576.84, 416.68, 108.46, 180.84)
        },
        getinpoint = vector3(2588.56, 409.6, 108.46),
        showBlip = true,
        blipName = 'Big Rig Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'public',
        category = "all"
    },
    govgarage = {
        label = 'Government Parking',
        takeVehicle = vector4(-557.72, -165.86, 38.31, 21.58),
        spawnPoint = {
            vector4(-558.7, -161.7, 38.17, 290.4)
        },
        getinpoint = vector3(-571.86, -167.74, 37.99),
        showBlip = false,
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
        showBlip = false,
        blipName = 'Gov Helipad',
        blipNumber = 357,
        blipColor = 1,
        type = 'job', -- public, gang, job, depot
        job='government',
        category="air"
    },
    restaurantgarage = {
        label = 'Restaurant Parking',
        takeVehicle = vector4(-1339.01, -1099.12, 6.74, 215.79),
        spawnPoint = {
            vector4(-1342.57, -1106.16, 5.84, 302.59)
        },
        getinpoint = vector3(-1351.72, -1111.22, 4.32),
        showBlip = false,
        blipName = 'Restaurant Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'job', -- public, gang, job, depot
        job='restaurant',
    },
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
    realestategarage = {
        label = 'Realestate Parking',
        takeVehicle = vector4(-702.86, 276.63, 83.69, 33.85),
        spawnPoint = {
            vector4(-707.57, 280.55, 84.01, 76.97)
        },
        getinpoint = vector3(-714.58, 279.81, 84.43),
        showBlip = false,
        blipName = 'Realestate Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'job', -- public, gang, job, depot
        job='realestate',
    },
}


