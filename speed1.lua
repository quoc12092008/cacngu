-- Xóa UI cũ nếu có
if game.CoreGui:FindFirstChild("BananaStatsChecker") then
	game.CoreGui.BananaStatsChecker:Destroy()
end

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

-- Lấy PlotController
local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- Cấu hình từ getgenv
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 2

-- Xác định acc hiện tại
local CurrentPet = nil
local farmMode = "Checker"
local MyAccountConfig = nil

for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		farmMode = "Farmer"
		MyAccountConfig = cfg
		break
	end
end

-- 🔒 DANH SÁCH PET ĐANG BỊ CLAIM (shared giữa các acc)
local ClaimedPets = {}

-- ⚙️ Speed Coil System
local speedCoilActive = false
local speedCoilBought = false
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net", 10)
local remotePath = "RF/CoinsShopService/RequestBuy"
local remoteFunction = Net and Net:FindFirstChild(remotePath, true)

local function BuySpeedCoil()
	if speedCoilBought or not remoteFunction then return end
	
	local args = {[1] = "Speed Coil"}
	
	local success, result = pcall(function()
		return remoteFunction:InvokeServer(unpack(args))
	end)
	
	if success then
		speedCoilBought = true
		print("[✅] Mua Speed Coil thành công:", result)
	else
		warn("[❌] Lỗi khi mua Speed Coil:", result)
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

---------------------------------------------------------------------
-- 🎨 TẠO UI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "BananaStatsChecker"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

-- STATUS BOX
local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusBox"
statusFrame.AnchorPoint = Vector2.new(0.5, 0)
statusFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
statusFrame.Size = UDim2.new(0, 380, 0, 42)
statusFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
statusFrame.BackgroundTransparency = 0.2
statusFrame.Parent = gui

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = Color3.fromRGB(255, 180, 0)
statusStroke.Thickness = 2
statusStroke.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamBold
statusText.TextColor3 = Color3.fromRGB(255, 200, 40)
statusText.TextSize = 17
statusText.Text = "Status : Initializing..."
statusText.Parent = statusFrame

-- DISCORD TAG
local discordText = Instance.new("TextLabel")
discordText.Text = "Chúi Hub"
discordText.Position = UDim2.new(0.5, 0, 0.06, 0)
discordText.AnchorPoint = Vector2.new(0.5, 0)
discordText.Size = UDim2.new(0, 200, 0, 20)
discordText.BackgroundTransparency = 1
discordText.Font = Enum.Font.GothamBold
discordText.TextColor3 = Color3.fromRGB(255, 200, 0)
discordText.TextSize = 13
discordText.Parent = gui

-- MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.55, 0)
mainFrame.Size = UDim2.new(0, 720, 0, 340)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 180, 0)
mainStroke.Thickness = 2.5
mainStroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Text = "Chúi Hub "
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Divider
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.92, 0, 0, 2)
divider.Position = UDim2.new(0.04, 0, 0, 50)
divider.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- Cột trái
local leftColumn = Instance.new("Frame")
leftColumn.Position = UDim2.new(0.05, 0, 0, 70)
leftColumn.Size = UDim2.new(0.42, 0, 0, 240)
leftColumn.BackgroundTransparency = 1
leftColumn.Parent = mainFrame

local leftTitle = Instance.new("TextLabel")
leftTitle.Text = "Account Info"
leftTitle.Font = Enum.Font.GothamBold
leftTitle.TextSize = 18
leftTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
leftTitle.BackgroundTransparency = 1
leftTitle.Position = UDim2.new(0, 0, 0, 0)
leftTitle.Size = UDim2.new(1, 0, 0, 25)
leftTitle.Parent = leftColumn

-- Stats labels
local statLabels = {}
for i = 1, 6 do
	local statLabel = Instance.new("TextLabel")
	statLabel.Text = "Loading..."
	statLabel.Font = Enum.Font.GothamMedium
	statLabel.TextSize = 15
	statLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
	statLabel.BackgroundTransparency = 1
	statLabel.Position = UDim2.new(0, 10, 0, 30 + (i * 26))
	statLabel.Size = UDim2.new(1, -10, 0, 22)
	statLabel.TextXAlignment = Enum.TextXAlignment.Left
	statLabel.Parent = leftColumn
	statLabels[i] = statLabel
end

-- Divider vertical
local verticalDivider = Instance.new("Frame")
verticalDivider.Size = UDim2.new(0, 2, 0, 240)
verticalDivider.Position = UDim2.new(0.48, 0, 0, 70)
verticalDivider.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
verticalDivider.BackgroundTransparency = 0.5
verticalDivider.BorderSizePixel = 0
verticalDivider.Parent = mainFrame

-- Cột phải
local rightColumn = Instance.new("Frame")
rightColumn.Position = UDim2.new(0.53, 0, 0, 70)
rightColumn.Size = UDim2.new(0.42, 0, 0, 240)
rightColumn.BackgroundTransparency = 1
rightColumn.Parent = mainFrame

local rightTitle = Instance.new("TextLabel")
rightTitle.Text = "Pet Đang Có"
rightTitle.Font = Enum.Font.GothamBold
rightTitle.TextSize = 18
rightTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
rightTitle.BackgroundTransparency = 1
rightTitle.Position = UDim2.new(0, 0, 0, 0)
rightTitle.Size = UDim2.new(1, 0, 0, 25)
rightTitle.Parent = rightColumn

-- ScrollingFrame cho pets
local petScroll = Instance.new("ScrollingFrame")
petScroll.Position = UDim2.new(0, 0, 0, 30)
petScroll.Size = UDim2.new(1, 0, 1, -30)
petScroll.BackgroundTransparency = 1
petScroll.BorderSizePixel = 0
petScroll.ScrollBarThickness = 4
petScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 180, 0)
petScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
petScroll.Parent = rightColumn

local petListLayout = Instance.new("UIListLayout")
petListLayout.Padding = UDim.new(0, 6)
petListLayout.Parent = petScroll

---------------------------------------------------------------------
-- 🔧 CÁC HÀM FARM
---------------------------------------------------------------------
local function GetMyPlot()
	local myPlot = PlotController.GetMyPlot()
	if myPlot and myPlot.PlotModel then
		return myPlot.PlotModel
	end
	return nil
end

local function GetPlotOwner(plot)
	-- Tìm owner của plot từ tên hoặc properties
	for _, cfg in ipairs(AccHold) do
		local playerInGame = Players:FindFirstChild(cfg.AccountName)
		if playerInGame then
			local theirPlot = PlotController.GetPlot(playerInGame)
			if theirPlot and theirPlot.PlotModel == plot then
				return cfg.AccountName
			end
		end
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

local function AdjustCameraBehindPlayer(pet)
	local cam = Workspace.CurrentCamera
	if not cam or not pet then return end

	local petPos = pet.WorldPivot and pet.WorldPivot.Position or pet.Position
	local direction = (petPos - hrp.Position).Unit
	local behindOffset = -direction * 5 + Vector3.new(0, 3, 0)
	local camPos = hrp.Position + behindOffset

	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0, 2, 0))

	task.delay(4, function()
		cam.CameraType = Enum.CameraType.Custom
	end)
end

-- 📏 ĐO TỐC ĐỘ DI CHUYỂN
local function MeasureWalkSpeed()
	local pos1 = hrp.Position
	task.wait(0.5)
	local pos2 = hrp.Position
	local distance = (pos2 - pos1).Magnitude
	return distance / 0.5 -- speed per second
end

local function HoldKeyEReal(duration)
	local start = tick()
	while tick() - start < duration do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- 🔍 KIỂM TRA XEM PET CÓ BỊ CLAIM BỞI ACC KHÁC KHÔNG
local function IsPetBeingClaimed(petId)
	return ClaimedPets[petId] ~= nil
end

local function ClaimPet(petId)
	ClaimedPets[petId] = {
		claimer = player.Name,
		time = tick()
	}
end

local function ReleasePet(petId)
	ClaimedPets[petId] = nil
end

-- 🧹 XÓA CLAIM CŨ (sau 30s)
task.spawn(function()
	while true do
		task.wait(5)
		local now = tick()
		for petId, data in pairs(ClaimedPets) do
			if now - data.time > 30 then
				ClaimedPets[petId] = nil
			end
		end
	end
end)

local function HandlePet(pet, myPlot, plotOwner)
	local petId = pet:GetFullName()
	
	-- 🔒 KIỂM TRA XEM PET ĐÃ BỊ CLAIM CHƯA
	if IsPetBeingClaimed(petId) then
		statusText.Text = "Status : Pet already claimed, skipping..."
		return false
	end
	
	-- CLAIM PET
	ClaimPet(petId)
	
	local targetPos = pet.WorldPivot and pet.WorldPivot.Position
	if not targetPos then 
		ReleasePet(petId)
		return false 
	end

	statusText.Text = "Status : Walking to " .. pet.Name .. " (Plot: " .. (plotOwner or "Unknown") .. ")"
	
	if not WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		ReleasePet(petId)
		return false
	end
	
	AdjustCameraBehindPlayer(pet)
	
	-- ⚠️ TẮT Speed Coil khi cầm pet
	speedCoilActive = false

    -- 📏 ĐO TỐC ĐỘ TRƯỚC KHI HOLD E
    statusText.Text = "Status : Measuring speed before hold..."
    task.wait(0.5)
    local speedBefore = MeasureWalkSpeed()
    print("[📊] Speed before hold:", speedBefore)

    -- HOLD E
    statusText.Text = "Status : Holding E on " .. pet.Name
    HoldKeyEReal(HoldTime)

    -- 📏 ĐO TỐC ĐỘ SAU KHI HOLD E
    task.wait(0.5)
    statusText.Text = "Status : Checking if pet picked up..."
    local speedAfter = MeasureWalkSpeed()
    print("[📊] Speed after hold:", speedAfter)

    -- 🔍 SO SÁNH TỐC ĐỘ GIẢM BAO NHIÊU
    local diff = speedBefore - speedAfter
    if diff < 3 then
        statusText.Text = string.format("Status : ❌ Speed drop too small (%.2f) → Skip pet", diff)
        print(string.format("[⚠️] Không cầm được pet, chênh lệch %.2f quá nhỏ → bỏ qua", diff))
        ReleasePet(petId)
        return false
    end

    -- ✅ ĐÃ CẦM ĐƯỢC PET
    statusText.Text = "Status : ✅ Pet picked up! Testing movement..."
    print("[✅] Đã cầm được pet, kiểm tra lại tốc độ...")

    -- 🚶‍♂️ Di chuyển nhẹ để test lại
    WalkToPosition(hrp.Position + Vector3.new(0, 0, 5))
    task.wait(1)
    local speedCheck = MeasureWalkSpeed()
    print("[📏] Speed recheck:", speedCheck)

    if speedCheck > 3 then
        statusText.Text = "Status : ❌ Seems pet dropped (speed too high)"
        print("[⚠️] Tốc độ quá cao, có thể pet rơi → bỏ qua và tìm pet khác")
        ReleasePet(petId)
        return false
    end

    -- ✅ Giữ thành công → Về nhà
    statusText.Text = "Status : ✅ Confirmed hold, returning home..."
    print("[🏠] Giữ pet thành công, về nhà...")

    local homePos = GetHomeSpawn(myPlot)
    if homePos then
        WalkToPosition(homePos + Vector3.new(0, 2, 0))

        -- ⚙️ Speed Coil logic
        if not speedCoilBought then
            task.wait(1.5)
            local claimPos = GetAnimalPodiumClaim(myPlot)
            if claimPos then
                statusText.Text = "Status : Going to Podium for reward..."
                if WalkToPosition(claimPos + Vector3.new(0, 2, 0)) then
                    statusText.Text = "Status : Buying Speed Coil..."
                    task.wait(0.5)
                    BuySpeedCoil()
                    task.wait(1)
                    statusText.Text = "Status : Equipping Speed Coil..."
                    EquipSpeedCoil()
                end
            end
        else
            task.wait(0.5)
            statusText.Text = "Status : Re-equipping Speed Coil..."
            EquipSpeedCoil()
        end
    end

    ReleasePet(petId)
    return true
end

local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	local availablePets = {}
	
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			local plotOwner = GetPlotOwner(plot)
			
			-- 🚫 BỎ QUA NẾU LÀ PLOT CỦA ACC KHÁC TRONG DANH SÁCH
			local isTeammatePlot = false
			for _, cfg in ipairs(AccHold) do
				if plotOwner == cfg.AccountName then
					isTeammatePlot = true
					break
				end
			end
			
			if not isTeammatePlot then
				for _, pet in ipairs(plot:GetChildren()) do
					if pet.Name == CurrentPet then
						local petId = pet:GetFullName()
						if not IsPetBeingClaimed(petId) then
							table.insert(availablePets, {
								pet = pet,
								plot = myPlot,
								owner = plotOwner
							})
						end
					end
				end
			end
		end
	end
	
	-- 🎲 CHỌN RANDOM PET TỪ DANH SÁCH
	if #availablePets > 0 then
		local randomIndex = math.random(1, #availablePets)
		local chosen = availablePets[randomIndex]
		
		local success = HandlePet(chosen.pet, chosen.plot, chosen.owner)
		
		if not success then
			-- Nếu thất bại, thử pet khác
			statusText.Text = "Status : Retrying with different pet..."
			task.wait(1)
		end
	else
		statusText.Text = "Status : No available pets, waiting..."
	end
end

local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then return true end

	for _, pet in ipairs(myPlot:GetChildren()) do
		for _, cfg in ipairs(AccHold) do
			if pet.Name == cfg.Pet then 
				return false
			end
		end
	end
	return true
end

local function GetPetsInPlot(plot)
	if not plot then return {} end
	local pets = {}
	
	local skipList = {
		"Decorations", "Floor", "Walls", "Roof", "SpawnLocation", "Door",
		"FriendPanel", "Friend", "Panel", "BuildArea", "Lighting", 
		"Camera", "PlotArea", "Gui", "UI", "Screen", "AnimalPodiums"
	}
	
	for _, obj in ipairs(plot:GetChildren()) do
		if not obj:IsA("Model") then
			continue
		end
		
		local shouldSkip = false
		for _, skipWord in ipairs(skipList) do
			if string.find(string.lower(obj.Name), string.lower(skipWord)) then
				shouldSkip = true
				break
			end
		end
		
		if not shouldSkip then
			if obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart then
				table.insert(pets, obj.Name)
			end
		end
	end
	
	return pets
end

---------------------------------------------------------------------
-- 📊 UPDATE UI
---------------------------------------------------------------------
local function UpdateUI()
	statLabels[1].Text = "Username: " .. player.Name
	statLabels[2].Text = "Display: " .. player.DisplayName
	statLabels[3].Text = "Mode: " .. farmMode .. " Mode"
	statLabels[4].Text = "Target Pet: " .. (CurrentPet or "None")
	statLabels[5].Text = "Hold Time: " .. HoldTime .. "s"
	statLabels[6].Text = "Speed Coil: " .. (speedCoilActive and "✅ Active" or "❌ Inactive")
	
	local myPlot = GetMyPlot()
	local pets = GetPetsInPlot(myPlot)
	
	for _, child in ipairs(petScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	if #pets == 0 then
		local noPetLabel = Instance.new("TextLabel")
		noPetLabel.Text = "No pets in plot"
		noPetLabel.Font = Enum.Font.GothamMedium
		noPetLabel.TextSize = 14
		noPetLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		noPetLabel.BackgroundTransparency = 1
		noPetLabel.Size = UDim2.new(1, 0, 0, 20)
		noPetLabel.Parent = petScroll
	else
		for i, petName in ipairs(pets) do
			local petFrame = Instance.new("Frame")
			petFrame.Size = UDim2.new(1, -5, 0, 24)
			petFrame.BackgroundTransparency = 1
			petFrame.Parent = petScroll
			
			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0, 8, 0, 8)
			dot.Position = UDim2.new(0, 0, 0.5, -4)
			dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
			dot.BorderSizePixel = 0
			dot.Parent = petFrame
			
			local dotCorner = Instance.new("UICorner")
			dotCorner.CornerRadius = UDim.new(1, 0)
			dotCorner.Parent = dot
			
			local petLabel = Instance.new("TextLabel")
			petLabel.Text = petName
			petLabel.Font = Enum.Font.GothamMedium
			petLabel.TextSize = 14
			petLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
			petLabel.BackgroundTransparency = 1
			petLabel.Position = UDim2.new(0, 16, 0, 0)
			petLabel.Size = UDim2.new(1, -16, 1, 0)
			petLabel.TextXAlignment = Enum.TextXAlignment.Left
			petLabel.Parent = petFrame
		end
	end
	
	petScroll.CanvasSize = UDim2.new(0, 0, 0, petListLayout.AbsoluteContentSize.Y + 10)
end

---------------------------------------------------------------------
-- 🚀 KHỞI ĐỘNG FARM
---------------------------------------------------------------------
if CurrentPet then
	print("[ACC FARM] 🎯", player.Name, "→ gom pet:", CurrentPet)
	statusText.Text = "Status : Farming " .. CurrentPet
	
	-- Farm loop với random selection
	task.spawn(function()
		while true do
			pcall(function()
				ScanAllPlots()
			end)
			task.wait(CheckInterval)
		end
	end)
else
	print("[ACC CHECK] 👀", player.Name, "không trong danh sách farm, kiểm tra plot riêng.")
	statusText.Text = "Status : Monitoring Plot"
	
	task.spawn(function()
		while true do
			pcall(function()
				if CheckMyPlotEmpty() then
					player:Kick("Hết pet rồi.")
					return
				end
			end)
			task.wait(5)
		end
	end)
end

-- Update UI loop
task.spawn(function()
	while true do
		pcall(UpdateUI)
		task.wait(2)
	end
end)

UpdateUI()
print("✅ Pet Farm UI + Anti-Conflict + Speed Check loaded!")
