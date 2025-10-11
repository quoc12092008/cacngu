-- ⚙️ CẤU HÌNH SERVER
local SERVER_URL = "http://localhost:5000"

-- ===== CẤU HÌNH ACCOUNTS =====
-- 🔍 CHECKER ACCOUNTS: Tìm pet và báo server
local CheckerAccounts = {
    "CheckerAcc1",
    "CheckerAcc2",
    "CheckerAcc3"
}

-- 🤖 HOLDER ACCOUNTS: Nhận lệnh join VIP và lấy pet
local HolderConfig = {
    {AccountName = "HolderAcc1", TargetPet = "Banana"},
    {AccountName = "HolderAcc2", TargetPet = "Orange"},
    {AccountName = "HolderAcc3", TargetPet = "Banana"}
}

-- Cấu hình chung
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 8

-- ===== HTTP SETUP =====
local HttpService = game:GetService("HttpService")
local http = syn and syn.request or http_request or request or fluxus and fluxus.request

if not http then
    warn("❌ EXECUTOR KHÔNG HỖ TRỢ HTTP!")
    error("Executor không hỗ trợ HTTP!")
    return
end

print("✅ HTTP function detected!")

-- Services
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- ===== HTTP REQUEST HELPER =====
local API_CONFIG = {
    retryAttempts = 3,
    retryDelay = 2
}

local function HttpPost(endpoint, data)
    local attempt = 0
    
    while attempt < API_CONFIG.retryAttempts do
        attempt = attempt + 1
        
        local success, result = pcall(function()
            local url = SERVER_URL .. endpoint
            local jsonData = HttpService:JSONEncode(data)
            
            local response = http({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Accept"] = "application/json"
                },
                Body = jsonData
            })
            
            if response.Success or response.StatusCode == 200 then
                return HttpService:JSONDecode(response.Body)
            else
                error("HTTP Error: " .. tostring(response.StatusCode or "Unknown"))
            end
        end)
        
        if success then
            return result
        else
            warn("[HTTP ERROR] Attempt " .. attempt .. "/" .. API_CONFIG.retryAttempts .. ": " .. tostring(result))
            
            if attempt < API_CONFIG.retryAttempts then
                task.wait(API_CONFIG.retryDelay)
            else
                warn("[HTTP FAILED] " .. endpoint .. " failed after " .. attempt .. " attempts")
                return nil
            end
        end
    end
    
    return nil
end

-- ===== XÁC ĐỊNH ROLE =====
local AccountMode = nil
local TargetPet = nil

-- Check if Checker
for _, checkerName in ipairs(CheckerAccounts) do
    if checkerName == player.Name then
        AccountMode = "Checker"
        break
    end
end

-- Check if Holder
if not AccountMode then
    for _, holderCfg in ipairs(HolderConfig) do
        if holderCfg.AccountName == player.Name then
            AccountMode = "Holder"
            TargetPet = holderCfg.TargetPet
            break
        end
    end
end

if not AccountMode then
    error("❌ Account " .. player.Name .. " không có trong config!")
    return
end

print("========================================")
if AccountMode == "Checker" then
    print("🔍 [CHECKER MODE] Account:", player.Name)
    print("🔍 Role: Find pets and submit to server")
else
    print("🤖 [HOLDER MODE] Account:", player.Name)
    print("🤖 Target Pet:", TargetPet)
    print("🤖 Role: Join VIP and collect pets")
end
print("========================================")

-- ===== SERVER API =====
local ServerAPI = {}

function ServerAPI.RegisterChecker(username)
    return HttpPost("/register_checker", {username = username})
end

function ServerAPI.RegisterHolder(username)
    return HttpPost("/register_holder", {username = username})
end

function ServerAPI.Heartbeat(username, account_type)
    return HttpPost("/heartbeat", {
        username = username,
        type = account_type
    })
end

function ServerAPI.SubmitPet(username, pet_name)
    return HttpPost("/submit_pet", {
        username = username,
        pet_name = pet_name
    })
end

function ServerAPI.GetHolderJob(username)
    return HttpPost("/get_holder_job", {username = username})
end

function ServerAPI.CompleteJob(username)
    return HttpPost("/complete_job", {username = username})
end

-- ===== SPEED COIL (CHỈ CHO HOLDER) =====
local speedCoilActive = false
local speedCoilBought = false
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net", 10)
local remotePath = "RF/CoinsShopService/RequestBuy"
local remoteFunction = Net and Net:FindFirstChild(remotePath, true)

local function BuySpeedCoil()
    if speedCoilBought or not remoteFunction then return end
    local success = pcall(function()
        remoteFunction:InvokeServer("Speed Coil")
    end)
    if success then
        speedCoilBought = true
        print("[✅] Mua Speed Coil thành công")
    end
end

local function EquipSpeedCoil()
    if not speedCoilBought then return end
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
    speedCoilActive = true
    print("[⚡] Speed Coil equipped!")
end

-- ===== CAMERA ADJUSTMENT =====
local function AdjustCameraBehindPlayer(petPosition)
    local cam = Workspace.CurrentCamera
    if not cam or not hrp then return end
    
    local direction = (petPosition - hrp.Position).Unit
    local behindOffset = -direction * 5 + Vector3.new(0, 3, 0)
    local camPos = hrp.Position + behindOffset
    
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0, 2, 0))
    
    print("[📷] Camera adjusted behind player")
    
    task.delay(4, function()
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            print("[📷] Camera returned to normal")
        end
    end)
end

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "EnhancedPetFarm"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusBox"
statusFrame.AnchorPoint = Vector2.new(0.5, 0)
statusFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
statusFrame.Size = UDim2.new(0, 420, 0, 42)
statusFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
statusFrame.BackgroundTransparency = 0.2
statusFrame.Parent = gui

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = AccountMode == "Checker" and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(0, 255, 100)
statusStroke.Thickness = 2
statusStroke.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamBold
statusText.TextColor3 = AccountMode == "Checker" and Color3.fromRGB(255, 200, 40) or Color3.fromRGB(0, 255, 100)
statusText.TextSize = 16
statusText.Text = "Status : Connecting to server..."
statusText.Parent = statusFrame

local discordText = Instance.new("TextLabel")
discordText.Text = "Enhanced VIP System - " .. AccountMode .. " Mode"
discordText.Position = UDim2.new(0.5, 0, 0.06, 0)
discordText.AnchorPoint = Vector2.new(0.5, 0)
discordText.Size = UDim2.new(0, 300, 0, 20)
discordText.BackgroundTransparency = 1
discordText.Font = Enum.Font.GothamBold
discordText.TextColor3 = AccountMode == "Checker" and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(0, 255, 100)
discordText.TextSize = 13
discordText.Parent = gui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.55, 0)
mainFrame.Size = UDim2.new(0, 500, 0, 250)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = AccountMode == "Checker" and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(0, 255, 100)
mainStroke.Thickness = 2.5
mainStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = AccountMode == "Checker" and "🔍 CHECKER MODE" or "🤖 HOLDER MODE"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = AccountMode == "Checker" and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(0, 255, 100)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.92, 0, 0, 2)
divider.Position = UDim2.new(0.04, 0, 0, 50)
divider.BackgroundColor3 = AccountMode == "Checker" and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(0, 255, 100)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

local infoText = Instance.new("TextLabel")
infoText.Position = UDim2.new(0.05, 0, 0, 70)
infoText.Size = UDim2.new(0.9, 0, 0.7, 0)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.GothamMedium
infoText.TextColor3 = Color3.fromRGB(245, 245, 245)
infoText.TextSize = 15
infoText.TextWrapped = true
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.Text = "Loading..."
infoText.Parent = mainFrame

-- ===== PLOT FUNCTIONS =====
local function GetMyPlot()
    local myPlot = PlotController.GetMyPlot()
    if myPlot and myPlot.PlotModel then
        return myPlot.PlotModel
    end
    return nil
end

local function GetHomeSpawn(myPlot)
    if not myPlot then return nil end
    local deco = myPlot:FindFirstChild("Decorations")
    if not deco then return nil end
    local spawnPart = deco:GetChildren()[12]
    if spawnPart and spawnPart.CFrame then
        return spawnPart.CFrame.Position
    end
    return nil
end

local function GetAnimalPodiumClaim(myPlot)
    if not myPlot then return nil end
    local animalPodiums = myPlot:FindFirstChild("AnimalPodiums")
    if not animalPodiums then return nil end
    local podium1 = animalPodiums:FindFirstChild("1")
    if not podium1 then return nil end
    local claim = podium1:FindFirstChild("Claim")
    if not claim then return nil end
    local main = claim:FindFirstChild("Main")
    if main and main.CFrame then
        return main.CFrame.Position
    end
    return nil
end

local function GetPetsInMyPlot()
    local myPlot = GetMyPlot()
    if not myPlot then return {} end
    
    local pets = {}
    local skipList = {
        "Decorations", "Floor", "Walls", "Roof", "SpawnLocation", "Door",
        "FriendPanel", "Friend", "Panel", "BuildArea", "Lighting", 
        "Camera", "PlotArea", "Gui", "UI", "Screen", "AnimalPodiums"
    }
    
    for _, obj in ipairs(myPlot:GetChildren()) do
        if not obj:IsA("Model") then continue end
        
        local shouldSkip = false
        for _, skipWord in ipairs(skipList) do
            if string.find(string.lower(obj.Name), string.lower(skipWord)) then
                shouldSkip = true
                break
            end
        end
        
        if not shouldSkip then
            if obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart then
                local pos = obj:GetPivot().Position
                table.insert(pets, {
                    name = obj.Name,
                    position = {x = pos.X, y = pos.Y, z = pos.Z},
                    object = obj
                })
            end
        end
    end
    
    return pets
end

local function WalkToPosition(targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4
    })
    path:ComputeAsync(hrp.Position, targetPos)

    if path.Status ~= Enum.PathStatus.Success then
        return false
    end

    for _, wp in ipairs(path:GetWaypoints()) do
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid:MoveTo(wp.Position)
        local reached = humanoid.MoveToFinished:Wait()
        if not reached then return false end
    end
    return true
end

local function HoldKeyEReal(duration)
    local start = tick()
    while tick() - start < duration do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        RunService.Heartbeat:Wait()
    end
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- ===== CHECKER MODE =====
local petsSubmitted = 0

function UpdateCheckerInfo()
    local myPets = GetPetsInMyPlot()
    
    local petList = ""
    for i, pet in ipairs(myPets) do
        petList = petList .. string.format("  • %s\n", pet.name)
        if i >= 8 then
            petList = petList .. string.format("  ... and %d more\n", #myPets - 8)
            break
        end
    end
    
    if #myPets == 0 then
        petList = "  (No pets in plot)\n"
    end
    
    infoText.Text = string.format(
        "👤 Username: %s\n" ..
        "🔍 Role: Find and submit pets\n" ..
        "🏠 Pets in Plot: %d\n" ..
        "📤 Submitted: %d\n\n" ..
        "Pet List:\n%s",
        player.Name,
        #myPets,
        petsSubmitted,
        petList
    )
end

local function CheckerLoop()
    while true do
        pcall(function()
            local pets = GetPetsInMyPlot()
            
            if #pets == 0 then
                print("[CHECKER] ⚠️ Hết pet! Waiting...")
                statusText.Text = "Status : No pets - Waiting..."
                task.wait(15)
                return
            end
            
            -- Tìm pet mới (chưa submit)
            local newPets = {}
            for _, pet in ipairs(pets) do
                -- Có thể thêm logic tracking pet đã submit
                table.insert(newPets, pet)
            end
            
            -- Submit từng pet
            for _, pet in ipairs(newPets) do
                statusText.Text = "Status : Submitting " .. pet.name .. " to server..."
                
                local response = ServerAPI.SubmitPet(player.Name, pet.name)
                
                if response and response.success then
                    petsSubmitted = petsSubmitted + 1
                    
                    if response.status == "queued" then
                        print("[CHECKER] ✅ Pet queued:", pet.name, "- Job ID:", response.job_id)
                        statusText.Text = "Status : Pet " .. pet.name .. " queued (waiting holder)"
                    else
                        print("[CHECKER] ✅ Pet assigned:", pet.name, "to", response.assigned_to)
                        statusText.Text = "Status : Pet " .. pet.name .. " assigned to " .. response.assigned_to
                    end
                else
                    print("[CHECKER] ❌ Failed to submit:", pet.name)
                    statusText.Text = "Status : Failed to submit " .. pet.name
                end
                
                UpdateCheckerInfo()
                task.wait(2)
            end
        end)
        
        task.wait(CheckInterval)
    end
end

-- ===== HOLDER MODE =====
local jobsCompleted = 0

function UpdateHolderInfo()
    local myPets = GetPetsInMyPlot()
    infoText.Text = string.format(
        "👤 Username: %s\n" ..
        "🎯 Target Pet: %s\n" ..
        "✅ Jobs Completed: %d\n" ..
        "🏠 Pets in My Plot: %d\n" ..
        "⚡ Speed Coil: %s\n" ..
        "⏱️ Hold Time: %.1fs\n" ..
        "📊 Status: Waiting for jobs...",
        player.Name,
        TargetPet,
        jobsCompleted,
        #myPets,
        speedCoilActive and "Active" or "Inactive",
        HoldTime
    )
end

local currentJob = nil

local function DoHolderJob(job)
    currentJob = job
    
    statusText.Text = "Status : Job received! Pet: " .. job.pet_name
    print("[HOLDER] 📥 Job received:", job.pet_name, "from", job.checker)
    
    -- Script này được chạy khi đã ở trong VIP server rồi
    -- Nhiệm vụ: Tìm pet và lấy
    
    task.wait(3)  -- Chờ load vào server
    
    statusText.Text = "Status : Searching for " .. job.pet_name .. "..."
    
    -- Tìm pet trong plot
    local foundPet = nil
    for i = 1, 10 do  -- Retry 10 lần
        local pets = GetPetsInMyPlot()
        for _, pet in ipairs(pets) do
            if pet.name == job.pet_name then
                foundPet = pet
                break
            end
        end
        
        if foundPet then break end
        task.wait(1)
    end
    
    if not foundPet then
        print("[HOLDER] ❌ Pet not found:", job.pet_name)
        statusText.Text = "Status : Pet not found! Completing anyway..."
        task.wait(2)
        ServerAPI.CompleteJob(player.Name)
        currentJob = nil
        return
    end
    
    -- Di chuyển đến pet
    local targetPos = Vector3.new(foundPet.position.x, foundPet.position.y, foundPet.position.z)
    statusText.Text = "Status : Walking to " .. job.pet_name
    
    if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
        speedCoilActive = false
        
        statusText.Text = "Status : Arrived! Waiting..."
        task.wait(2)
        
        -- Camera adjustment
        AdjustCameraBehindPlayer(targetPos)
        task.wait(1)
        
        -- Hold E
        statusText.Text = "Status : Holding E on " .. job.pet_name
        HoldKeyEReal(HoldTime)
        
        -- Return home
        local myPlot = GetMyPlot()
        local homePos = GetHomeSpawn(myPlot)
        if homePos then
            statusText.Text = "Status : Returning home..."
            WalkToPosition(homePos + Vector3.new(0, 2, 0))
            
            if not speedCoilBought then
                task.wait(1.5)
                local claimPos = GetAnimalPodiumClaim(myPlot)
                if claimPos then
                    statusText.Text = "Status : Going to Podium..."
                    if WalkToPosition(claimPos + Vector3.new(0, 2, 0)) then
                        task.wait(0.5)
                        BuySpeedCoil()
                        task.wait(1)
                        EquipSpeedCoil()
                    end
                end
            else
                task.wait(0.5)
                EquipSpeedCoil()
            end
        end
        
        -- Complete job
        ServerAPI.CompleteJob(player.Name)
        jobsCompleted = jobsCompleted + 1
        
        statusText.Text = "Status : Job completed! (" .. jobsCompleted .. " total)"
        print("[HOLDER] ✅ Job completed!")
        
        UpdateHolderInfo()
        currentJob = nil
        
        -- Server sẽ kick account sau khi complete
        task.wait(2)
    else
        print("[HOLDER] ❌ Cannot walk to pet")
        statusText.Text = "Status : Failed to reach pet"
        ServerAPI.CompleteJob(player.Name)
        currentJob = nil
    end
end

local function HolderLoop()
    while true do
        pcall(function()
            if currentJob then
                -- Đang làm job, chờ
                task.wait(1)
                return
            end
            
            statusText.Text = "Status : Checking for new jobs..."
            
            local response = ServerAPI.GetHolderJob(player.Name)
            
            if response and response.success and response.has_job then
                local job = response.job
                print("[HOLDER] 🎯 New job available:", job.pet_name)
                
                -- Note: Khi có job, server đã launch holder vào VIP rồi
                -- Script này chỉ cần detect và xử lý
                DoHolderJob(job)
            else
                statusText.Text = "Status : No jobs available, waiting..."
            end
        end)
        
        task.wait(5)
    end
end

-- ===== HEARTBEAT LOOP =====
local function HeartbeatLoop()
    while true do
        pcall(function()
            ServerAPI.Heartbeat(player.Name, AccountMode == "Checker" and "checker" or "holder")
        end)
        task.wait(10)
    end
end

-- ===== KHỞI ĐỘNG =====
print("🚀 Connecting to server:", SERVER_URL)

if AccountMode == "Checker" then
    local response = ServerAPI.RegisterChecker(player.Name)
    if response and response.success then
        print("[✅] Registered as CHECKER:", player.Name)
        print("[✅] VIP Link:", response.vip_link)
        statusText.Text = "Status : Registered as Checker"
        
        UpdateCheckerInfo()
        task.spawn(CheckerLoop)
        task.spawn(function()
            while true do
                pcall(UpdateCheckerInfo)
                task.wait(3)
            end
        end)
    else
        warn("[❌] Không thể đăng ký checker!")
        if response and response.error then
            warn("[❌]", response.error)
        end
        statusText.Text = "Status : Registration failed - Check data.txt"
    end
else
    local response = ServerAPI.RegisterHolder(player.Name)
    if response and response.success then
        print("[✅] Registered as HOLDER:", player.Name, "→", TargetPet)
        statusText.Text = "Status : Registered as Holder"
        
        UpdateHolderInfo()
        task.spawn(HolderLoop)
        task.spawn(function()
            while true do
                pcall(UpdateHolderInfo)
                task.wait(3)
            end
        end)
    else
        warn("[❌] Không thể đăng ký holder!")
        statusText.Text = "Status : Registration failed"
    end
end

task.spawn(HeartbeatLoop)
print("✅ Enhanced VIP System loaded!")
