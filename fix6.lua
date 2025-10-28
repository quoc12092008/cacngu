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
local CheckInterval = getgenv().CheckInterval or 10

print("[📝] Farm Accounts Config:")
for i, cfg in ipairs(AccHold) do
	print("  " .. i .. ". " .. cfg.AccountName .. " (Pet: " .. cfg.Pet .. ")")
end

-- Xác định acc hiện tại
local CurrentPet = nil
local farmMode = "Checker"
local IsChecker = true

for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		farmMode = "Farmer"
		IsChecker = false
		break
	end
end

print("[INFO] Account:", player.Name, "| Mode:", farmMode, "| IsChecker:", IsChecker, "| CurrentPet:", CurrentPet)

-- ⚙️ Speed Coil System
local speedCoilActive = false
local speedCoilBought = false
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net", 10)
local remotePath = "RF/CoinsShopService/RequestBuy"
local remoteFunction = Net and Net:FindFirstChild(remotePath, true)

local function BuySpeedCoil()
	if speedCoilBought or not remoteFunction then return end
	
	local args = {
		[1] = "Speed Coil"
	}
	
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
-- 🔧 HELPER FUNCTIONS
---------------------------------------------------------------------

-- Kiểm tra xem acc có phải farm acc ko (tìm trong AccHold)
local function IsFarmAccount(accName)
	for _, cfg in ipairs(AccHold) do
		if cfg.AccountName == accName then
			return true
		end
	end
	return false
end

-- ✅ Auto-detect: Acc nào KHÔNG trong AccHold → Nó là CHECKER
local function IsCheckerAccount(accName)
	return not IsFarmAccount(accName)
end

-- Lấy owner của plot (từ tên plot hoặc detect)
local function GetPlotOwner(plot)
	if not plot then return nil end
	local plotName = plot.Name
	
	-- ✅ Kiểm tra farm account trước
	for _, cfg in ipairs(AccHold) do
		if string.find(plotName, cfg.AccountName) then
			return cfg.AccountName
		end
	end
	
	-- Nếu ko tìm được trong AccHold → Nó là CHECKER plot
	return "Checker"
end

-- Kiểm tra pet có bị lock ko (bị acc khác claim)
local function IsPetLocked(pet)
	local claimedBy = pet:GetAttribute("Claiming")
	if claimedBy ~= nil and claimedBy ~= "" then
		return true, claimedBy
	end
	return false, nil
end

-- Lock pet
local function LockPet(pet)
	pet:SetAttribute("Claiming", player.Name)
	print("[🔒] Locked pet:", pet.Name, "by", player.Name)
end

-- Unlock pet
local function UnlockPet(pet)
	pet:SetAttribute("Claiming", nil)
	print("[🔓] Unlocked pet:", pet.Name)
end

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

local function HoldKeyEReal(duration)
	local start = tick()
	while tick() - start < duration do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function HandlePet(pet, myPlot)
	-- ✅ BƯỚC 1: Kiểm tra pet có bị lock không
	local isLocked, lockedBy = IsPetLocked(pet)
	if isLocked then
		print("⚠️ Pet " .. pet.Name .. " đang bị " .. lockedBy .. " claim → bỏ qua")
		return
	end
	
	-- ✅ BƯỚC 2: Lock pet để acc khác biết đang bị mình lấy
	LockPet(pet)
	
	local targetPos = pet.WorldPivot and pet.WorldPivot.Position
	if not targetPos then
		UnlockPet(pet)
		return
	end

	print("Walking to " .. pet.Name)
	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		AdjustCameraBehindPlayer(pet)
		
		speedCoilActive = false
		
		print("Holding E on " .. pet.Name)
		HoldKeyEReal(HoldTime)

		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			print("Returning home...")
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
			
			if not speedCoilBought then
				task.wait(1.5)
				
				local claimPos = GetAnimalPodiumClaim(myPlot)
				if claimPos then
					print("Going to Podium for reward...")
					if WalkToPosition(claimPos + Vector3.new(0, 2, 0)) then
						print("Buying Speed Coil...")
						task.wait(0.5)
						BuySpeedCoil()
						task.wait(1)
						
						print("Equipping Speed Coil...")
						EquipSpeedCoil()
					end
				end
			else
				task.wait(0.5)
				print("Re-equipping Speed Coil...")
				EquipSpeedCoil()
			end
		end
	end
	
	-- ✅ BƯỚC 3: Unlock pet sau khi xong
	UnlockPet(pet)
	print("Farming " .. CurrentPet)
end

local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			local plotOwner = GetPlotOwner(plot)
			
			-- ✅ CHỈ lấy pet từ CHECKER plot hoặc plot của chính mình
			-- KHÔNG được lấy pet từ plot của acc farm khác
			if plotOwner ~= "Checker" and plotOwner ~= player.Name then
				print("⛔ Plot " .. plot.Name .. " (" .. plotOwner .. ") → thuộc acc farm khác, BỎ QUA hoàn toàn")
				continue
			end
			
			-- Nếu plot này là CHECKER hoặc MY PLOT → Tìm pet chưa bị lock
			local petCount = 0
			for _, pet in ipairs(plot:GetChildren()) do
				if pet.Name == CurrentPet then
					-- ✅ Kiểm tra pet có bị lock không
					local isLocked, lockedBy = IsPetLocked(pet)
					if not isLocked then
						petCount = petCount + 1
						
						-- ✅ Logic chia công việc:
						-- Nếu là farm acc thứ 1 → lấy pet thứ 1
						-- Nếu là farm acc thứ 2 → lấy pet thứ 2
						-- Nếu là farm acc thứ 3 → lấy pet thứ 3, etc...
						
						local farmAccIndex = 0
						for idx, cfg in ipairs(AccHold) do
							if cfg.AccountName == player.Name then
								farmAccIndex = idx
								break
							end
						end
						
						if petCount == farmAccIndex then
							print("[✅] " .. player.Name .. " (Farm#" .. farmAccIndex .. ") → Lấy pet#" .. petCount .. " từ " .. plotOwner)
							HandlePet(pet, myPlot)
							return  -- Lấy xong 1 con → thoát, chờ vòng scan tiếp
						end
					else
						print("[⏭️] Pet '" .. pet.Name .. "' đang bị " .. lockedBy .. " claim → skip")
					end
				end
			end
		end
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

---------------------------------------------------------------------
-- 🚀 KHỞI ĐỘNG FARM
---------------------------------------------------------------------
if not IsChecker then
	print("[ACC FARM] 🎯", player.Name, "→ gom pet:", CurrentPet)
	
	-- Farm loop
	task.spawn(function()
		while true do
			pcall(function()
				ScanAllPlots()
			end)
			task.wait(CheckInterval)
		end
	end)
else
	print("[ACC CHECK] 👀", player.Name, "là CHECKER - chỉ check plot riêng")
	
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

print("✅ Pet Farm Script loaded with Pet Locking System!")
