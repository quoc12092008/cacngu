-- ⚙️ CẤU HÌNH SERVER
local SERVER_URL = "http://localhost:5000"  -- Thay IP nếu chạy máy khác

-- ===== HTTP SETUP =====
local HttpService = game:GetService("HttpService")

-- Tìm HTTP request function (hỗ trợ nhiều executor)
local http = syn and syn.request or http_request or request or fluxus and fluxus.request

-- Kiểm tra HTTP có khả dụng không
if not http then
	warn("==============================================")
	warn("❌ EXECUTOR KHÔNG HỖ TRỢ HTTP REQUESTS!")
	warn("❌ Script cần executor hỗ trợ HTTP!")
	warn("==============================================")
	warn("✅ Các executor hỗ trợ:")
	warn("  - Synapse X (syn.request)")
	warn("  - Script-Ware (http_request)")
	warn("  - Electron (request)")
	warn("  - Fluxus (fluxus.request)")
	warn("  - Krnl (request)")
	warn("==============================================")
	
	-- Tạo UI báo lỗi
	local gui = Instance.new("ScreenGui")
	gui.Name = "HttpError"
	gui.Parent = game.CoreGui
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 450, 0, 220)
	frame.Position = UDim2.new(0.5, -225, 0.5, -110)
	frame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	frame.Parent = gui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -20, 1, -20)
	text.Position = UDim2.new(0, 10, 0, 10)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextSize = 16
	text.TextWrapped = true
	text.Text = "❌ EXECUTOR KHÔNG HỖ TRỢ HTTP!\n\nScript cần executor hỗ trợ HTTP requests.\n\nVui lòng dùng:\n• Synapse X\n• Script-Ware\n• Electron\n• Fluxus\n• Krnl"
	text.Parent = frame
	
	error("Executor không hỗ trợ HTTP!")
	return
end

print("✅ HTTP function detected!")

-- Xóa UI cũ
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
local INITIAL_WAIT_TIME = 20  -- Thời gian chờ khi mới vào game
local MAX_JOB_RETRIES = 3  -- Số lần thử lại tối đa cho mỗi job

-- ===== HTTP REQUEST HELPER (Với retry mechanism) =====
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

-- ===== XÁC ĐỊNH ROLE: FARMER hay CHECKER =====
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
	print("🎯 [FARMER MODE] Account:", player.Name)
	print("🎯 Target Pet:", CurrentPet)
else
	print("📦 [CHECKER MODE] Account:", player.Name)
	print("📦 Will submit pets to server for farmers")
	print("⏰ Initial wait time:", INITIAL_WAIT_TIME, "seconds")
end
print("========================================")

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

function ServerAPI.CompleteJob(username, success)
	return HttpPost("/complete_job", {
		username = username,
		success = success
	})
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

-- ===== CAMERA ADJUSTMENT - IMPROVED ZOOM =====
local function ZoomCameraToPet(petPosition)
	local cam = Workspace.CurrentCamera
	if not cam or not hrp then return end
	
	-- Tính hướng từ player đến pet
	local direction = (petPosition - hrp.Position).Unit
	
	-- ZOOM GẦN: Đặt camera gần pet hơn, phía sau player
	local cameraDistance = 3
	local cameraHeight = 1.5
	
	local behindOffset = -direction * cameraDistance + Vector3.new(0, cameraHeight, 0)
	local camPos = hrp.Position + behindOffset
	
	-- Set camera scriptable và zoom vào pet
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = CFrame.new(camPos, petPosition)
	cam.FieldOfView = 50
	
	print("[📷] Camera zoomed to pet (Distance: " .. cameraDistance .. ")")
	
	-- Tự động trả về Custom sau 5 giây
	task.delay(5, function()
		if cam then
			cam.CameraType = Enum.CameraType.Custom
			cam.FieldOfView = 70
			print("[📷] Camera returned to normal")
		end
	end)
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
	if not myPlot then 
		warn("[CHECKER] ⚠️ Không tìm thấy plot!")
		return {} 
	end
	
	local pets = {}
	local skipList = {
		"Decorations", "Floor", "Walls", "Roof", "SpawnLocation", "Door",
		"FriendPanel", "Friend", "Panel", "BuildArea", "Lighting", 
		"Camera", "PlotArea", "Gui", "UI", "Screen", "AnimalPodiums"
	}
	
	for _, obj in ipairs(myPlot:GetChildren()) do
		-- 🆕 Kiểm tra obj còn tồn tại và có Parent
		if not obj or not obj.Parent then continue end
		if not obj:IsA("Model") then continue end
		
		local shouldSkip = false
		for _, skipWord in ipairs(skipList) do
			if string.find(string.lower(obj.Name), string.lower(skipWord)) then
				shouldSkip = true
				break
			end
		end
		
		if not shouldSkip then
			-- 🆕 Kiểm tra kỹ hơn pet còn tồn tại
			local hasRootPart = obj:FindFirstChild("HumanoidRootPart")
			local hasPrimary = obj.PrimaryPart ~= nil
			
			if hasRootPart or hasPrimary then
				-- 🆕 Double check obj vẫn còn trong game
				if obj.Parent and obj.Parent == myPlot then
					local pos = obj:GetPivot().Position
					table.insert(pets, {
						name = obj.Name,
						position = {x = pos.X, y = pos.Y, z = pos.Z}
					})
					print("[CHECKER] 🐾 Found pet:", obj.Name, "at", pos)
				end
			end
		end
	end
	
	print("[CHECKER] 📊 Total pets found:", #pets)
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

-- ===== STEALS CHECKER (CHO FARMER) =====
local function GetStealsValue()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local steals = leaderstats:FindFirstChild("Steals")
		if steals then
			return steals.Value
		end
	end
	return 0
end

local function CheckAndKickIfFull()
	if farmMode ~= "Farmer" then return false end
	
	local steals = GetStealsValue()
	
	if steals >= 10 then
		print("[FARMER] ⚠️⚠️⚠️ STEALS = " .. steals .. " - ĐÃ ĐẦY PET! KICK...")
		statusText.Text = "Status : INVENTORY FULL (Steals: 10) - KICKING..."
		task.wait(3)
		player:Kick("✅ Đã đầy 10 pet rồi! (Steals: " .. steals .. ")\n\nVui lòng lấy pet ra và chạy lại script.\n\nFarmer account: " .. player.Name)
		return true
	end
	
	return false
end

-- ===== FARMER MODE =====
local jobsCompleted = 0
local jobsFailed = 0
local currentJob = nil

local function DoFarmerJob(job)
	-- KIỂM TRA STEALS TRƯỚC KHI LÀM JOB
	if CheckAndKickIfFull() then
		return false
	end
	
	currentJob = job
	local targetPos = Vector3.new(job.position.x, job.position.y, job.position.z)
	
	statusText.Text = "Status : Walking to " .. job.pet_name .. " from " .. job.owner
	print("[FARMER] 🚶 Đang đi đến pet:", job.pet_name)
	
	-- Bước 1: Đi đến pet
	if not WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		warn("[FARMER] ❌ Không thể di chuyển tới pet")
		statusText.Text = "Status : Failed to reach pet - Retrying..."
		return false
	end
	
	speedCoilActive = false
	
	-- Bước 2: Đến nơi, chờ và zoom camera
	statusText.Text = "Status : Arrived at " .. job.pet_name .. ", preparing..."
	print("[FARMER] ✅ Đã đến pet, chuẩn bị hold E")
	task.wait(2)
	
	statusText.Text = "Status : Adjusting camera zoom..."
	ZoomCameraToPet(targetPos)
	task.wait(1.5)
	
	-- Bước 3: Hold E
	statusText.Text = "Status : Holding E on " .. job.pet_name
	print("[FARMER] 🎯 Đang hold E...")
	HoldKeyEReal(HoldTime)
	print("[FARMER] ✅ Đã hold E xong")
	
	-- Bước 4: Về nhà
	local myPlot = GetMyPlot()
	local homePos = GetHomeSpawn(myPlot)
	if homePos then
		statusText.Text = "Status : Returning home..."
		print("[FARMER] 🏠 Đang quay về nhà")
		
		if not WalkToPosition(homePos + Vector3.new(0, 2, 0)) then
			warn("[FARMER] ⚠️ Không thể về nhà nhưng job đã hoàn thành")
		end
		
		-- Mua/Equip Speed Coil nếu cần
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
	
	-- Bước 5: Báo server hoàn thành THÀNH CÔNG
	print("[FARMER] 📤 Báo server job hoàn thành")
	ServerAPI.CompleteJob(player.Name, true)
	jobsCompleted = jobsCompleted + 1
	currentJob = nil
	
	-- KIỂM TRA STEALS SAU KHI HOÀN THÀNH JOB
	task.wait(1)
	if CheckAndKickIfFull() then
		return true
	end
	
	statusText.Text = "Status : Job completed! (" .. jobsCompleted .. " total)"
	UpdateFarmerInfo()
	
	return true
end

function UpdateFarmerInfo()
	local myPets = GetPetsInMyPlot()
	local steals = GetStealsValue()
	
	infoText.Text = string.format(
		"👤 Username: %s\n" ..
		"🎯 Target Pet: %s\n" ..
		"📊 Steals: %d/10\n" ..
		"✅ Jobs Completed: %d\n" ..
		"❌ Jobs Failed: %d\n" ..
		"🏠 Pets in My Plot: %d\n" ..
		"⚡ Speed Coil: %s\n" ..
		"⏱️ Hold Time: %.1fs",
		player.Name,
		CurrentPet,
		steals,
		jobsCompleted,
		jobsFailed,
		#myPets,
		speedCoilActive and "Active" or "Inactive",
		HoldTime
	)
end

local function FarmerLoop()
	-- KIỂM TRA STEALS NGAY KHI BẮT ĐẦU
	if CheckAndKickIfFull() then
		return
	end
	
	while true do
		pcall(function()
			-- Kiểm tra Steals định kỳ
			if CheckAndKickIfFull() then
				return
			end
			
			-- Chỉ xin job mới khi KHÔNG có job đang làm
			if currentJob then
				warn("[FARMER] ⚠️ Đang có job chưa hoàn thành, bỏ qua")
				return
			end
			
			statusText.Text = "Status : Requesting job from server..."
			local response = ServerAPI.GetJob(player.Name)
			
			if response and response.job then
				local job = response.job
				print("[FARMER] 📩 Nhận job mới:", job.pet_name, "từ", job.owner)
				
				-- Thử làm job với retry mechanism
				local retryCount = 0
				local success = false
				
				while retryCount < MAX_JOB_RETRIES and not success do
					retryCount = retryCount + 1
					
					if retryCount > 1 then
						print("[FARMER] 🔄 Retry lần", retryCount .. "/" .. MAX_JOB_RETRIES)
						statusText.Text = string.format("Status : Retrying job (%d/%d)", retryCount, MAX_JOB_RETRIES)
						task.wait(3)
					end
					
					success = DoFarmerJob(job)
				end
				
				-- Nếu thất bại sau tất cả retry
				if not success then
					warn("[FARMER] ❌ Job FAILED sau", MAX_JOB_RETRIES, "lần thử")
					ServerAPI.CompleteJob(player.Name, false)
					jobsFailed = jobsFailed + 1
					currentJob = nil
					statusText.Text = "Status : Job failed after retries"
					UpdateFarmerInfo()
				end
			else
				statusText.Text = "Status : No jobs available, waiting..."
			end
		end)
		
		task.wait(CheckInterval)
	end
end

-- ===== STEALS MONITOR (CHO FARMER) =====
local function MonitorStealsLoop()
	if farmMode ~= "Farmer" then return end
	
	while true do
		pcall(function()
			local steals = GetStealsValue()
			
			-- Cảnh báo khi gần đầy
			if steals >= 9 then
				warn("[FARMER] ⚠️ Steals = " .. steals .. "/10 - GẦN ĐẦY!")
				statusText.TextColor3 = Color3.fromRGB(255, 150, 0)
			elseif steals >= 10 then
				CheckAndKickIfFull()
			end
		end)
		
		task.wait(5)
	end
end

-- ===== CHECKER MODE - WITH INITIAL WAIT =====
local petsSubmitted = 0
local hasWaitedInitial = false
local lastPetCount = 0  -- 🆕 Track số pet lần trước

function UpdateCheckerInfo()
	local myPets = GetPetsInMyPlot()
	
	-- 🆕 So sánh với lần trước để phát hiện thay đổi
	if lastPetCount ~= #myPets then
		print("[CHECKER] 🔔 Pet count changed:", lastPetCount, "→", #myPets)
		lastPetCount = #myPets
	end
	
	-- Cảnh báo nếu gần hết pet
	if #myPets <= 2 and #myPets > 0 then
		warn("[CHECKER] ⚠️ CHỈ CÒN", #myPets, "PET!")
		statusText.TextColor3 = Color3.fromRGB(255, 150, 0)  -- Màu cam cảnh báo
	elseif #myPets == 0 then
		statusText.TextColor3 = Color3.fromRGB(255, 50, 50)  -- Màu đỏ
	else
		statusText.TextColor3 = Color3.fromRGB(255, 200, 40)  -- Màu vàng bình thường
	end
	
	local petList = ""
	for i, pet in ipairs(myPets) do
		petList = petList .. string.format("  • %s (%.1f, %.1f, %.1f)\n", 
			pet.name, pet.position.x, pet.position.y, pet.position.z)
		if i >= 10 then
			petList = petList .. string.format("  ... and %d more\n", #myPets - 10)
			break
		end
	end
	
	if #myPets == 0 then
		petList = "  ❌ NO PETS IN PLOT!\n"
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
	-- CHỜ 20 GIÂY LẦN ĐẦU TIÊN
	if not hasWaitedInitial then
		print("[CHECKER] ⏰ Waiting " .. INITIAL_WAIT_TIME .. "s for plot to stabilize...")
		statusText.Text = "Status : Waiting for plot door to close..."
		
		for i = INITIAL_WAIT_TIME, 1, -1 do
			statusText.Text = string.format("Status : Waiting... (%ds remaining)", i)
			task.wait(1)
		end
		
		hasWaitedInitial = true
		print("[CHECKER] ✅ Initial wait completed, starting normal operation")
		statusText.Text = "Status : Ready to submit pets"
	end
	
	-- VÒNG LẶP BÌNH THƯỜNG
	while true do
		local shouldContinue = true
		
		pcall(function()
			-- 🆕 LUÔN SCAN LẠI PLOT MỚI NHẤT
			local pets = GetPetsInMyPlot()
			
			print("[CHECKER] 🔍 Scanning plot... Found:", #pets, "pets")
			
			-- KIỂM TRA HẾT PET → KICK NGAY
			if #pets == 0 then
				print("[CHECKER] ⚠️⚠️⚠️ HẾT PET! KICK NGAY...")
				statusText.Text = "Status : NO PETS LEFT - KICKING IN 3s..."
				UpdateCheckerInfo()  -- Update UI để hiển thị 0 pets
				task.wait(3)
				player:Kick("❌ Hết pet rồi! Script đã dừng.\n\nĐã lấy hết pet từ plot.\n\nChecker account: " .. player.Name)
				shouldContinue = false
				return
			end
			
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
		
		if not shouldContinue then
			break
		end
		
		task.wait(2)  -- 🆕 Giảm từ 5s xuống 2s để check nhanh hơn
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
	local response = ServerAPI.Register(player.Name, CurrentPet)
	if response and response.success then
		print("[✅] Registered as FARMER:", player.Name, "→", CurrentPet)
		
		-- KIỂM TRA STEALS NGAY KHI KHỞI ĐỘNG
		local initialSteals = GetStealsValue()
		print("[📊] Initial Steals:", initialSteals .. "/10")
		
		if initialSteals >= 10 then
			statusText.Text = "Status : Already full! (Steals: 10)"
			task.wait(2)
			player:Kick("⚠️ Account đã đầy 10 pet rồi!\n\nVui lòng lấy pet ra trước khi chạy script.\n\nFarmer: " .. player.Name)
			return
		end
		
		statusText.Text = "Status : Registered as Farmer (Steals: " .. initialSteals .. "/10)"
		
		UpdateFarmerInfo()
		task.spawn(FarmerLoop)
		task.spawn(MonitorStealsLoop)
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
	print("[✅] Running as CHECKER:", player.Name)
	statusText.Text = "Status : Initializing as Checker"
	
	UpdateCheckerInfo()
	task.spawn(CheckerLoop)
	task.spawn(function()
		while true do
			pcall(UpdateCheckerInfo)
			task.wait(2)  -- 🆕 Giảm từ 3s xuống 2s
		end
	end)
end

task.spawn(HeartbeatLoop)
print("✅ Script loaded with Job Tracking, Retry, Auto-Kick & Steals Monitor!")
