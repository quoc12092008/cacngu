-- ⚙️ CẤU HÌNH SERVER
local SERVER_URL = "http://localhost:5000"

-- ===== HTTP SETUP =====
local HttpService = game:GetService("HttpService")
local http = syn and syn.request or http_request or request or fluxus and fluxus.request

if not http then
	warn("==============================================")
	warn("❌ EXECUTOR KHÔNG HỖ TRỢ HTTP REQUESTS!")
	warn("==============================================")
	error("Executor không hỗ trợ HTTP!")
	return
end

print("✅ HTTP function detected!")

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

local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- Cấu hình
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

-- ===== HTTP với Retry =====
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
			end
		end
	end
	
	return nil
end

-- ===== NHẬN DIỆN ROLE =====
local CurrentPet = nil
local farmMode = "Checker"

for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		farmMode = "Farmer"
		break
	end
end

print("========================================")
if farmMode == "Farmer" then
	print("🎯 [FARMER MODE]:", player.Name, "→", CurrentPet)
else
	print("📦 [CHECKER MODE]:", player.Name)
end
print("========================================")

-- ===== SERVER API =====
local ServerAPI = {}

function ServerAPI.Register(username, pet_target)
	return HttpPost("/register", {username = username, pet_target = pet_target})
end

function ServerAPI.Heartbeat(username)
	return HttpPost("/heartbeat", {username = username})
end

function ServerAPI.SubmitPets(username, pets)
	return HttpPost("/submit_pets", {username = username, pets = pets})
end

function ServerAPI.GetJob(username)
	return HttpPost("/get_job", {username = username})
end

function ServerAPI.CompleteJob(username)
	return HttpPost("/complete_job", {username = username})
end

-- ===== SPEED COIL =====
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
gui.Parent = game.CoreGui

local statusFrame = Instance.new("Frame")
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
statusStroke.Color = farmMode == "Farmer" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 180, 0)
statusStroke.Thickness = 2
statusStroke.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamBold
statusText.TextColor3 = farmMode == "Farmer" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 200, 40)
statusText.TextSize = 17
statusText.Text = "Status : Initializing..."
statusText.Parent = statusFrame

local discordText = Instance.new("TextLabel")
discordText.Text = "Chúi Hub - " .. farmMode
discordText.Position = UDim2.new(0.5, 0, 0.06, 0)
discordText.AnchorPoint = Vector2.new(0.5, 0)
discordText.Size = UDim2.new(0, 200, 0, 20)
discordText.BackgroundTransparency = 1
discordText.Font = Enum.Font.GothamBold
discordText.TextColor3 = Color3.fromRGB(255, 200, 0)
discordText.TextSize = 13
discordText.Parent = gui

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

-- ===== ANTI-COLLISION: Kiểm tra có player khác gần không =====
local function IsPlayerNearby(position, radius)
	radius = radius or 10
	
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			if otherHRP then
				local distance = (otherHRP.Position - position).Magnitude
				if distance < radius then
					return true, otherPlayer.Name
				end
			end
		end
	end
	
	return false
end

-- ===== PATHFINDING với ANTI-COLLISION =====
local function WalkToPosition(targetPos)
	-- Kiểm tra có ai đang ở target không
	local hasPlayer, playerName = IsPlayerNearby(targetPos, 8)
	if hasPlayer then
		warn("[COLLISION] Player", playerName, "đang ở gần target, chờ...")
		statusText.Text = "Status : Waiting for " .. playerName .. "..."
		
		-- Chờ player kia đi xa (tối đa 30s)
		local waitTime = 0
		while waitTime < 30 do
			task.wait(1)
			waitTime = waitTime + 1
			hasPlayer = IsPlayerNearby(targetPos, 8)
			if not hasPlayer then
				break
			end
		end
		
		-- Nếu vẫn còn người, thêm offset random
		if hasPlayer then
			print("[COLLISION] Thêm offset để tránh kẹt")
			local randomOffset = Vector3.new(
				math.random(-5, 5),
				0,
				math.random(-5, 5)
			)
			targetPos = targetPos + randomOffset
		end
	end
	
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

-- ===== CAMERA PHÍA SAU =====
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

local function HoldKeyEReal(duration)
	local start = tick()
	while tick() - start < duration do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- ===== FARMER LOGIC TỪNG BƯỚC =====
local jobsCompleted = 0

local function HandlePet(pet, myPlot)
	local targetPos = pet.WorldPivot and pet.WorldPivot.Position
	if not targetPos then return end

	statusText.Text = "Status : Walking to " .. pet.Name
	
	-- Đi đến pet với anti-collision
	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		-- Camera phía sau
		AdjustCameraBehindPlayer(pet)
		
		-- Tắt Speed Coil khi cầm
		speedCoilActive = false
		
		statusText.Text = "Status : Holding E on " .. pet.Name
		HoldKeyEReal(HoldTime)

		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			statusText.Text = "Status : Returning home..."
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
			
			-- Mua Speed Coil lần đầu
			if not speedCoilBought then
				task.wait(1.5)
				
				local claimPos = GetAnimalPodiumClaim(myPlot)
				if claimPos then
					statusText.Text = "Status : Going to Podium..."
					if WalkToPosition(claimPos + Vector3.new(0, 2, 0)) then
						statusText.Text = "Status : Buying Speed Coil..."
						task.wait(0.5)
						BuySpeedCoil()
						task.wait(1)
						EquipSpeedCoil()
					end
				end
			else
				-- Re-equip Speed Coil
				task.wait(0.5)
				statusText.Text = "Status : Re-equipping Speed Coil..."
				EquipSpeedCoil()
			end
		end
		
		jobsCompleted = jobsCompleted + 1
		return true
	end
	
	return false
end

-- ===== SCAN TẤT CẢ PLOTS =====
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			for _, pet in ipairs(plot:GetChildren()) do
				if pet.Name == CurrentPet then
					HandlePet(pet, myPlot)
				end
			end
		end
	end
end

-- ===== FARMER LOOP (Logic gốc) =====
local function FarmerLoop()
	while true do
		pcall(function()
			statusText.Text = "Status : Scanning plots..."
			ScanAllPlots()
			statusText.Text = "Status : Farming " .. CurrentPet .. " (" .. jobsCompleted .. " done)"
		end)
		
		task.wait(CheckInterval)
	end
end

-- ===== CHECKER LOOP =====
local petsSubmitted = 0

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

local function CheckerLoop()
	while true do
		pcall(function()
			local pets = GetPetsInMyPlot()
			
			if #pets == 0 or CheckMyPlotEmpty() then
				print("[CHECKER] ⚠️ Hết pet! Kick...")
				statusText.Text = "Status : No pets left"
				task.wait(2)
				player:Kick("Hết pet rồi.")
				return
			end
			
			statusText.Text = "Status : Submitting " .. #pets .. " pets..."
			local response = ServerAPI.SubmitPets(player.Name, pets)
			
			if response and response.success then
				petsSubmitted = petsSubmitted + #pets
				print("[CHECKER] ✅ Submitted", #pets, "pets")
			end
			
			statusText.Text = "Status : Monitoring (" .. #pets .. " pets)"
		end)
		
		task.wait(5)
	end
end

-- ===== HEARTBEAT =====
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
	local response = ServerAPI.Register(player.Name, CurrentPet)
	if response and response.success then
		print("[✅] Registered as FARMER")
		statusText.Text = "Status : Farming " .. CurrentPet
		task.spawn(FarmerLoop)
		task.spawn(HeartbeatLoop)
	else
		warn("[❌] Server connection failed!")
		statusText.Text = "Status : Connection failed"
	end
else
	print("[✅] Running as CHECKER")
	statusText.Text = "Status : Monitoring plot"
	task.spawn(CheckerLoop)
	task.spawn(HeartbeatLoop)
end

print("✅ Script loaded!")
