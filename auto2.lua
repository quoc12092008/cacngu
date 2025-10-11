-- ═══════════════════════════════════════════════════════════════
--    🎮 ENHANCED VIP PET FARM SYSTEM
-- ═══════════════════════════════════════════════════════════════
-- Execute với config:
-- getgenv().EnhancedVIPConfig = {
--     ServerURL = "http://localhost:5000",
--     CheckerAccounts = {"CheckerAcc1"},
--     HolderConfig = {
--         {AccountName = "HolderAcc1", TargetPet = "Banana"},
--     },
--     HoldTime = 3.5,
--     CheckInterval = 5,
-- }
-- loadstring(game:HttpGet("YOUR_RAW_GITHUB_LINK"))()
-- ═══════════════════════════════════════════════════════════════

-- Check config
if not getgenv().EnhancedVIPConfig then
    error([[
╔═══════════════════════════════════════════════════════════════╗
║  ❌ MISSING CONFIG!                                           ║
╚═══════════════════════════════════════════════════════════════╝

Please set config first:

getgenv().EnhancedVIPConfig = {
    ServerURL = "http://localhost:5000",
    CheckerAccounts = {"YourChecker"},
    HolderConfig = {
        {AccountName = "YourHolder", TargetPet = "Banana"},
    },
    HoldTime = 3.5,
    CheckInterval = 5,
}

Then run the script again!
    ]])
    return
end

-- Load config
local Config = getgenv().EnhancedVIPConfig
local SERVER_URL = Config.ServerURL or "http://localhost:5000"
local CheckerAccounts = Config.CheckerAccounts or {}
local HolderConfig = Config.HolderConfig or {}
local HoldTime = Config.HoldTime or 3.5
local CheckInterval = Config.CheckInterval or 8
local ShowDetailedLogs = Config.ShowDetailedLogs or false

-- Validate config
if #CheckerAccounts == 0 and #HolderConfig == 0 then
    error("❌ Config must have at least 1 Checker or 1 Holder!")
    return
end

-- ===== HTTP SETUP =====
local HttpService = game:GetService("HttpService")
local http = syn and syn.request or http_request or request or fluxus and fluxus.request

if not http then
    error("❌ Executor không hỗ trợ HTTP requests!")
    return
end

-- ===== SERVICES =====
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

-- ===== LOGGING =====
local function Log(message, level)
    level = level or "INFO"
    if ShowDetailedLogs or level == "ERROR" or level == "SUCCESS" then
        local prefix = level == "ERROR" and "[❌]" or level == "SUCCESS" and "[✅]" or "[ℹ️]"
        print(prefix, message)
    end
end

-- ===== HTTP HELPER =====
local function HttpPost(endpoint, data)
    for attempt = 1, 3 do
        local success, result = pcall(function()
            local response = http({
                Url = SERVER_URL .. endpoint,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
            
            if response.Success or response.StatusCode == 200 then
                return HttpService:JSONDecode(response.Body)
            end
            error("HTTP Error: " .. tostring(response.StatusCode))
        end)
        
        if success then return result end
        if attempt < 3 then task.wait(2) end
    end
    return nil
end

-- ===== XÁC ĐỊNH ROLE =====
local AccountMode, TargetPet = nil, nil

for _, name in ipairs(CheckerAccounts) do
    if name == player.Name then
        AccountMode = "Checker"
        break
    end
end

if not AccountMode then
    for _, cfg in ipairs(HolderConfig) do
        if cfg.AccountName == player.Name then
            AccountMode = "Holder"
            TargetPet = cfg.TargetPet
            break
        end
    end
end

if not AccountMode then
    error(string.format([[
╔═══════════════════════════════════════════════════════════════╗
║  ❌ ACCOUNT NOT IN CONFIG!                                    ║
╚═══════════════════════════════════════════════════════════════╝

Current account: %s

This account is not listed in:
  • CheckerAccounts
  • HolderConfig

Please add it to your config!
    ]], player.Name))
    return
end

Log(string.format("Account: %s | Mode: %s", player.Name, AccountMode), "SUCCESS")
if TargetPet then Log("Target Pet: " .. TargetPet, "INFO") end

-- ===== API =====
local API = {}

function API.RegisterChecker(username)
    return HttpPost("/register_checker", {username = username})
end

function API.RegisterHolder(username)
    return HttpPost("/register_holder", {username = username})
end

function API.Heartbeat(username, type)
    return HttpPost("/heartbeat", {username = username, type = type})
end

function API.SubmitPet(username, pet_name)
    return HttpPost("/submit_pet", {username = username, pet_name = pet_name})
end

function API.GetHolderJob(username)
    return HttpPost("/get_holder_job", {username = username})
end

function API.CompleteJob(username)
    return HttpPost("/complete_job", {username = username})
end

-- ===== UI =====
if game.CoreGui:FindFirstChild("EnhancedPetFarm") then
    game.CoreGui.EnhancedPetFarm:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "EnhancedPetFarm"
gui.Parent = game.CoreGui

local statusFrame = Instance.new("Frame")
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
statusText.TextColor3 = statusStroke.Color
statusText.TextSize = 16
statusText.Text = "Status : Connecting..."
statusText.Parent = statusFrame

local titleText = Instance.new("TextLabel")
titleText.Text = "Enhanced VIP System - " .. AccountMode
titleText.Position = UDim2.new(0.5, 0, 0.06, 0)
titleText.AnchorPoint = Vector2.new(0.5, 0)
titleText.Size = UDim2.new(0, 300, 0, 20)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextColor3 = statusStroke.Color
titleText.TextSize = 13
titleText.Parent = gui

local mainFrame = Instance.new("Frame")
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
mainStroke.Color = statusStroke.Color
mainStroke.Thickness = 2.5
mainStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = AccountMode == "Checker" and "🔍 CHECKER MODE" or "🤖 HOLDER MODE"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = statusStroke.Color
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.92, 0, 0, 2)
divider.Position = UDim2.new(0.04, 0, 0, 50)
divider.BackgroundColor3 = statusStroke.Color
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
infoText.Text = "Initializing..."
infoText.Parent = mainFrame

-- ===== PLOT FUNCTIONS =====
local function GetMyPlot()
    local myPlot = PlotController.GetMyPlot()
    return myPlot and myPlot.PlotModel or nil
end

local function GetHomeSpawn(myPlot)
    if not myPlot then return nil end
    local deco = myPlot:FindFirstChild("Decorations")
    if not deco then return nil end
    local spawnPart = deco:GetChildren()[12]
    return spawnPart and spawnPart.CFrame and spawnPart.CFrame.Position or nil
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
    return main and main.CFrame and main.CFrame.Position or nil
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
        if obj:IsA("Model") then
            local shouldSkip = false
            for _, skipWord in ipairs(skipList) do
                if string.find(string.lower(obj.Name), string.lower(skipWord)) then
                    shouldSkip = true
                    break
                end
            end
            
            if not shouldSkip and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) then
                local pos = obj:GetPivot().Position
                table.insert(pets, {
                    name = obj.Name,
                    position = {x = pos.X, y = pos.Y, z = pos.Z}
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

    if path.Status ~= Enum.PathStatus.Success then return false end

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

local function HoldKeyE(duration)
    local start = tick()
    while tick() - start < duration do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        RunService.Heartbeat:Wait()
    end
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function AdjustCamera(petPosition)
    local cam = Workspace.CurrentCamera
    if not cam or not hrp then return end
    
    local direction = (petPosition - hrp.Position).Unit
    local behindOffset = -direction * 5 + Vector3.new(0, 3, 0)
    local camPos = hrp.Position + behindOffset
    
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0, 2, 0))
    
    task.delay(4, function()
        if cam then
            cam.CameraType = Enum.CameraType.Custom
        end
    end)
end

-- ===== SPEED COIL =====
local speedCoilBought = false
local speedCoilActive = false
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net", 10)
local remotePath = "RF/CoinsShopService/RequestBuy"
local remoteFunction = Net and Net:FindFirstChild(remotePath, true)

local function BuySpeedCoil()
    if speedCoilBought or not remoteFunction then return end
    pcall(function()
        remoteFunction:InvokeServer("Speed Coil")
        speedCoilBought = true
        Log("Speed Coil bought", "SUCCESS")
    end)
end

local function EquipSpeedCoil()
    if not speedCoilBought then return end
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
    speedCoilActive = true
    Log("Speed Coil equipped", "INFO")
end

-- ===== CHECKER MODE =====
local petsSubmitted = 0

local function UpdateCheckerInfo()
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
        player.Name, #myPets, petsSubmitted, petList
    )
end

local function CheckerLoop()
    while true do
        pcall(function()
            local pets = GetPetsInMyPlot()
            
            if #pets == 0 then
                statusText.Text = "Status : No pets - Waiting..."
                task.wait(15)
                return
            end
            
            for _, pet in ipairs(pets) do
                statusText.Text = "Status : Submitting " .. pet.name
                
                local response = API.SubmitPet(player.Name, pet.name)
                
                if response and response.success then
                    petsSubmitted = petsSubmitted + 1
                    
                    if response.status == "queued" then
                        statusText.Text = "Status : Pet queued (waiting holder)"
                        Log(string.format("Pet queued: %s", pet.name), "INFO")
                    else
                        statusText.Text = "Status : Pet assigned to " .. (response.assigned_to or "holder")
                        Log(string.format("Pet assigned: %s → %s", pet.name, response.assigned_to), "SUCCESS")
                    end
                else
                    statusText.Text = "Status : Failed to submit"
                    Log("Failed to submit pet: " .. pet.name, "ERROR")
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

local function UpdateHolderInfo()
    local myPets = GetPetsInMyPlot()
    infoText.Text = string.format(
        "👤 Username: %s\n" ..
        "🎯 Target Pet: %s\n" ..
        "✅ Jobs Completed: %d\n" ..
        "🏠 Pets in Plot: %d\n" ..
        "⚡ Speed Coil: %s\n" ..
        "⏱️ Hold Time: %.1fs\n" ..
        "📊 Status: Waiting for jobs...",
        player.Name, TargetPet, jobsCompleted, #myPets,
        speedCoilActive and "Active" or "Inactive", HoldTime
    )
end

local currentJob = nil

local function DoHolderJob(job)
    currentJob = job
    statusText.Text = "Status : Job received! Pet: " .. job.pet_name
    Log(string.format("Job received: %s from %s", job.pet_name, job.checker), "SUCCESS")
    
    task.wait(3)
    
    statusText.Text = "Status : Searching for " .. job.pet_name
    
    local foundPet = nil
    for i = 1, 10 do
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
        Log("Pet not found: " .. job.pet_name, "ERROR")
        statusText.Text = "Status : Pet not found!"
        task.wait(2)
        API.CompleteJob(player.Name)
        currentJob = nil
        return
    end
    
    local targetPos = Vector3.new(foundPet.position.x, foundPet.position.y, foundPet.position.z)
    statusText.Text = "Status : Walking to " .. job.pet_name
    
    if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
        speedCoilActive = false
        
        statusText.Text = "Status : Arrived! Waiting..."
        task.wait(2)
        
        AdjustCamera(targetPos)
        task.wait(1)
        
        statusText.Text = "Status : Holding E on " .. job.pet_name
        HoldKeyE(HoldTime)
        
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
        
        API.CompleteJob(player.Name)
        jobsCompleted = jobsCompleted + 1
        
        statusText.Text = "Status : Job completed! (" .. jobsCompleted .. " total)"
        Log("Job completed!", "SUCCESS")
        
        UpdateHolderInfo()
        currentJob = nil
        task.wait(2)
    else
        Log("Cannot walk to pet", "ERROR")
        statusText.Text = "Status : Failed to reach pet"
        API.CompleteJob(player.Name)
        currentJob = nil
    end
end

local function HolderLoop()
    while true do
        pcall(function()
            if currentJob then
                task.wait(1)
                return
            end
            
            statusText.Text = "Status : Checking for jobs..."
            
            local response = API.GetHolderJob(player.Name)
            
            if response and response.success and response.has_job then
                local job = response.job
                Log("New job available: " .. job.pet_name, "INFO")
                DoHolderJob(job)
            else
                statusText.Text = "Status : No jobs, waiting..."
            end
        end)
        
        task.wait(5)
    end
end

-- ===== HEARTBEAT =====
local function HeartbeatLoop()
    while true do
        pcall(function()
            API.Heartbeat(player.Name, AccountMode == "Checker" and "checker" or "holder")
        end)
        task.wait(10)
    end
end

-- ===== KHỞI ĐỘNG =====
Log("Connecting to: " .. SERVER_URL, "INFO")

if AccountMode == "Checker" then
    local response = API.RegisterChecker(player.Name)
    if response and response.success then
        Log("Registered as CHECKER", "SUCCESS")
        Log("VIP Link: " .. (response.vip_link or "N/A"), "INFO")
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
        Log("Registration failed! Check data.txt", "ERROR")
        if response then Log("Error: " .. (response.error or "Unknown"), "ERROR") end
        statusText.Text = "Status : Failed - Check data.txt"
    end
else
    local response = API.RegisterHolder(player.Name)
    if response and response.success then
        Log(string.format("Registered as HOLDER → %s", TargetPet), "SUCCESS")
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
        Log("Registration failed!", "ERROR")
        statusText.Text = "Status : Failed"
    end
end

task.spawn(HeartbeatLoop)
Log("Enhanced VIP System loaded!", "SUCCESS")

-- ===== HTTP SETUP =====
local HttpService = game:GetService("HttpService")
local http = syn and syn.request or http_request or request or fluxus and fluxus.request

if not http then
    error("❌ Executor không hỗ trợ HTTP!")
    return
end

-- ===== SERVICES =====
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

-- ===== HTTP HELPER =====
local function HttpPost(endpoint, data)
    for attempt = 1, 3 do
        local success, result = pcall(function()
            local response = http({
                Url = SERVER_URL .. endpoint,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
            
            if response.Success or response.StatusCode == 200 then
                return HttpService:JSONDecode(response.Body)
            end
            error("HTTP Error: " .. tostring(response.StatusCode))
        end)
        
        if success then return result end
        if attempt < 3 then task.wait(2) end
    end
    return nil
end

-- ===== XÁC ĐỊNH ROLE =====
local AccountMode, TargetPet = nil, nil

for _, name in ipairs(CheckerAccounts) do
    if name == player.Name then
        AccountMode = "Checker"
        break
    end
end

if not AccountMode then
    for _, cfg in ipairs(HolderConfig) do
        if cfg.AccountName == player.Name then
            AccountMode = "Holder"
            TargetPet = cfg.TargetPet
            break
        end
    end
end

if not AccountMode then
    error("❌ Account không có trong config!")
    return
end

print("========================================")
print(AccountMode == "Checker" and "🔍 [CHECKER MODE]" or "🤖 [HOLDER MODE]")
print("Account:", player.Name)
if TargetPet then print("Target Pet:", TargetPet) end
print("========================================")

-- ===== API =====
local API = {}

function API.RegisterChecker(username)
    return HttpPost("/register_checker", {username = username})
end

function API.RegisterHolder(username)
    return HttpPost("/register_holder", {username = username})
end

function API.Heartbeat(username, type)
    return HttpPost("/heartbeat", {username = username, type = type})
end

function API.SubmitPet(username, pet_name)
    return HttpPost("/submit_pet", {username = username, pet_name = pet_name})
end

function API.GetHolderJob(username)
    return HttpPost("/get_holder_job", {username = username})
end

function API.CompleteJob(username)
    return HttpPost("/complete_job", {username = username})
end

-- ===== UI =====
if game.CoreGui:FindFirstChild("EnhancedPetFarm") then
    game.CoreGui.EnhancedPetFarm:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "EnhancedPetFarm"
gui.Parent = game.CoreGui

local statusFrame = Instance.new("Frame")
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
statusText.TextColor3 = statusStroke.Color
statusText.TextSize = 16
statusText.Text = "Status : Connecting..."
statusText.Parent = statusFrame

local titleText = Instance.new("TextLabel")
titleText.Text = "Enhanced VIP System - " .. AccountMode
titleText.Position = UDim2.new(0.5, 0, 0.06, 0)
titleText.AnchorPoint = Vector2.new(0.5, 0)
titleText.Size = UDim2.new(0, 300, 0, 20)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextColor3 = statusStroke.Color
titleText.TextSize = 13
titleText.Parent = gui

local mainFrame = Instance.new("Frame")
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
mainStroke.Color = statusStroke.Color
mainStroke.Thickness = 2.5
mainStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = AccountMode == "Checker" and "🔍 CHECKER MODE" or "🤖 HOLDER MODE"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = statusStroke.Color
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.92, 0, 0, 2)
divider.Position = UDim2.new(0.04, 0, 0, 50)
divider.BackgroundColor3 = statusStroke.Color
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
    return myPlot and myPlot.PlotModel or nil
end

local function GetHomeSpawn(myPlot)
    if not myPlot then return nil end
    local deco = myPlot:FindFirstChild("Decorations")
    if not deco then return nil end
    local spawnPart = deco:GetChildren()[12]
    return spawnPart and spawnPart.CFrame and spawnPart.CFrame.Position or nil
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
    return main and main.CFrame and main.CFrame.Position or nil
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
        if obj:IsA("Model") then
            local shouldSkip = false
            for _, skipWord in ipairs(skipList) do
                if string.find(string.lower(obj.Name), string.lower(skipWord)) then
                    shouldSkip = true
                    break
                end
            end
            
            if not shouldSkip and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) then
                local pos = obj:GetPivot().Position
                table.insert(pets, {
                    name = obj.Name,
                    position = {x = pos.X, y = pos.Y, z = pos.Z}
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

    if path.Status ~= Enum.PathStatus.Success then return false end

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

local function HoldKeyE(duration)
    local start = tick()
    while tick() - start < duration do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        RunService.Heartbeat:Wait()
    end
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function AdjustCamera(petPosition)
    local cam = Workspace.CurrentCamera
    if not cam or not hrp then return end
    
    local direction = (petPosition - hrp.Position).Unit
    local behindOffset = -direction * 5 + Vector3.new(0, 3, 0)
    local camPos = hrp.Position + behindOffset
    
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0, 2, 0))
    
    task.delay(4, function()
        if cam then
            cam.CameraType = Enum.CameraType.Custom
        end
    end)
end

-- ===== SPEED COIL =====
local speedCoilBought = false
local speedCoilActive = false
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net", 10)
local remotePath = "RF/CoinsShopService/RequestBuy"
local remoteFunction = Net and Net:FindFirstChild(remotePath, true)

local function BuySpeedCoil()
    if speedCoilBought or not remoteFunction then return end
    pcall(function()
        remoteFunction:InvokeServer("Speed Coil")
        speedCoilBought = true
        print("[✅] Speed Coil bought")
    end)
end

local function EquipSpeedCoil()
    if not speedCoilBought then return end
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
    speedCoilActive = true
    print("[⚡] Speed Coil equipped")
end

-- ===== CHECKER MODE =====
local petsSubmitted = 0

local function UpdateCheckerInfo()
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
        player.Name, #myPets, petsSubmitted, petList
    )
end

local function CheckerLoop()
    while true do
        pcall(function()
            local pets = GetPetsInMyPlot()
            
            if #pets == 0 then
                statusText.Text = "Status : No pets - Waiting..."
                task.wait(15)
                return
            end
            
            for _, pet in ipairs(pets) do
                statusText.Text = "Status : Submitting " .. pet.name
                
                local response = API.SubmitPet(player.Name, pet.name)
                
                if response and response.success then
                    petsSubmitted = petsSubmitted + 1
                    
                    if response.status == "queued" then
                        statusText.Text = "Status : Pet queued (waiting holder)"
                    else
                        statusText.Text = "Status : Pet assigned to " .. response.assigned_to
                    end
                else
                    statusText.Text = "Status : Failed to submit"
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

local function UpdateHolderInfo()
    local myPets = GetPetsInMyPlot()
    infoText.Text = string.format(
        "👤 Username: %s\n" ..
        "🎯 Target Pet: %s\n" ..
        "✅ Jobs Completed: %d\n" ..
        "🏠 Pets in Plot: %d\n" ..
        "⚡ Speed Coil: %s\n" ..
        "⏱️ Hold Time: %.1fs\n" ..
        "📊 Status: Waiting for jobs...",
        player.Name, TargetPet, jobsCompleted, #myPets,
        speedCoilActive and "Active" or "Inactive", HoldTime
    )
end

local currentJob = nil

local function DoHolderJob(job)
    currentJob = job
    statusText.Text = "Status : Job received! Pet: " .. job.pet_name
    print("[HOLDER] 📥 Job:", job.pet_name, "from", job.checker)
    
    task.wait(3)
    
    statusText.Text = "Status : Searching for " .. job.pet_name
    
    local foundPet = nil
    for i = 1, 10 do
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
        statusText.Text = "Status : Pet not found!"
        task.wait(2)
        API.CompleteJob(player.Name)
        currentJob = nil
        return
    end
    
    local targetPos = Vector3.new(foundPet.position.x, foundPet.position.y, foundPet.position.z)
    statusText.Text = "Status : Walking to " .. job.pet_name
    
    if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
        speedCoilActive = false
        
        statusText.Text = "Status : Arrived! Waiting..."
        task.wait(2)
        
        AdjustCamera(targetPos)
        task.wait(1)
        
        statusText.Text = "Status : Holding E on " .. job.pet_name
        HoldKeyE(HoldTime)
        
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
        
        API.CompleteJob(player.Name)
        jobsCompleted = jobsCompleted + 1
        
        statusText.Text = "Status : Job completed! (" .. jobsCompleted .. " total)"
        print("[HOLDER] ✅ Job completed!")
        
        UpdateHolderInfo()
        currentJob = nil
        task.wait(2)
    else
        print("[HOLDER] ❌ Cannot walk to pet")
        statusText.Text = "Status : Failed to reach pet"
        API.CompleteJob(player.Name)
        currentJob = nil
    end
end

local function HolderLoop()
    while true do
        pcall(function()
            if currentJob then
                task.wait(1)
                return
            end
            
            statusText.Text = "Status : Checking for jobs..."
            
            local response = API.GetHolderJob(player.Name)
            
            if response and response.success and response.has_job then
                local job = response.job
                print("[HOLDER] 🎯 New job:", job.pet_name)
                DoHolderJob(job)
            else
                statusText.Text = "Status : No jobs, waiting..."
            end
        end)
        
        task.wait(5)
    end
end

-- ===== HEARTBEAT =====
local function HeartbeatLoop()
    while true do
        pcall(function()
            API.Heartbeat(player.Name, AccountMode == "Checker" and "checker" or "holder")
        end)
        task.wait(10)
    end
end

-- ===== KHỞI ĐỘNG =====
print("🚀 Connecting to:", SERVER_URL)

if AccountMode == "Checker" then
    local response = API.RegisterChecker(player.Name)
    if response and response.success then
        print("[✅] Registered as CHECKER")
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
        warn("[❌] Registration failed!")
        if response then warn("[❌]", response.error) end
        statusText.Text = "Status : Failed - Check data.txt"
    end
else
    local response = API.RegisterHolder(player.Name)
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
        warn("[❌] Registration failed!")
        statusText.Text = "Status : Failed"
    end
end

task.spawn(HeartbeatLoop)
print("✅ Enhanced VIP System loaded!")
