local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- HTTP Request function (syn/exploit required)
local http = syn and syn.request or http_request or request

-- ==============================================
-- KEY CONFIGURATION - USER MUST SET THIS
-- ==============================================
getgenv().PET_TRACKER_KEY = getgenv().PET_TRACKER_KEY or "key123"  -- CHANGE THIS TO YOUR KEY

-- API Configuration
local API_CONFIG = {
	baseUrl = "https://gundamrealm.io.vn/trackgameantrom"
    enabled = true,
    timeout = 15,
    retryAttempts = 3,
    retryDelay = 2
}

-- Timing Configuration
local TIMING_CONFIG = {
    petCheckInterval = 30,    -- Check pets mỗi 30 giây
    apiSendInterval = 120,    -- Gửi API mỗi 120 giây (2 phút)
    forceUpdateInterval = 600,  -- Force update mỗi 10 phút
    authCheckInterval = 300   -- Check auth mỗi 5 phút
}

-- Danh sách pet được phép hiển thị
local allowedPets = {
    "La Vacca Saturno Saturnita",
    "Torrtuginni Dragonfrutini", 
    "Agarrini La Palini",
    "Las Tralaleritas",
    "Los Tralaleritos",
    "Las Vaquitas Saturnitas",
    "Graipusseni Medussini",
    "Chicleteira Bicicleteira",
    "Pot Hotspot",
    "La Grande Combinasion",
    "Los Combinasionas",
    "Nuclearo Dinossauro",
    "Los Hotspotsitos",
    "Garama and Mandundung",
    "Esok Sekola",
    "Dragon Cannelloni",
    "Secret Lucky Block",
    "Chimpanzini Spiderini",
    "Karkerkar Kurkur"
}

-- Chuyển đổi thành set để tìm kiếm nhanh hơn
local allowedPetSet = {}
for _, petName in ipairs(allowedPets) do
    allowedPetSet[petName:lower()] = true
end

-- Authentication variables
local sessionToken = nil
local lastAuthCheck = 0
local isAuthenticated = false
local userInfo = nil

-- Biến để lưu connection và timing
local recheckConnection = nil
local lastFoundPets = {}
local lastPetCheckTime = 0
local lastApiSendTime = 0
local lastForceUpdateTime = 0
local consecutiveFailures = 0

-- Statistics tracking
local stats = {
    totalChecks = 0,
    totalChanges = 0,
    totalApiCalls = 0,
    successfulCalls = 0,
    failedCalls = 0,
    authAttempts = 0,
    startTime = tick()
}

-- Hàm authenticate với server
local function authenticateWithServer()
    if not http then
        warn("❌ HTTP request function không có sẵn. Cần exploit có syn.request hoặc http_request")
        return false, "HTTP function not available"
    end
    
    if not getgenv().PET_TRACKER_KEY or getgenv().PET_TRACKER_KEY == "" then
        warn("❌ PET_TRACKER_KEY chưa được set! Sử dụng: getgenv().PET_TRACKER_KEY = 'your_key_here'")
        return false, "Key not set"
    end
    
    local success, result = pcall(function()
        local url = API_CONFIG.baseUrl .. "/api/auth/login"
        
        local requestData = {
            key = getgenv().PET_TRACKER_KEY
        }
        
        local jsonData = HttpService:JSONEncode(requestData)
        
        print("🔐 Authenticating with key: " .. string.rep("*", #getgenv().PET_TRACKER_KEY))
        
        local response = http({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Accept"] = "application/json"
            },
            Body = jsonData
        })
        
        if response.Success then
            local responseData = HttpService:JSONDecode(response.Body)
            
            if responseData.success then
                sessionToken = responseData.sessionToken
                userInfo = responseData.user
                isAuthenticated = true
                
                print("✅ Authentication successful!")
                print("👤 Username: " .. userInfo.username)
                print("🎯 Slots: " .. userInfo.slots)
                print("📅 Expires: " .. userInfo.expiry)
                
                return true, responseData
            else
                error("Authentication failed: " .. (responseData.error or "Unknown error"))
            end
        else
            error("HTTP Error: " .. (response.StatusCode or "Unknown") .. " - " .. (response.Body or "No response"))
        end
    end)
    
    stats.authAttempts = stats.authAttempts + 1
    
    if success then
        return true, result
    else
        warn("❌ Authentication Error: " .. tostring(result))
        
        -- Check for specific error codes
        if tostring(result):find("INVALID_KEY") then
            warn("❌ KEY KHÔNG HỢP LỆ: Key '" .. getgenv().PET_TRACKER_KEY .. "' không tồn tại hoặc đã hết hạn")
            warn("💡 Kiểm tra lại key hoặc liên hệ admin để được cấp key mới")
        end
        
        return false, result
    end
end

-- Hàm kiểm tra authentication status
local function checkAuthenticationStatus()
    if not sessionToken then
        return false, "No session token"
    end
    
    local success, result = pcall(function()
        local url = API_CONFIG.baseUrl .. "/api/auth/me"
        
        local response = http({
            Url = url,
            Method = "GET",
            Headers = {
                ["Accept"] = "application/json",
                ["Authorization"] = "Bearer " .. sessionToken
            }
        })
        
        if response.Success then
            local responseData = HttpService:JSONDecode(response.Body)
            
            if responseData.success then
                userInfo = responseData.user
                return true, responseData
            else
                error("Auth check failed: " .. (responseData.error or "Unknown error"))
            end
        else
            error("HTTP Error: " .. (response.StatusCode or "Unknown"))
        end
    end)
    
    if success then
        return true, result
    else
        warn("⚠️ Auth check failed: " .. tostring(result))
        
        -- Reset authentication if session is invalid
        if tostring(result):find("401") or tostring(result):find("INVALID_SESSION") then
            sessionToken = nil
            isAuthenticated = false
            userInfo = nil
        end
        
        return false, result
    end
end

-- Hàm gửi data tới API với authentication
local function sendDataToAPI(accountName, pets, isForced)
    if not API_CONFIG.enabled then
        return false, "API disabled"
    end
    
    if not isAuthenticated or not sessionToken then
        warn("❌ Chưa authenticate. Thử authenticate lại...")
        local authSuccess = authenticateWithServer()
        if not authSuccess then
            return false, "Authentication failed"
        end
    end
    
    local attempt = 0
    local lastError = nil
    
    while attempt < API_CONFIG.retryAttempts do
        attempt = attempt + 1
        stats.totalApiCalls = stats.totalApiCalls + 1
        
        local success, result = pcall(function()
            local url = API_CONFIG.baseUrl .. "/api/accounts/" .. HttpService:UrlEncode(accountName)
            
            local requestData = {
                pets = pets,
                timestamp = os.time(),
                game_info = {
                    place_id = game.PlaceId,
                    player_id = LocalPlayer.UserId,
                    display_name = LocalPlayer.DisplayName,
                    server_id = game.JobId
                },
                metadata = {
                    total_pets = #pets,
                    check_type = isForced and "forced" or "scheduled",
                    client_time = os.date("%Y-%m-%d %H:%M:%S"),
                    attempt = attempt,
                    key_user = userInfo and userInfo.username or "unknown"
                }
            }
            
            local jsonData = HttpService:JSONEncode(requestData)
            
            if attempt == 1 then
                print("📡 Đang gửi data tới: " .. url)
                print("👤 User: " .. (userInfo and userInfo.username or "unknown"))
                print("📋 Pets: " .. #pets .. " | Type: " .. (isForced and "FORCED" or "SCHEDULED"))
            end
            
            local response = http({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Accept"] = "application/json",
                    ["Authorization"] = "Bearer " .. sessionToken
                },
                Body = jsonData
            })
            
            if response.Success then
                local responseData = HttpService:JSONDecode(response.Body)
                
                if responseData.success then
                    if attempt > 1 then
                        print("✅ API Success (attempt " .. attempt .. "): " .. response.Body)
                    else
                        print("✅ API Response: " .. responseData.message)
                    end
                    
                    return responseData
                else
                    error("API Error: " .. (responseData.error or "Unknown error"))
                end
            elseif response.StatusCode == 401 then
                -- Session expired, try to re-authenticate
                warn("🔐 Session expired, re-authenticating...")
                isAuthenticated = false
                sessionToken = nil
                
                local authSuccess = authenticateWithServer()
                if authSuccess then
                    error("RETRY_WITH_NEW_AUTH") -- Special error to retry with new auth
                else
                    error("Re-authentication failed")
                end
            elseif response.StatusCode == 403 and response.Body and response.Body:find("SLOT_LIMIT_EXCEEDED") then
                error("❌ SLOT LIMIT EXCEEDED: Account vượt quá số slot cho phép (" .. (userInfo and userInfo.slots or "unknown") .. " slots)")
            else
                error("HTTP Error: " .. (response.StatusCode or "Unknown") .. " - " .. (response.Body or "No response"))
            end
        end)
        
        if success then
            consecutiveFailures = 0
            stats.successfulCalls = stats.successfulCalls + 1
            print("✅ API: Đã gửi data cho " .. accountName .. " - " .. #pets .. " pets (attempt " .. attempt .. ")")
            return true, result
        else
            lastError = result
            consecutiveFailures = consecutiveFailures + 1
            stats.failedCalls = stats.failedCalls + 1
            
            -- Handle special retry case
            if tostring(result):find("RETRY_WITH_NEW_AUTH") then
                warn("🔄 Retrying with new authentication...")
                task.wait(1)
                continue
            end
            
            if attempt < API_CONFIG.retryAttempts then
                warn("❌ API Error (attempt " .. attempt .. "): " .. tostring(result))
                warn("🔄 Retrying in " .. API_CONFIG.retryDelay .. " seconds...")
                task.wait(API_CONFIG.retryDelay)
            end
        end
    end
    
    warn("❌ API Failed after " .. API_CONFIG.retryAttempts .. " attempts: " .. tostring(lastError))
    
    -- Disable API if too many consecutive failures (but keep auth)
    if consecutiveFailures >= 10 then
        warn("⚠️ Too many API failures, temporarily disabling API calls")
        task.wait(60) -- Wait 1 minute before re-enabling
        consecutiveFailures = 0
    end
    
    return false, lastError
end

-- Hàm tìm plot của bạn
local function findMyPlot(waitForSpawn)
    local deadline = tick() + (waitForSpawn and 10 or 0)
    repeat
        for _, plot in ipairs(Workspace.Plots:GetChildren()) do
            local ownerTag = plot:FindFirstChild("Owner")
            if ownerTag and ownerTag.Value == LocalPlayer then
                return plot
            end
            local sign = plot:FindFirstChild("PlotSign")
            local label = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
            if label then
                local txt = label.Text:lower()
                if txt:match(LocalPlayer.Name:lower()) or txt:match(LocalPlayer.DisplayName:lower()) then
                    return plot
                end
            end
        end
        RunService.RenderStepped:Wait()
    until tick() > deadline
    return nil
end

-- Hàm lấy dữ liệu pet từ spawn (tối ưu)
local function getPetDataFromSpawn(spawn)
    if not spawn then return nil end

    local attach = spawn:FindFirstChild("Attachment")
    if not attach then return nil end
    
    local overhead = attach:FindFirstChild("AnimalOverhead")
    if not overhead then return nil end
    
    local lbl = overhead:FindFirstChild("DisplayName")
    if not lbl then return nil end
    
    local name = lbl.Text
    if not name or name == "" then return nil end

    local mut = "Normal"

    -- Check mutation từ Attributes của pet trong workspace
    local petObj = Workspace:FindFirstChild(name)
    if petObj then
        local attrMut = petObj:GetAttribute("Mutation")
        if attrMut and attrMut ~= "" then
            mut = attrMut
        end
    end

    return {name = name, mut = mut}
end

-- Hàm lấy list pet được phép trong plot (tối ưu)
local function getAllowedPetsInPlot(plot)
    local pets = {}
    local podFolder = plot and plot:FindFirstChild("AnimalPodiums")
    if not podFolder then return pets end
    
    for _, podium in ipairs(podFolder:GetChildren()) do
        if podium:IsA("Model") then
            local base = podium:FindFirstChild("Base")
            if base then
                local spawn = base:FindFirstChild("Spawn")
                local data = getPetDataFromSpawn(spawn)
                if data then
                    -- Chỉ thêm pet nếu nằm trong danh sách cho phép
                    if allowedPetSet[data.name:lower()] then
                        table.insert(pets, data)
                    end
                end
            end
        end
    end
    return pets
end

-- Hàm so sánh 2 danh sách pet (tối ưu)
local function comparePetLists(oldPets, newPets)
    local oldPetMap = {}
    local newPetMap = {}
    
    -- Tạo map từ danh sách cũ
    for _, pet in ipairs(oldPets) do
        local key = pet.name .. "|" .. pet.mut
        oldPetMap[key] = (oldPetMap[key] or 0) + 1
    end
    
    -- Tạo map từ danh sách mới
    for _, pet in ipairs(newPets) do
        local key = pet.name .. "|" .. pet.mut
        newPetMap[key] = (newPetMap[key] or 0) + 1
    end
    
    local added = {}
    local removed = {}
    
    -- Tìm pet mới thêm
    for key, count in pairs(newPetMap) do
        local oldCount = oldPetMap[key] or 0
        if count > oldCount then
            local name, mut = key:match("([^|]+)|(.+)")
            for i = 1, count - oldCount do
                table.insert(added, {name = name, mut = mut})
            end
        end
    end
    
    -- Tìm pet bị xóa
    for key, count in pairs(oldPetMap) do
        local newCount = newPetMap[key] or 0
        if count > newCount then
            local name, mut = key:match("([^|]+)|(.+)")
            for i = 1, count - newCount do
                table.insert(removed, {name = name, mut = mut})
            end
        end
    end
    
    return added, removed
end

-- Hàm kiểm tra xem có cần gửi API không
local function shouldSendToAPI(added, removed, timeSinceLastSend, timeSinceLastForce)
    return (#added > 0 or #removed > 0 or 
            timeSinceLastSend >= TIMING_CONFIG.apiSendInterval or 
            timeSinceLastForce >= TIMING_CONFIG.forceUpdateInterval)
end

-- Hàm hiển thị pet list trong console với authentication info
local function displayPetsInConsole(pets, isInitial)
    if isInitial then
        print("\n" .. string.rep("=", 80))
        print("🔐 KHỞI CHẠY AUTHENTICATED PET MONITOR")
        print("⏰ Thời gian: " .. os.date("%Y-%m-%d %H:%M:%S"))
        print("🔑 Key User: " .. (userInfo and userInfo.username or "Not authenticated"))
        print("🎯 Slots: " .. (userInfo and userInfo.slots or "Unknown"))
        print("📊 Tổng số pet được phép tìm thấy: " .. #pets)
        print("📡 API URL: " .. API_CONFIG.baseUrl)
        print("👤 Account: " .. LocalPlayer.Name)
        print("🔧 HTTP Function: " .. (http and "Available" or "NOT AVAILABLE"))
        print("🔐 Authentication: " .. (isAuthenticated and "✅ Valid" or "❌ Invalid"))
        print("⚙️ Timing Config:")
        print("  • Pet Check: " .. TIMING_CONFIG.petCheckInterval .. "s")
        print("  • API Send: " .. TIMING_CONFIG.apiSendInterval .. "s") 
        print("  • Force Update: " .. TIMING_CONFIG.forceUpdateInterval .. "s")
        print("  • Auth Check: " .. TIMING_CONFIG.authCheckInterval .. "s")
        print(string.rep("=", 80))
        
        if #pets > 0 then
            for i, pet in ipairs(pets) do
                print(string.format("  [%d] %s | Mutation: %s", i, pet.name, pet.mut))
            end
        else
            print("  ❌ Không tìm thấy pet nào trong danh sách cho phép")
        end
        print(string.rep("=", 80) .. "\n")
    else
        print("\n🔄 AUTO RECHECK - " .. os.date("%H:%M:%S"))
        print("📊 Tổng pet được phép: " .. #pets)
        print("🔐 Auth Status: " .. (isAuthenticated and "✅" or "❌"))
        
        -- Show stats every few checks
        if stats.totalChecks % 5 == 0 then
            local uptime = math.floor(tick() - stats.startTime)
            local successRate = stats.totalApiCalls > 0 and 
                math.floor((stats.successfulCalls / stats.totalApiCalls) * 100) or 0
            
            print("📈 Stats: " .. stats.totalChecks .. " checks, " .. 
                  stats.totalChanges .. " changes, " .. 
                  stats.successfulCalls .. "/" .. stats.totalApiCalls .. 
                  " API calls (" .. successRate .. "% success)")
        end
        
        if #pets > 0 then
            for i, pet in ipairs(pets) do
                print(string.format("  [%d] %s | %s", i, pet.name, pet.mut))
            end
        end
    end
end

-- Hàm hiển thị thay đổi trong console
local function displayChangesInConsole(added, removed)
    if #added > 0 then
        print("\n✅ PET MỚI XUẤT HIỆN:")
        for _, pet in ipairs(added) do
            print("  + " .. pet.name .. " | " .. pet.mut)
        end
        stats.totalChanges = stats.totalChanges + #added
    end
    
    if #removed > 0 then
        print("\n❌ PET BỊ XÓA:")
        for _, pet in ipairs(removed) do
            print("  - " .. pet.name .. " | " .. pet.mut)
        end
        stats.totalChanges = stats.totalChanges + #removed
    end
    
    if #added > 0 or #removed > 0 then
        print(string.rep("-", 50))
    end
end

-- Hàm bắt đầu monitor với authentication
local function startPetMonitor(plot)
    lastPetCheckTime = tick()
    lastApiSendTime = tick()
    lastForceUpdateTime = tick()
    lastAuthCheck = tick()
    
    -- Kiểm tra HTTP function
    if not http then
        warn("❌ CẢNH BÁO: HTTP request function không có sẵn!")
        warn("❌ Cần sử dụng exploit có syn.request hoặc http_request")
        warn("❌ Script sẽ không hoạt động")
        return
    end
    
    -- Authenticate với server
    print("🔐 Đang authenticate với server...")
    local authSuccess, authResult = authenticateWithServer()
    if not authSuccess then
        warn("❌ Authentication failed! Script sẽ không hoạt động.")
        warn("💡 Kiểm tra:")
        warn("  • Key đúng chưa: getgenv().PET_TRACKER_KEY = 'your_key'")
        warn("  • Server có đang chạy không")
        warn("  • Key có bị hết hạn không")
        return
    end
    
    -- Lấy danh sách pet ban đầu
    lastFoundPets = getAllowedPetsInPlot(plot)
    displayPetsInConsole(lastFoundPets, true)
    
    -- Gửi data ban đầu tới API
    if API_CONFIG.enabled and isAuthenticated then
        local success, result = sendDataToAPI(LocalPlayer.Name, lastFoundPets, false)
        if success then
            lastApiSendTime = tick()
            lastForceUpdateTime = tick()
        end
    end
    
    -- Connection cho auto recheck với authentication checks
    recheckConnection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        -- Check authentication status mỗi 5 phút
        if currentTime - lastAuthCheck >= TIMING_CONFIG.authCheckInterval then
            lastAuthCheck = currentTime
            
            if isAuthenticated then
                local authValid, authResult = checkAuthenticationStatus()
                if not authValid then
                    warn("⚠️ Authentication expired, re-authenticating...")
                    authenticateWithServer()
                end
            end
        end
        
        -- Check pets mỗi 30 giây
        if currentTime - lastPetCheckTime >= TIMING_CONFIG.petCheckInterval then
            lastPetCheckTime = currentTime
            stats.totalChecks = stats.totalChecks + 1
            
            -- Kiểm tra xem plot còn tồn tại không
            if not plot.Parent then
                print("❌ Plot không còn tồn tại. Dừng monitor.")
                recheckConnection:Disconnect()
                return
            end
            
            -- Lấy danh sách pet mới
            local newPets = getAllowedPetsInPlot(plot)
            
            -- So sánh với danh sách cũ
            local added, removed = comparePetLists(lastFoundPets, newPets)
            
            -- Hiển thị thay đổi nếu có
            if #added > 0 or #removed > 0 then
                displayChangesInConsole(added, removed)
                displayPetsInConsole(newPets, false)
            end
            
            -- Tính thời gian từ lần gửi API cuối
            local timeSinceLastSend = currentTime - lastApiSendTime
            local timeSinceLastForce = currentTime - lastForceUpdateTime
            
            -- Kiểm tra xem có cần gửi API không
            if API_CONFIG.enabled and isAuthenticated and shouldSendToAPI(added, removed, timeSinceLastSend, timeSinceLastForce) then
                local isForced = (timeSinceLastForce >= TIMING_CONFIG.forceUpdateInterval)
                local reason = ""
                
                if #added > 0 or #removed > 0 then
                    reason = "có thay đổi pet"
                elseif timeSinceLastSend >= TIMING_CONFIG.apiSendInterval then
                    reason = "scheduled update (120s)"
                elseif isForced then
                    reason = "force update (10min)"
                end
                
                local success, result = sendDataToAPI(LocalPlayer.Name, newPets, isForced)
                if success then
                    lastApiSendTime = currentTime
                    if isForced then
                        lastForceUpdateTime = currentTime
                    end
                    print("📡 API: Data updated - " .. reason)
                else
                    warn("📡 API: Failed to update - " .. reason)
                end
            end
            
            -- Cập nhật danh sách cũ
            lastFoundPets = newPets
        end
    end)
    
    print("🚀 Authenticated Pet Monitor đã khởi chạy!")
    print("🔑 User: " .. userInfo.username .. " (" .. userInfo.slots .. " slots)")
    print("📝 Chỉ hiển thị " .. #allowedPets .. " loại pet được phép.")
    print("🕐 Check pets mỗi " .. TIMING_CONFIG.petCheckInterval .. "s, gửi API mỗi " .. TIMING_CONFIG.apiSendInterval .. "s")
    print("🔐 Auth check mỗi " .. TIMING_CONFIG.authCheckInterval .. "s")
    print("⚠️ Để dừng monitor, chạy lại script hoặc reset.")
end

-- Global commands để control authenticated API
_G.PetTrackerAuth = {
    setKey = function(newKey)
        getgenv().PET_TRACKER_KEY = newKey
        isAuthenticated = false
        sessionToken = nil
        userInfo = nil
        print("🔑 Key updated to: " .. string.rep("*", #newKey))
        print("💡 Chạy lại script để authenticate với key mới")
    end,
    authenticate = function()
        return authenticateWithServer()
    end,
    checkAuth = function()
        return checkAuthenticationStatus()
    end,
    getUserInfo = function()
        return userInfo
    end,
    getStats = function()
        local uptime = math.floor(tick() - stats.startTime)
        local successRate = stats.totalApiCalls > 0 and 
            math.floor((stats.successfulCalls / stats.totalApiCalls) * 100) or 0
        
        print("\n📊 AUTHENTICATED PET TRACKER STATISTICS:")
        print("🔑 Key User: " .. (userInfo and userInfo.username or "Not authenticated"))
        print("🎯 Slots: " .. (userInfo and userInfo.slots or "Unknown"))
        print("🔐 Authenticated: " .. (isAuthenticated and "Yes" or "No"))
        print("⏰ Uptime: " .. math.floor(uptime / 60) .. " minutes")
        print("🔍 Total Checks: " .. stats.totalChecks)
        print("📈 Total Changes: " .. stats.totalChanges)
        print("📡 API Calls: " .. stats.successfulCalls .. "/" .. stats.totalApiCalls .. " (" .. successRate .. "% success)")
        print("🔐 Auth Attempts: " .. stats.authAttempts)
        print("❌ Consecutive Failures: " .. stats.failedCalls)
        print("🐾 Current Pets: " .. #lastFoundPets)
        
        return {
            authenticated = isAuthenticated,
            userInfo = userInfo,
            stats = stats,
            uptime = uptime,
            successRate = successRate
        }
    end,
    sendNow = function()
        if lastFoundPets and isAuthenticated then
            return sendDataToAPI(LocalPlayer.Name, lastFoundPets, true)
        else
            warn("❌ Not authenticated or no pet data")
            return false
        end
    end,
    config = API_CONFIG,
    timing = TIMING_CONFIG
}

-- Dừng connection cũ nếu có
if recheckConnection then
    recheckConnection:Disconnect()
    print("🔄 Đã dừng monitor cũ.")
end

-- Validate key trước khi chạy
if not getgenv().PET_TRACKER_KEY or getgenv().PET_TRACKER_KEY == "" then
    error("❌ THIẾU KEY! Sử dụng: getgenv().PET_TRACKER_KEY = 'your_key_here'")
    return
end

-- Chạy script
print("\n🚀 Starting Authenticated Pet Tracker...")
print("🔑 Key: " .. string.rep("*", #getgenv().PET_TRACKER_KEY))
print("📡 Commands available: _G.PetTrackerAuth")
print("🔧 Testing HTTP function...")

if not http then
    error("❌ HTTP request function không có sẵn! Script sẽ không hoạt động.")
    return
end

local myPlot = findMyPlot(true)
if not myPlot then
    error("❌ Không tìm thấy plot của bạn! Kiểm tra lại trong game.")
    return
end

startPetMonitor(myPlot)
