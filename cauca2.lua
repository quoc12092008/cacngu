-- // COMBINED SCRIPT: LOGIC CÂU CÁ (TỪ CAUCA1) + AUTO DỌN PET/WEBHOOK (TỪ CAUCA2)
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Modules cho Clean Plot (Từ Cauca2)
local Animals = require(ReplicatedStorage.Datas.Animals)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

-- Net System
local Net = require(ReplicatedStorage.Packages.Net)

-- Remotes Fishing (Lấy chuẩn từ Cauca1 để đảm bảo hoạt động)
local CastRE        = Net:RemoteEvent("FishingRod.Cast")
local CancelRE      = Net:RemoteEvent("FishingRod.Cancel")
local SetupBobberRE = Net:RemoteEvent("FishingRod.SetupBobber")
local MinigameClick = Net:RemoteEvent("FishingRod.MinigameClick")
local RewardRE      = Net:RemoteEvent("FishingRod.Reward")
local BiteRE        = Net:RemoteEvent("FishingRod.BiteGot")
local SellRemote    = ReplicatedStorage.Packages.Net["RE/PlotService/Sell"] -- Dùng cho clean plot

-- Remotes Shop
local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
local BuyRodRF   = NetFolder:WaitForChild("RF/RodsShopService/RequestBuy")
local EquipRodRF = NetFolder:WaitForChild("RF/RodsShopService/RequestEquip")

--------------------------------------------------------
-- ⚙ CẤU HÌNH (CONFIG)
--------------------------------------------------------
getgenv().AUTO_FISH         = true   -- Bật tắt auto câu
getgenv().AUTO_BEST_ROD     = true   -- Auto mua cần xịn
getgenv().AUTO_EQUIP_ROD    = true   -- Auto cầm cần
getgenv().EVENT_WEBHOOK     = getgenv().EVENT_WEBHOOK or "" -- Link webhook của bạn

-- Cấu hình Clean Plot
local AUTO_CLEAN_PLOT = true
local CLEAN_DELAY     = 1

----------------------------------------------------------------
-- 🟡 PHẦN 1: LOGIC DỌN PET & WEBHOOK (TỪ CAUCA2)
----------------------------------------------------------------

-- 1. Load Danh sách Pet
local function LoadPetCategories()
    local AllowedSet = {}
    local Secret, OG, LuckyBlocks = {}, {}, {}

    for name, data in pairs(Animals) do
        local rarity = data.Rarity or ""
        local lname = name:lower()
        local lrar = rarity:lower()

        if rarity == "Secret" then
            AllowedSet[name] = true
            table.insert(Secret, name)
        elseif rarity == "OG" then
            AllowedSet[name] = true
            table.insert(OG, name)
        elseif lname:find("lucky block") or lrar:find("lucky") then
            AllowedSet[name] = true
            table.insert(LuckyBlocks, name)
        end
    end
    return { AllowedSet = AllowedSet, Secret = Secret, OG = OG, LuckyBlocks = LuckyBlocks }
end

-- 2. Lấy Pet trong Plot
local function GetAnimalList()
    local sync = Synchronizer:Get(LocalPlayer)
    if sync then
        local ok, list = pcall(function() return sync:Get("AnimalPodiums") end)
        if ok and list then return list end
    end
    local ok2, PlotController = pcall(function() return require(ReplicatedStorage.Controllers.PlotController) end)
    if ok2 and PlotController then
        local myPlot = PlotController.GetMyPlot()
        if myPlot and myPlot.Channel then
            local ok3, list = pcall(function() return myPlot.Channel:Get("AnimalList") end)
            if ok3 and list then return list end
        end
    end
    return {}
end

-- 3. Xóa Pet Rác
local function CleanPlot(categories)
    local allowed = categories.AllowedSet
    local pets = GetAnimalList()
    local kept, deleted, total = 0, 0, 0

    for index, data in pairs(pets) do
        if data and data.Index then
            local name = data.Index
            total += 1
            if allowed[name] then
                kept += 1
            else
                deleted += 1
                pcall(function() SellRemote:FireServer(index) end)
            end
        end
    end
    -- print(string.format("🐾 CLEAN: Total %d | Keep %d | Deleted %d", total, kept, deleted))
end

-- 4. Webhook Event
local EventPets = {
    ["Tralaledon"] = true, ["Eviledon"] = true, ["Los Primos"] = true, 
    ["Orcaledon"] = true, ["Capitano Moby"] = true,
}
local EventCounter = 0
local HasSentWebhook = false

local function GetPetNameById(id)
    for name, data in pairs(Animals) do
        if tostring(data.Id) == tostring(id) then return name end
    end
end

local function SendEventWebhook()
    if HasSentWebhook then return end
    if not getgenv().EVENT_WEBHOOK or getgenv().EVENT_WEBHOOK == "" then return end

    local msg = {
        username = "Fishing Event Tracker",
        embeds = {{
            title = "🎉 ĐỦ 5 PET SỰ KIỆN!",
            description = "**Bạn đã câu đủ 5 PET SỰ KIỆN!**",
            color = 16753920,
            fields = {
                { name = "🎣 Danh sách:", value = "• Tralaledon\n• Eviledon\n• Los Primos\n• Orcaledon\n• Capitano Moby" },
                { name = "⭐ Tổng số:", value = tostring(EventCounter) }
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    local req = http_request or request or syn.request
    if req then
        req({ Url = getgenv().EVENT_WEBHOOK, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(msg) })
    end
    HasSentWebhook = true
end

----------------------------------------------------------------
-- 🎣 PHẦN 2: LOGIC CÂU CÁ CHUẨN (LẤY TỪ CAUCA1)
----------------------------------------------------------------

-- Danh sách cần câu
local RodPriority = {
    "Radioactive Rod",
    "Fiery Rod",
    "Frozen Rod",
    "Starter Rod",
}

local currentRodTool = nil

-- Cập nhật biến currentRodTool
local function UpdateCurrentRodTool()
    local char = LocalPlayer.Character
    currentRodTool = nil
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") and obj.Name:find("Rod") then
            currentRodTool = obj
            break
        end
    end
end

-- Equip cần đang có trong Balo
local function EquipCurrentRodTool()
    if not getgenv().AUTO_EQUIP_ROD then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if char:FindFirstChildOfClass("Tool") then return end -- Đã cầm gì đó rồi

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end

    local targetTool = nil
    local equippedRodName = LocalPlayer:GetAttribute("EquippedFishingRod")

    if equippedRodName and backpack:FindFirstChild(equippedRodName) then
        targetTool = backpack[equippedRodName]
    else
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name:find("Rod") then
                targetTool = t
                break
            end
        end
    end

    if targetTool then hum:EquipTool(targetTool) end
end

-- Mua và Equip cần xịn nhất
local function AutoBuyAndEquipBestRod()
    if not getgenv().AUTO_BEST_ROD then return end
    for _, rodName in ipairs(RodPriority) do
        -- 1. Thử Equip
        pcall(function() EquipRodRF:InvokeServer(rodName) end)
        task.wait(0.2)
        if LocalPlayer:GetAttribute("EquippedFishingRod") == rodName then
            EquipCurrentRodTool()
            return
        end
        -- 2. Thử Mua
        pcall(function() BuyRodRF:InvokeServer(rodName) end)
        task.wait(0.2)
        -- 3. Equip lại sau khi mua
        pcall(function() EquipRodRF:InvokeServer(rodName) end)
        task.wait(0.2)
        if LocalPlayer:GetAttribute("EquippedFishingRod") == rodName then
            EquipCurrentRodTool()
            return
        end
    end
end

-- Auto Minigame (Click chuẩn theo HP)
local lastMiniClick = 0
local function AutoPerfectMinigame()
    if not currentRodTool then return end
    if not currentRodTool:GetAttribute("minigame") then return end

    local hits = currentRodTool:GetAttribute("minigameHits")
    local hp   = currentRodTool:GetAttribute("minigameHP")

    if not hits or not hp or hp == 0 then return end

    -- Click mỗi 0.12s
    if tick() - lastMiniClick > 0.12 then
        lastMiniClick = tick()
        MinigameClick:FireServer()
    end
end

-- Auto Cast (Thả cần)
local function AutoCast()
    if not currentRodTool then return end
    if currentRodTool:GetAttribute("minigame") then return end
    if currentRodTool:GetAttribute("casted") then return end
    if currentRodTool:GetAttribute("castCooldown") then return end

    local power = math.random(90, 100) / 100
    CastRE:FireServer(power)
end

-- Khi cá cắn -> Click ngay
BiteRE.OnClientEvent:Connect(function(playerWhoGotBite)
    if not getgenv().AUTO_FISH then return end
    if playerWhoGotBite ~= LocalPlayer then return end
    MinigameClick:FireServer()
end)

-- Khi câu xong -> Gộp logic Webhook + Tự câu lại
RewardRE.OnClientEvent:Connect(function(pPlayer, bobber, pos, _, animalId, _)
    if pPlayer ~= LocalPlayer then return end
    
    -- LOGIC 1: Check Webhook Event (Từ Cauca2)
    local petName = GetPetNameById(animalId)
    if petName and EventPets[petName] then
        EventCounter += 1
        print("🔥 EVENT PET:", petName, "| Count:", EventCounter)
        if EventCounter >= 5 then SendEventWebhook() end
    end

    -- LOGIC 2: Tự thả cần lại (Từ Cauca1)
    if getgenv().AUTO_FISH then
        task.delay(0.7, function()
            AutoCast()
        end)
    end
end)

-- Cập nhật trạng thái khi cầm tool
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    UpdateCurrentRodTool()
    AutoBuyAndEquipBestRod()
    EquipCurrentRodTool()
    
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name:find("Rod") then currentRodTool = child end
    end)
    char.ChildRemoved:Connect(function(child)
        if child == currentRodTool then currentRodTool = nil end
    end)
end)

if LocalPlayer.Character then
    task.wait(1)
    UpdateCurrentRodTool()
    AutoBuyAndEquipBestRod()
    EquipCurrentRodTool()
end

----------------------------------------------------------------
-- 🔁 CÁC VÒNG LẶP (LOOPS)
----------------------------------------------------------------

-- Loop Auto Fish (Chuẩn Cauca1)
task.spawn(function()
    while task.wait(0.05) do
        if getgenv().AUTO_FISH then
            if not currentRodTool then
                EquipCurrentRodTool()
                AutoBuyAndEquipBestRod()
            else
                if currentRodTool:GetAttribute("minigame") then
                    AutoPerfectMinigame()
                else
                    AutoCast()
                end
            end
        end
    end
end)

-- Loop Clean Plot (Chuẩn Cauca2)
if AUTO_CLEAN_PLOT then
    task.spawn(function()
        while true do
            CleanPlot(LoadPetCategories())
            task.wait(CLEAN_DELAY)
        end
    end)
end

print("✅ FULL SCRIPT: AUTO FISH (FIXED) + CLEAN PLOT + WEBHOOK LOADED")
