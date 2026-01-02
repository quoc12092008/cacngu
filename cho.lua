--[[
    PET TRACKER v6 - COMPACT VERSION
    getgenv().PET_TRACKER_KEY = "your_key"
]]

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
local plr = game.Players.LocalPlayer
repeat task.wait() until plr.Character
repeat task.wait() until plr.Character:FindFirstChild("HumanoidRootPart")
task.wait(3)

-- CHECK KEY
if not getgenv().PET_TRACKER_KEY or getgenv().PET_TRACKER_KEY == "" then
    error("❌ Set key: getgenv().PET_TRACKER_KEY = 'your_key'")
    return
end

-- STOP OLD INSTANCE
if getgenv().PET_TRACKER_STOP then
    getgenv().PET_TRACKER_STOP()
    task.wait(1)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local http = syn and syn.request or http_request or request

-- CONFIG
-- CONFIG (đơn vị: giây)
local API_URL = "https://tracksab.com/trackgameantrom"
local HEARTBEAT_INTERVAL    = 3    -- Gửi heartbeat 3s/lần
local PET_CHECK_INTERVAL    = 15   -- Quét lại pets bên client 15s/lần
local API_SEND_INTERVAL     = 20   -- Gửi FULL pets/candy tối đa 15s/lần
local FORCE_UPDATE_INTERVAL = 120  -- 2 phút ép full update 1 lần (dự phòng)


-- STATE
local isAuthenticated = false
local userInfo = nil
local allowedPets = {}
local allowedPetSet = {}
local LUCKY_BLOCKS = {}
local lastFoundPets = {}
local lastPetCheckTime = 0
local lastApiSendTime = 0
local lastForceUpdateTime = 0

getgenv().PET_TRACKER_RUNNING = false

-- UTILS
local function log(msg)
    print("[PT] " .. msg)
end

local function httpRequest(method, endpoint, data)
    local success, result = pcall(function()
        local body = data and HttpService:JSONEncode(data) or nil
        local headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }
        if method ~= "POST" or endpoint ~= "/api/auth/validate" then
            headers["X-API-Key"] = getgenv().PET_TRACKER_KEY
        end
        
        return http({
            Url = API_URL .. endpoint,
            Method = method,
            Headers = headers,
            Body = body
        })
    end)
    
    if success and result and result.Success then
        local ok, json = pcall(function()
            return HttpService:JSONDecode(result.Body)
        end)
        if ok then return json end
    end
    return nil
end

-- AUTH
local function validateKey()
    local result = httpRequest("POST", "/api/auth/validate", {key = getgenv().PET_TRACKER_KEY})
    if result and result.success then
        userInfo = result.keyInfo
        isAuthenticated = true
        log("✓ Key OK: " .. userInfo.description)
        return true
    end
    log("✗ Key invalid")
    return false
end

-- SCAN PETS FROM GAME
local function scanPetsFromGame()
    local success, result = pcall(function()
        local Animals = require(ReplicatedStorage.Datas.Animals)
        local secretPets, ogPets, luckyBlockPets = {}, {}, {}
        
        for name, data in pairs(Animals) do
            local rarity = data.Rarity
            if rarity == "Secret" then
                table.insert(secretPets, name)
            elseif rarity == "OG" then
                table.insert(ogPets, name)
            elseif tostring(name):lower():find("lucky block") then
                table.insert(luckyBlockPets, name)
            end
        end
        
        return {secret = secretPets, og = ogPets, luckyBlocks = luckyBlockPets}
    end)
    
    return success and result or nil
end

local function updatePetList()
    local scanned = scanPetsFromGame()
    if not scanned then return false end
    
    allowedPets, allowedPetSet, LUCKY_BLOCKS = {}, {}, {}
    
    for _, name in ipairs(scanned.secret) do
        table.insert(allowedPets, name)
        allowedPetSet[name:lower()] = true
    end
    for _, name in ipairs(scanned.og) do
        table.insert(allowedPets, name)
        allowedPetSet[name:lower()] = true
    end
    for _, name in ipairs(scanned.luckyBlocks) do
        table.insert(LUCKY_BLOCKS, name)
        allowedPetSet[name:lower()] = true
    end
    
    log("📊 Tracking: " .. #allowedPets .. " pets, " .. #LUCKY_BLOCKS .. " lucky blocks")
    return true
end

-- GETGC - SAFE DATA ACCESS
local function getAnimalPodiumsViaGC()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" then
            local cache = rawget(v, "CacheTable")
            if cache and type(cache) == "table" then
                local animals = rawget(cache, "AnimalPodiums")
                if animals and type(animals) == "table" and next(animals) then
                    return animals
                end
            end
        end
    end
    return nil
end

local function getAnimalList()
    for _ = 1, 3 do
        local list = getAnimalPodiumsViaGC()
        if list and next(list) then return list end
        task.wait(0.5)
    end
    return nil
end

-- GET CANDY
local function getCandyAmount()
    local success, candy = pcall(function()
        local gui = LocalPlayer:WaitForChild("PlayerGui")
        local leftBottom = gui:FindFirstChild("LeftBottom")
        if leftBottom then
            local frame = leftBottom:FindFirstChild("LeftBottom")
            if frame then
                local candyLabel = frame:FindFirstChild("CurrencyCandyCane")
                if candyLabel then
                    return tonumber(candyLabel.Text:gsub(",", "")) or 0
                end
            end
        end
        return 0
    end)
    return success and candy or 0
end

-- GET ALLOWED PETS
local function getAllowedPets()
    local pets = {}
    local animalList = getAnimalList()
    if not animalList then return pets end
    
    for _, animal in pairs(animalList) do
        local name = animal.Index or animal.Animal or animal.Name
        if name and allowedPetSet[name:lower()] then
            table.insert(pets, {
                name = name,
                mut = animal.Mutation or "Normal",
                traits = animal.Traits or {},
                count = 1
            })
        end
    end
    return pets
end

-- COMPARE PETS
local function comparePets(oldPets, newPets)
    local oldMap, newMap = {}, {}
    
    for _, pet in ipairs(oldPets) do
        local key = pet.name .. "|" .. pet.mut
        oldMap[key] = (oldMap[key] or 0) + 1
    end
    for _, pet in ipairs(newPets) do
        local key = pet.name .. "|" .. pet.mut
        newMap[key] = (newMap[key] or 0) + 1
    end
    
    local added, removed = 0, 0
    for key, count in pairs(newMap) do
        added = added + math.max(0, count - (oldMap[key] or 0))
    end
    for key, count in pairs(oldMap) do
        removed = removed + math.max(0, count - (newMap[key] or 0))
    end
    
    return added, removed
end

-- SEND HEARTBEAT (lightweight, just update online status)
local function sendHeartbeat()
    local result = httpRequest("POST", "/api/accounts/" .. HttpService:UrlEncode(LocalPlayer.Name), {
        heartbeat = true,
        timestamp = os.time(),
        game_info = {
            place_id = game.PlaceId,
            player_id = LocalPlayer.UserId,
            server_id = game.JobId
        }
    })
    return result and result.success
end

-- SEND FULL DATA
local function sendFullData(pets)
    if not isAuthenticated then return false end
    
    local formattedPets = {}
    for _, pet in ipairs(pets) do
        if allowedPetSet[pet.name:lower()] then
            table.insert(formattedPets, {
                name = pet.name,
                mut = pet.mut or "Normal",
                traits = pet.traits or {},
                count = pet.count or 1
            })
        end
    end
    
    local result = httpRequest("POST", "/api/accounts/" .. HttpService:UrlEncode(LocalPlayer.Name), {
        pets = formattedPets,
        candy = getCandyAmount(),
        timestamp = os.time(),
        game_info = {
            place_id = game.PlaceId,
            player_id = LocalPlayer.UserId,
            display_name = LocalPlayer.DisplayName,
            server_id = game.JobId
        },
        mode = "replace"
    })
    
    if result and result.success then
        log("✓ Synced " .. #formattedPets .. " pets")
        return true
    end
    return false
end

-- STOP
local function stopScript()
    getgenv().PET_TRACKER_RUNNING = false
    log("Stopped")
end
getgenv().PET_TRACKER_STOP = stopScript

-- MAIN
local function main()
    log("Starting...")
    
    if not validateKey() then
        error("Key validation failed")
        return
    end
    
    -- Test getgc
    local testData = getAnimalPodiumsViaGC()
    if testData then
        local count = 0
        for _ in pairs(testData) do count = count + 1 end
        log("✓ getgc() OK - " .. count .. " pets cached")
    else
        log("⚠ getgc() empty, waiting...")
        task.wait(3)
    end
    
    updatePetList()
    
    local now = tick()
    lastPetCheckTime = now
    lastApiSendTime = now
    lastForceUpdateTime = now
    
    lastFoundPets = getAllowedPets()
    
    log("═══════════════════════════════")
    log("Player: " .. LocalPlayer.Name)
    log("Pets found: " .. #lastFoundPets)
    log("═══════════════════════════════")
    
    -- Initial sync
    if sendFullData(lastFoundPets) then
        lastApiSendTime = tick()
        lastForceUpdateTime = tick()
    end
    
    getgenv().PET_TRACKER_RUNNING = true
    
    -- Heartbeat task (every 30s)
    task.spawn(function()
        while getgenv().PET_TRACKER_RUNNING do
            sendHeartbeat()
            task.wait(HEARTBEAT_INTERVAL)
        end
    end)
    
    -- Main loop
    while getgenv().PET_TRACKER_RUNNING do
        local now = tick()
        
        -- Check pets
        if now - lastPetCheckTime >= PET_CHECK_INTERVAL then
            lastPetCheckTime = now
            
            local newPets = getAllowedPets()
            if #newPets > 0 or #lastFoundPets == 0 then
                local added, removed = comparePets(lastFoundPets, newPets)
                
                if added > 0 or removed > 0 then
                    log("Δ +" .. added .. " -" .. removed .. " pets")
                end
                
                local timeSinceSend = now - lastApiSendTime
                local timeSinceForce = now - lastForceUpdateTime
                local needsUpdate = added > 0 or removed > 0 or 
                                   timeSinceSend >= API_SEND_INTERVAL or 
                                   timeSinceForce >= FORCE_UPDATE_INTERVAL
                
                if needsUpdate then
                    if sendFullData(newPets) then
                        lastApiSendTime = now
                        if timeSinceForce >= FORCE_UPDATE_INTERVAL then
                            lastForceUpdateTime = now
                        end
                    end
                end
                
                lastFoundPets = newPets
            end
        end
        
        task.wait(1)
    end
    
    log("Loop ended")
end

main()
