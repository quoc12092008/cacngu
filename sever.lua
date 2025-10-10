-- ⚙️ CẤU HÌNH SERVER
local SERVER_URL = "http://localhost:5000"  -- Thay IP nếu chạy máy khác

-- Xóa UI cũ
if game.CoreGui:FindFirstChild("BananaStatsChecker") then
	game.CoreGui.BananaStatsChecker:Destroy()
end

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
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

-- Cấu hình
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

-- ===== XÁC ĐỊNH ROLE: FARMER hay CHECKER =====
local CurrentPet = nil
local farmMode = "Checker"  -- Mặc định là Checker

-- Kiểm tra acc hiện tại có trong danh sách AccHold không
for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		farmMode = "Farmer"  -- Acc trong danh sách = FARMER
		break
	end
end

-- Nếu KHÔNG có trong danh sách → CHECKER
print("========================================")
if farmMode == "Farmer" then
	print("🎯 [FARMER MODE] Account:", player.Name)
	print("🎯 Target Pet:", CurrentPet)
else
	print("📦 [CHECKER MODE] Account:", player.Name)
	print("📦 Will submit pets to server for farmers")
end
print("========================================")

-- ===== HTTP REQUEST HELPER =====
local function HttpPost(endpoint, data)
	local success, result = pcall(function()
		return HttpService:PostAsync(
			SERVER_URL .. endpoint,
			HttpService:JSONEncode(data),
			Enum.HttpContentType.ApplicationJson
		)
	end)
	
	if success then
		return HttpService:JSONDecode(result)
	else
		warn("[HTTP ERROR]", endpoint, result)
		return nil
	end
end

-- ===== SERVER API =====
local ServerAPI = {}

function ServerAPI.Register(username, pet_target)
	return HttpPost("/register", {
		username = username,
		pet_target = pet_target
	})
end

function ServerAPI.Heartbeat(username)
	return HttpPost("/heartbeat", {username = username})
end

function ServerAPI.SubmitPets(username, pets)
	return HttpPost("/submit_pets", {
		username = username,
		pets = pets
	})
end

function ServerAPI.GetJob(username)
	return HttpPost("/get_job", {username = username})
end

function ServerAPI.CompleteJob(username)
	return HttpPost("/complete_job", {username = username})
end

function ServerAPI.RemovePet(username, pet_name)
	return HttpPost("/remove_pet", {
		username = username,
		pet_name = pet_name
	})
end

-- ===== SPEED COIL (CHỈ CHO FARMER) =====
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

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "BananaStatsChecker"
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
statusStroke.Color = farmMode == "Farmer" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 180, 0)
statusStroke.Thickness = 2
statusStroke.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamBold
statusText.TextColor3 = farmMode == "Farmer" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 200, 40)
statusText.TextSize = 16
statusText.Text = "Status : Connecting to server..."
statusText.Parent = statusFrame

local discordText = Instance.new("TextLabel")
discordText.Text = "Chúi Hub - " .. farmMode .. " Mode"
discordText.Position = UDim2.new(0.5, 0, 0.06, 0)
discordText.AnchorPoint = Vector2.new(0.5, 0)
discordText.Size = UDim2.new(0, 250, 0, 20)
discordText.BackgroundTransparency = 1
discordText.Font = Enum.Font.GothamBold
discordText.TextColor3 = farmMode == "Farmer" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 200, 0)
discordText.TextSize = 13
discordText.Parent = gui

-- Main frame (để hiển thị thông tin)
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
mainStroke.Color = farmMode == "Farmer" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 180, 0)
mainStroke.Thickness = 2.5
mainStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = farmMode == "Farmer" and "🎯 FARMER MODE" or "📦 CHECKER MODE"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = farmMode == "Farmer" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 200, 0)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.92, 0, 0, 2)
divider.Position = UDim2.new(0.04, 0, 0, 50)
divider.BackgroundColor3 = farmMode == "Farmer" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 180, 0)
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

-- ===== FARMER MODE =====
local jobsCompleted = 0

local function DoFarmerJob(job)
	local targetPos = Vector3.new(job.position.x, job.position.y, job.position.z)
	
	statusText.Text = "Status : Walking to " .. job.pet_name .. " from " .. job.owner
	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		speedCoilActive = false
		
		statusText.Text = "Status : Holding E on " .. job.pet_name
		HoldKeyEReal(HoldTime)
		
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
		
		-- Báo server hoàn thành
		ServerAPI.CompleteJob(player.Name)
		jobsCompleted = jobsCompleted + 1
		
		statusText.Text = "Status : Job completed! (" .. jobsCompleted .. " total)"
		UpdateFarmerInfo()
		
		return true
	else
		warn("[FARMER] Không thể di chuyển tới pet")
		return false
	end
end

local function UpdateFarmerInfo()
	local myPets = GetPetsInMyPlot()
	infoText.Text = string.format(
		"👤 Username: %s\n" ..
		"🎯 Target Pet: %s\n" ..
		"✅ Jobs Completed: %d\n" ..
		"🏠 Pets in My Plot: %d\n" ..
		"⚡ Speed Coil: %s\n" ..
		"⏱️ Hold Time: %.1fs",
		player.Name,
		CurrentPet,
		jobsCompleted,
		#myPets,
		speedCoilActive and "Active" or "Inactive",
		HoldTime
	)
end

local function FarmerLoop()
	while true do
		pcall(function()
			statusText.Text = "Status : Requesting job from server..."
			local response = ServerAPI.GetJob(player.Name)
			
			if response and response.job then
				print("[FARMER] Nhận job:", response.job.pet_name, "từ", response.job.owner)
				DoFarmerJob(response.job)
			else
				statusText.Text = "Status : No jobs available, waiting..."
			end
		end)
		
		task.wait(CheckInterval)
	end
end

-- ===== CHECKER MODE =====
local petsSubmitted = 0

local function UpdateCheckerInfo()
	local myPets = GetPetsInMyPlot()
	
	local petList = ""
	for i, pet in ipairs(myPets) do
		petList = petList .. string.format("  • %s\n", pet.name)
		if i >= 10 then
			petList = petList .. string.format("  ... and %d more\n", #myPets - 10)
			break
		end
	end
	
	if #myPets == 0 then
		petList = "  (No pets in plot)\n"
	end
	
	infoText.Text = string.format(
		"👤 Username: %s\n" ..
		"📦 Role: Submit pets for farmers\n" ..
		"🏠 Pets in Plot: %d\n" ..
		"📤 Total Submitted: %d\n\n" ..
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
				print("[CHECKER] ⚠️ Hết pet! Kick...")
				statusText.Text = "Status : No pets left - Kicking..."
				task.wait(2)
				player:Kick("Hết pet rồi. Script stopped.")
				return
			end
			
			-- Submit lên server
			statusText.Text = "Status : Submitting " .. #pets .. " pets to server..."
			local response = ServerAPI.SubmitPets(player.Name, pets)
			
			if response and response.success then
				petsSubmitted = petsSubmitted + #pets
				statusText.Text = "Status : Monitoring plot (" .. #pets .. " pets)"
				print("[CHECKER] ✅ Submitted", #pets, "pets to server")
			else
				statusText.Text = "Status : Failed to submit pets"
				warn("[CHECKER] ❌ Failed to submit pets")
			end
			
			UpdateCheckerInfo()
		end)
		
		task.wait(5)
	end
end

-- ===== HEARTBEAT LOOP =====
local function HeartbeatLoop()
	while true do
		pcall(function()
			ServerAPI.Heartbeat(player.Name)
		end)
		task.wait(10)
	end
end

-- ===== KHỞI ĐỘNG =====
print("🚀 Connecting to server:", SERVER_URL)

if farmMode == "Farmer" then
	-- Đăng ký với server như FARMER
	local response = ServerAPI.Register(player.Name, CurrentPet)
	if response and response.success then
		print("[✅] Registered as FARMER:", player.Name, "→", CurrentPet)
		statusText.Text = "Status : Registered as Farmer"
		
		UpdateFarmerInfo()
		
		-- Start farmer loop
		task.spawn(FarmerLoop)
		
		-- Update info định kỳ
		task.spawn(function()
			while true do
				pcall(UpdateFarmerInfo)
				task.wait(3)
			end
		end)
	else
		warn("[❌] Không thể đăng ký với server!")
		statusText.Text = "Status : Server connection failed"
	end
else
	-- Chạy như CHECKER
	print("[✅] Running as CHECKER:", player.Name)
	statusText.Text = "Status : Running as Checker"
	
	UpdateCheckerInfo()
	
	-- Start checker loop
	task.spawn(CheckerLoop)
	
	-- Update info định kỳ
	task.spawn(function()
		while true do
			pcall(UpdateCheckerInfo)
			task.wait(3)
		end
	end)
end

-- Start heartbeat cho cả 2 mode
task.spawn(HeartbeatLoop)

print("✅ Script loaded with Server Mode!")
