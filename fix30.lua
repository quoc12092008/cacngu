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
local FarmAccIndex = 0

for idx, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		farmMode = "Farmer"
		IsChecker = false
		FarmAccIndex = idx
		break
	end
end

print("[INFO] Account:", player.Name, "| Mode:", farmMode, "| IsChecker:", IsChecker, "| CurrentPet:", CurrentPet, "| FarmAccIndex:", FarmAccIndex)

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

-- ✅ Lấy owner của plot bằng cách tìm Player liên kết
local function GetPlotOwner(plot)
	if not plot then return nil end
	
	-- Cách 1: Tìm xem plot có attribute "Owner" không
	local ownerAttr = plot:GetAttribute("Owner")
	if ownerAttr then
		return ownerAttr
	end
	
	-- Cách 2: Tìm trong Workspace xem plot nào liên kết với acc nào
	-- Duyệt qua tất cả player
	for _, plr in ipairs(Players:GetPlayers()) do
		-- Kiểm tra xem plot này có phải plot của player này không
		-- (thường có thể check qua tên hoặc OwnerId)
		if plot:FindFirstChild("OwnerId") then
			if plot.OwnerId.Value == plr.UserId then
				return plr.Name
			end
		elseif string.find(plot.Name, plr.Name) then
			return plr.Name
		end
	end
	
	-- Nếu ko tìm được → Nó là CHECKER plot
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

-- Lấy số pet đã được lấy từ plot
local function GetPetsTakenFromPlot(plotOwner)
	local key = "PetsTaken_" .. plotOwner
	local count = ReplicatedStorage:GetAttribute(key)
	return count or 0
end

-- Cập nhật số pet đã lấy
local function IncrementPetsTaken(plotOwner)
	local key = "PetsTaken_" .. plotOwner
	local current = GetPetsTakenFromPlot(plotOwner)
	ReplicatedStorage:SetAttribute(key, current + 1)
	print("[📊] Pet counter updated: " .. key .. " = " .. (current + 1))
end

-- Reset pet counter khi plot hết pet
local function ResetPetCounter(plotOwner)
	local key = "PetsTaken_" .. plotOwner
	ReplicatedStorage:SetAttribute(key, 0)
	print("[🔄] Reset pet counter: " .. key)
end

-- Tính xem acc này nên lấy pet thứ mấy
local function GetMyPetIndex()
	local totalFarmAccs = 0
	for _ in ipairs(AccHold) do
		totalFarmAccs = totalFarmAccs + 1
	end
	
	return FarmAccIndex
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
	print("✅ Farming " .. CurrentPet .. " completed!")
end

local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			local plotOwner = GetPlotOwner(plot)

			-- ✅ FARM acc → CHỈ được lấy pet từ CHECKER (acc KHÔNG thuộc AccHold)
			if not IsChecker then
				if not IsCheckerAccount(plotOwner) then
					print("⛔ " .. player.Name .. " là FARM → KHÔNG ĐƯỢC lấy pet từ acc farm khác:", plotOwner)
					continue
				end
			end

			-- ✅ Nếu đến đây → hoặc là CHECKER, hoặc FARM lấy từ CHECKER → 100% HỢP LỆ
			local totalFarmAccs = #AccHold
			local petsTaken = GetPetsTakenFromPlot(plotOwner)
			local petCount = 0
			local availablePets = {}

			-- Thu thập tất cả pet chưa bị lock
			for _, pet in ipairs(plot:GetChildren()) do
				if pet.Name == CurrentPet then
					local isLocked, lockedBy = IsPetLocked(pet)
					if not isLocked then
						petCount = petCount + 1
						table.insert(availablePets, {index = petCount, pet = pet})
					else
						print("[⏭️] Pet '" .. pet.Name .. "' đang bị " .. lockedBy .. " claim → skip")
					end
				end
			end

			-- ✅ LOGIC CHIA PET
			-- Mỗi acc farm sẽ lấy (petsTaken + FarmAccIndex) % totalFarmAccs
			local myPetIndex = (petsTaken + FarmAccIndex - 1) % totalFarmAccs + 1

			print("[🔍] Plot: " .. plotOwner .. " | PetsTaken: " .. petsTaken .. " | MyIndex: " .. myPetIndex .. " | TotalFarmAccs: " .. totalFarmAccs .. " | AvailablePets: " .. petCount)

			-- Tìm pet tương ứng với index của mình
			for _, petData in ipairs(availablePets) do
				if petData.index == myPetIndex then
					print("[✅] " .. player.Name .. " → Lấy pet#" .. myPetIndex .. " từ plot của " .. plotOwner)
					HandlePet(petData.pet, myPlot)
					IncrementPetsTaken(plotOwner)
					return
				end
			end

			-- Nếu không có pet cho mình trong lượt này, tính toán lại cho lần tiếp theo
			if petCount > 0 and petsTaken < petCount then
				print("[⏭️] Chưa đến lượt, chờ lần sau...")
				return
			elseif petCount == 0 then
				print("[✅] Plot " .. plotOwner .. " hết pet!")
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
	print("[ACC FARM] 🎯", player.Name, "→ gom pet:", CurrentPet, "| Index:", FarmAccIndex)
	
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
					print("[🚪] Hết pet rồi, kick checker account!")
					player:Kick("✅ Farm hoàn tất! Hết pet rồi.")
					return
				end
			end)
			task.wait(5)
		end
	end)
end

print("✅ Pet Farm Script loaded with Unified Pet Distribution System!")
