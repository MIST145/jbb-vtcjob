local QBCore = exports['qb-core']:GetCoreObject()

local LAST_ID = 0
local activeDriver = {}
local queuedCourse = {}
local inProgressCourse = {}

-- UTILITY FUNCTIONS
local function tableCount(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function checkAndGetPlayer(source)
    if source == '' then return nil end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    return Player
end

local function getRandomFloatInRange(minValue, maxValue)
    return minValue + math.random() * (maxValue - minValue)
end

--SQL
local dbCache = {}

local function dbManageHistory(player, toAdd)
    local history = json.decode(dbCache[player.PlayerData.citizenid].history)
    if #history >= 20 then
        table.remove(history, 1)
    end
    history[#history+1] = toAdd
    dbCache[player.PlayerData.citizenid].history = json.encode(history)

    if #history > 5 then
        local newRating = 0.0
        for _,e in ipairs(history) do
            newRating = newRating + e.rate
        end
        newRating = newRating/#history
        return newRating
    end

    return 5.0
end

local function dbCreatePlayer(player)
    return MySQL.insert.await('INSERT INTO jbbvtc(citizenid, history) VALUES (?, ?)', {player.PlayerData.citizenid, '[]'})
end

local function dbRetrievePlayer(player)
    local citizenid = player.PlayerData.citizenid
    local result = MySQL.single.await('SELECT * FROM jbbvtc WHERE citizenid = ? LIMIT 1', { citizenid })
    if result == nil then
        dbCreatePlayer(player)
        result = MySQL.single.await('SELECT * FROM jbbvtc WHERE citizenid = ? LIMIT 1', { citizenid })
    end

    dbCache[citizenid] = result
end

local function dbAddDoneCourse(player, earned, rate)
    local newRate = dbManageHistory(player, {earned=earned, rate=rate})

    local vtcInfos = dbCache[player.PlayerData.citizenid]
    vtcInfos.total_course = vtcInfos.total_course+1
    vtcInfos.total_earning = vtcInfos.total_earning+earned
    vtcInfos.rate = newRate

    MySQL.update('UPDATE jbbvtc SET total_course = ?, total_earning = ?, rate = ?, history = ? WHERE citizenid = ?', {
        vtcInfos.total_course,
        vtcInfos.total_earning,
        vtcInfos.rate,
        vtcInfos.history,
        player.PlayerData.citizenid
    }, function(affectedRows)
        print("[SERVER] VTC "..player.PlayerData.citizenid.." updated")
    end)

    return newRate
end

--SCRIPT FUNCTIONS

local function generateCourseId()
    LAST_ID = LAST_ID + 1
    return "C"..tostring(LAST_ID)
end

local function generateNewCourse()
    local start = Config.VTCLocations[math.random(#(Config.VTCLocations))]
    local destination = Config.VTCLocations[math.random(#(Config.VTCLocations))]
    local distance = #(start - destination)
    while distance < Config.VTC.generator.min_distance do
        destination = Config.VTCLocations[math.random(#(Config.VTCLocations))]
        distance = #(start - destination)
    end

    local coursePrice = (distance * Config.VTC.generator.money_per_meter)

    local maxSpeed = 999
    local minSpeed = 999
    if math.random(0, 9) < 5 then
        maxSpeed = math.random(Config.VTC.generator.range_min_maxspeed,Config.VTC.generator.range_max_maxspeed)
    end
    if math.random(0, 9) < 5 then
        minSpeed = math.random(Config.VTC.generator.range_min_minspeed,Config.VTC.generator.range_max_minspeed)
    end

    return {
        id = generateCourseId(),
        start = start,
        player = nil,
        destination = destination,
        pedscount = math.random(Config.VTC.generator.max_number_of_ped),
        peds = {},
        distance = distance,
        coursePrice = coursePrice,
        reward = math.ceil(coursePrice*Config.VTC.player.commission),
        minRate = getRandomFloatInRange(0.0, 4.5),
        maxSpeed = maxSpeed,
        minSpeed = minSpeed,
        createdAt = GetGameTimer()
    }
end

local function generatePlayerCourse(source, destination, pickup, distance, pedsCount)
    if not source then return end
    if not destination then return end
    if not pickup then return end
    local src = source

    local coursePrice = math.ceil(distance * Config.VTC.generator.money_per_meter);

    return {
        id = generateCourseId(),
        start = pickup,
        player = src,
        playerNetId = NetworkGetNetworkIdFromEntity(GetPlayerPed(src)),
        destination = destination,
        pedscount = pedsCount,
        distance = distance,
        price = coursePrice,
        reward = math.ceil(coursePrice*Config.VTC.player.commission),
        minRate = 0.0,
        maxSpeed = 999,
        minSpeed = 999,
        createdAt = GetGameTimer()
    }
end

local function assignCourse(driver, player, cid)
    local course = queuedCourse[cid]
    queuedCourse[cid] = nil
    TriggerClientEvent("jbb:vtc:client:delcourse", -1, cid)
    course.driver = driver
    inProgressCourse[cid] = course
    TriggerClientEvent("jbb:vtc:client:startcourse", driver, course)

    if course.player then
        local ped = GetPlayerPed(driver)
        local coords = GetEntityCoords(ped)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local plate = GetVehicleNumberPlateText(vehicle)

        TriggerClientEvent("jbb:vtc:client:driverassigned", course.player, {
            driver=course.driver,
            name=player.PlayerData.charinfo.firstname,
            plate=plate,
            coords=coords
        })
    end
end

local function endPnjCourse(player, course, success, satisfaction)
    if success then
        local rate = tonumber(string.format("%.1f", satisfaction/20))
        
        local newRate = dbAddDoneCourse(player, course.reward, rate)

        player.Functions.AddMoney("bank", course.reward, "VTC drive course done")
        TriggerClientEvent("jbb:vtc:client:jobdone", player.PlayerData.source, course.id, newRate)
        QBCore.Functions.Notify(player.PlayerData.source, "You've arrived at destination", "success", 3000)
    else
        TriggerClientEvent("jbb:vtc:client:jobcancelled", player.PlayerData.source, course.id)
        QBCore.Functions.Notify(player.PlayerData.source, "You cancelled the course", "error", 3000)
    end
end

local function endPlayerCourse(player, course, success)
    local client = QBCore.Functions.GetPlayer(course.player)
    if success then
        local rate = dbCache[player.PlayerData.citizenid].rate
        
        player.Functions.AddMoney("bank", course.reward, "VTC drive course done")
        client.Functions.RemoveMoney("bank", course.price, "VTC drive course")

        TriggerClientEvent("jbb:vtc:client:jobdone", player.PlayerData.source, course.id, rate)
        TriggerClientEvent("jbb:vtc:client:clientdone", course.player)

        QBCore.Functions.Notify(player.PlayerData.source, "You've arrived at destination", "success", 3000)
        QBCore.Functions.Notify(course.player, "You've arrived at destination", "success", 3000)
    else
        TriggerClientEvent("jbb:vtc:client:jobcancelled", player.PlayerData.source, course.id)
        QBCore.Functions.Notify(player.PlayerData.source, "The course is cancelled", "error", 3000)

        TriggerClientEvent("jbb:vtc:client:clientcancelled", course.player, course.id)
        QBCore.Functions.Notify(course.player, "The driver cancelled the course", "error", 3000)
    end
end

local function endCourse(src, player, cid, success, satisfaction)
    if player and activeDriver[player.PlayerData.citizenid] then
        if inProgressCourse[cid] then
            local course = inProgressCourse[cid]
            inProgressCourse[cid] = nil

            if course.player then endPlayerCourse(player, course, success)
            else endPnjCourse(player, course, success, satisfaction) end
        else
            QBCore.Functions.Notify(src, "This course is not in progress", "error", 3000)
        end
    end
end

local function goOnDuty(source)
    local src = source
    local player = checkAndGetPlayer(src)
    if player then
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(src), false)
        if not vehicle then
            QBCore.Functions.Notify(src, "You must be in a vehicle to start UverX.", "error", 3000)
            return
        end

        dbRetrievePlayer(player)
        activeDriver[player.PlayerData.citizenid] = src
        QBCore.Functions.Notify(src, "You're on duty.", "success", 2000)
        TriggerClientEvent("jbb:vtc:client:onduty", src, dbCache[player.PlayerData.citizenid].rate)
    end
end

local function goOffDuty(source)
    local src = source
    local player = checkAndGetPlayer(src)
    if player and activeDriver[player.PlayerData.citizenid] then
        dbCache[player.PlayerData.citizenid] = nil
        activeDriver[player.PlayerData.citizenid] = nil
        QBCore.Functions.Notify(src, "You're now off duty.", "success", 2000)
        TriggerClientEvent("jbb:vtc:client:offduty", src)
    end
end

-- EVENTS

RegisterNetEvent('QBCore:Server:UpdateObject', function()
	if source ~= '' then return false end
	QBCore = exports['qb-core']:GetCoreObject()
end)

RegisterNetEvent('jbb:vtc:server:finished', function(courseId, satisfaction)
    local src = source
    local player = checkAndGetPlayer(src)
    local cid = tostring(courseId)
    endCourse(src, player, cid, true, satisfaction)
end)

RegisterNetEvent('jbb:vtc:server:cancelled', function(courseId, satisfaction)
    local src = source
    local player = checkAndGetPlayer(src)
    local cid = tostring(courseId)
    endCourse(src, player, cid, false, satisfaction)
end)

RegisterNetEvent('jbb:vtc:server:takecourse', function(courseId)
    local src = source
    local player = checkAndGetPlayer(src)
    local cid = tostring(courseId)
    if player and activeDriver[player.PlayerData.citizenid] then
        if queuedCourse[cid] then
            assignCourse(src, player, cid)
        else
            QBCore.Functions.Notify(src, "This course is not available", "error", 2000)
        end
    end
end)

RegisterNetEvent('jbb:vtc:server:addPlayerCourse', function(data)
    local src = source
    local player = checkAndGetPlayer(src)
    local course = generatePlayerCourse(src, data.destination, data.pickup, data.distance, data.passengers)

    if course and player then
        if player.Functions.GetMoney("bank") >= course.price then
            queuedCourse[course.id] = course
            TriggerClientEvent("jbb:vtc:client:newcourse", -1, course)
        else
            TriggerClientEvent("jbb:vtc:client:notenoughmoney", src, data.price)
        end
    end
end)


-- player course events
RegisterNetEvent('jbb:vtc:server:driveratpickup', function(courseId)
    local src = source
    local player = checkAndGetPlayer(src)
    local cid = tostring(courseId)
    TriggerClientEvent("jbb:vtc:client:driverhere", inProgressCourse[cid].player)
end)

RegisterNetEvent('jbb:vtc:server:clientpickedup', function(courseId)
    local src = source
    local player = checkAndGetPlayer(src)
    local cid = tostring(courseId)
    inProgressCourse[cid].pickedUp = true
    TriggerClientEvent("jbb:vtc:client:driverprogress", inProgressCourse[cid].player)
end)

RegisterNetEvent('jbb:vtc:server:driveratdestination', function(courseId)
    local src = source
    local player = checkAndGetPlayer(src)
    local cid = tostring(courseId)
    TriggerClientEvent("jbb:vtc:client:driverarrived", inProgressCourse[cid].player)
end)

RegisterNetEvent('jbb:vtc:server:changeDuty', function(data)
    local src = source
    if not src then return end
    local player = checkAndGetPlayer(src)
    if not player then return end
    if data.driverMode then
        goOnDuty(src)
    else
        goOffDuty(src)
    end
end)

local running = true
-- THREADS
--thread for creating new courses
CreateThread(function()
    while running do
        local waitTime = math.random(Config.VTC.generator.min_wait_time,Config.VTC.generator.max_wait_time)
        if tableCount(activeDriver) > 0 then
            local course = generateNewCourse()
            queuedCourse[course.id] = course
            TriggerClientEvent("jbb:vtc:client:newcourse", -1, course)
        end
        Wait(waitTime)
    end
end)

--Checks for courses that are too old and disconnected player (todo)
CreateThread(function()
    while running do
        if tableCount(queuedCourse) > 0 then
            local maxTime = Config.VTC.course.availability_time_npc
            for cid, course in pairs(queuedCourse) do
                if course.player then maxTime = Config.VTC.course.availability_time_player end

                if GetGameTimer() - course.createdAt > maxTime then
                    queuedCourse[cid] = nil
                    TriggerClientEvent("jbb:vtc:client:delcourse", -1, cid)
                    if course.player then
                        TriggerClientEvent("jbb:vtc:client:timeout", course.player, cid)
                    end
                end
            end
        end
        Wait(1000)
    end
end)

--Update driver position for client who has a course going
CreateThread(function()
    while running do
        for _,course in pairs(inProgressCourse) do
            if course.player and not course.pickedUp then
                local ped = GetPlayerPed(course.driver)
                local newCoords = GetEntityCoords(ped)
                TriggerClientEvent("jbb:vtc:client:updateDriverPosition", course.player, newCoords)
            end
        end
        Wait(1000)
    end
end)