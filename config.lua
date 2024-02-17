Config = Config or {}
Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.VTC = {
    general = {
        speed_unit = "MPH",                 --can be KPH or MPH (this will affect min/max speed constraint)
        job_required = "uverx_driver",      --The needed job for being a VTC driver (nil means no job)
        item_required = "uverx_license",    --The needed item for being a VTC driver (nil means no item)
    },
    course = {
        availability_time_npc = 10000,      --Number of milliseconds after a NPC Course will be remove from list
        availability_time_player = 20000,   --Number of milliseconds after a Player Course will be remove from list
        malus_interval = 100,               --Calculation ticks for malus (milliseconds)
        malus = {
            to_fast=0.05,    --Malus for overspeeding
            to_slow=0.05,    --Malus for underspeeding
            away=0.1,        --Malus when driver is out from the car
            damage=2.0,      --Malus during car damage
            music=0.1,       --Malus for wrong music needs
        }
    },
    generator = {
        min_wait_time = 3000,               --Min time before the next NPC course generation
        max_wait_time = 15000,              --Max time before the next NPC course generation
        peds_radius_spawn = 3,              --Radius for NPC peds to spawn around the location
        max_number_of_ped = 3,              --Max number of Peds generated for 1 course
        money_per_meter = 0.5,              --Money gained per meters in the course
        min_distance = 500,                 --Minimum distance between the pickup location and destination
        range_min_maxspeed = 80,            --Minimum Max Speed for max speed constraint on NPC courses
        range_max_maxspeed = 120,           --Maximum Max Speed for max speed constraint on NPC courses
        range_min_minspeed = 20,            --Minimum Min Speed for min speed constraint on NPC courses
        range_max_minspeed = 50,            --Maximum Min Speed for min speed constraint on NPC courses
        -- List of peds model used for spawning NPCs
        --Be careful : If you add new peds, you need to generate the peds hashes list (see the doc)
        peds_model = {
            'a_f_m_skidrow_01',
            'a_f_m_soucentmc_01',
            'a_f_m_soucent_01',
            'a_f_m_soucent_02',
            'a_f_m_tourist_01',
            'a_f_m_trampbeac_01',
            'a_f_m_tramp_01',
            'a_f_o_genstreet_01',
            'a_f_o_indian_01',
            'a_f_o_ktown_01',
            'a_f_o_salton_01',
            'a_f_o_soucent_01',
            'a_f_o_soucent_02',
            'a_f_y_beach_01',
            'a_f_y_bevhills_01',
            'a_f_y_bevhills_02',
            'a_f_y_bevhills_03',
            'a_f_y_bevhills_04',
            'a_f_y_business_01',
            'a_f_y_business_02',
            'a_f_y_business_03',
            'a_f_y_business_04',
            'a_f_y_eastsa_01',
            'a_f_y_eastsa_02',
            'a_f_y_eastsa_03',
            'a_f_y_epsilon_01',
            'a_f_y_fitness_01',
            'a_f_y_fitness_02',
            'a_f_y_genhot_01',
            'a_f_y_golfer_01',
            'a_f_y_hiker_01',
            'a_f_y_hipster_01',
            'a_f_y_hipster_02',
            'a_f_y_hipster_03',
            'a_f_y_hipster_04',
            'a_f_y_indian_01',
            'a_f_y_juggalo_01',
            'a_f_y_runner_01',
            'a_f_y_rurmeth_01',
            'a_f_y_scdressy_01',
            'a_f_y_skater_01',
            'a_f_y_soucent_01',
            'a_f_y_soucent_02',
            'a_f_y_soucent_03',
            'a_f_y_tennis_01',
            'a_f_y_tourist_01',
            'a_f_y_tourist_02',
            'a_f_y_vinewood_01',
            'a_f_y_vinewood_02',
            'a_f_y_vinewood_03',
            'a_f_y_vinewood_04',
            'a_f_y_yoga_01',
            'g_f_y_ballas_01',
            'ig_barry',
            'ig_bestmen',
            'ig_beverly',
            'ig_car3guy1',
            'ig_car3guy2',
            'ig_casey',
            'ig_chef',
            'ig_chengsr',
            'ig_chrisformage',
            'ig_clay',
            'ig_claypain',
            'ig_cletus',
            'ig_dale',
            'ig_dreyfuss',
            'ig_fbisuit_01',
            'ig_floyd',
            'ig_groom',
            'ig_hao',
            'ig_hunter',
            'csb_prolsec',
            'ig_joeminuteman',
            'ig_josef',
            'ig_josh',
            'ig_lamardavis',
            'ig_lazlow',
            'ig_lestercrest',
            'ig_lifeinvad_01',
            'ig_lifeinvad_02',
            'ig_manuel',
            'ig_milton',
            'ig_mrk',
            'ig_nervousron',
            'ig_nigel',
            'ig_old_man1a',
            'ig_old_man2',
            'ig_oneil',
            'ig_orleans',
            'ig_ortega',
            'ig_paper',
            'ig_priest',
            'ig_prolsec_02',
            'ig_ramp_gang',
            'ig_ramp_hic',
            'ig_ramp_hipster',
            'ig_ramp_mex',
            'ig_roccopelosi',
            'ig_russiandrunk',
            'ig_siemonyetarian',
            'ig_solomon',
            'ig_stevehains',
            'ig_stretch',
            'ig_talina',
            'ig_taocheng',
            'ig_taostranslator',
            'ig_tenniscoach',
            'ig_terry',
            'ig_tomepsilon',
            'ig_tylerdix',
            'ig_wade',
            'ig_zimbor',
            's_m_m_paramedic_01',
            'a_m_m_afriamer_01',
            'a_m_m_beach_01',
            'a_m_m_beach_02',
            'a_m_m_bevhills_01',
            'a_m_m_bevhills_02',
            'a_m_m_business_01',
            'a_m_m_eastsa_01',
            'a_m_m_eastsa_02',
            'a_m_m_farmer_01',
            'a_m_m_fatlatin_01',
            'a_m_m_genfat_01',
            'a_m_m_genfat_02',
            'a_m_m_golfer_01',
            'a_m_m_hasjew_01',
            'a_m_m_hillbilly_01',
            'a_m_m_hillbilly_02',
            'a_m_m_indian_01',
            'a_m_m_ktown_01',
            'a_m_m_malibu_01',
            'a_m_m_mexcntry_01',
            'a_m_m_mexlabor_01',
            'a_m_m_og_boss_01',
            'a_m_m_paparazzi_01',
            'a_m_m_polynesian_01',
            'a_m_m_prolhost_01',
            'a_m_m_rurmeth_01',
        },
    },
    player = {
        commission = 0.3                    --Percentage of money that will be earned by the player for a course (NPC or Player). 0.3 = 30%
    }
}

-- List of allowed pickup and destination coords
Config.VTCLocations = {
    vector3(306.39, -234.31, 54.07),
    vector3(245.48, -378.46, 44.49),
    vector3(58.47, -278.59, 47.46),
    vector3(-110.04, -609.51, 36.28),
    vector3(-715.72, -1295.26, 5.1),
    vector3(-1080.98, -1045.28, 2.15),
    vector3(-1631.79, -1003.3, 13.04),
    vector3(-3021.04, 84.29, 11.67),
    vector3(-3172.58, 1294.82, 14.28),
    vector3(-253.31, 2190.21, 130.11),
    vector3(734.4, 2523.83, 73.23),
    vector3(1684.41, 4787.57, 41.94),
    vector3(3324.34, 5158.19, 18.41),
    vector3(-12.43, 6648.38, 31.07),
    vector3(-427.02, 6027.99, 31.49),
    vector3(-1031.51, 4932.85, 203.04),
    vector3(-1905.15, 2064.89, 140.84),
    vector3(-1035.44, -2736.82, 20.17),
    vector3(-1027.91, -2732.69, 13.76),
    vector3(-1081.73, -2694.02, 13.76),
    vector3(-213.43, -1997.88, 27.76),
    vector3(787.36, -2975.04, 6.04),
    vector3(923.48, 47.54, 81.11),
    vector3(1258.92, -602.64, 69.0),
    vector3(-342.27, 659.36, 168)
}

-- List of radio used for the radio constraint on NPC courses
Config.VtcRadio = {
    "RADIO_35_DLC_HEI4_MLR",
    "RADIO_37_MOTOMAMI",
    "RADIO_12_REGGAE",
    "RADIO_13_JAZZ",
    "RADIO_14_DANCE_02",
    "RADIO_15_MOTOWN",
    "RADIO_20_THELAB",
    "RADIO_16_SILVERLAKE",
    "RADIO_34_DLC_HEI4_KULT",
    "RADIO_17_FUNK",
    "RADIO_18_90S_ROCK",
    "RADIO_21_DLC_XM17",
    "RADIO_22_DLC_BATTLE_MIX1_RADIO",
    "RADIO_23_DLC_XM19_RADIO",
    "RADIO_01_CLASS_ROCK",
    "RADIO_02_POP",
    "RADIO_03_HIPHOP_NEW",
    "RADIO_04_PUNK",
    "RADIO_06_COUNTRY",
    "RADIO_07_DANCE_01",
    "RADIO_08_MEXICAN",
    "RADIO_09_HIPHOP_OLD",
    -- Disabled because depends on where you are on the map
    --"RADIO_05_TALK_01",
    --"RADIO_11_TALK_02",
}