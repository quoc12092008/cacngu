-- ✅ Script: Multi-account auto farm (FIXED - check pet với mutation)

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

-- ⚙️ Lấy PlotController
local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- 🧠 Cấu hình ngoài
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

-- Xác định acc hiện tại có được farm không và pet nào
local CurrentPet = nil
for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		break
	end
end

---------------------------------------------------------------------
-- 📦 Lấy plot của chính bạn
---------------------------------------------------------------------
local function GetMyPlot()
	local myPlot = PlotController.GetMyPlot()
	if myPlot and myPlot.PlotModel then
		return myPlot.PlotModel
	end
	return nil
end

---------------------------------------------------------------------
-- 🏠 Lấy vị trí spawn (Decorations[12])
---------------------------------------------------------------------
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

---------------------------------------------------------------------
-- 🚶‍♂️ Di chuyển thật bằng Pathfinding
---------------------------------------------------------------------
local function WalkToPosition(targetPos)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		WaypointSpacing = 4
	})
	path:ComputeAsync(hrp.Position, targetPos)

	if path.Status ~= Enum.PathStatus.Success then
		warn("[Pathfind] ❌ Không thể tính đường đến:", targetPos)
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

---------------------------------------------------------------------
-- 🎥 Camera phía sau nhân vật
---------------------------------------------------------------------
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

---------------------------------------------------------------------
-- ⌨️ Giữ phím E thật
---------------------------------------------------------------------
local function HoldKeyEReal(duration)
	local start = tick()
	while tick() - start < duration do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

---------------------------------------------------------------------
-- 🔍 Check xem pet name có khớp không (bỏ qua mutation prefix)
---------------------------------------------------------------------
local function IsPetMatch(petName, targetPetName)
	-- So sánh trực tiếp
	if petName == targetPetName then
		return true
	end
	
	-- Bỏ qua các mutation prefix phổ biến
	local mutations = {
		"Gold ", "Diamond ", "Rainbow ", "Bloodrot ", "Candy ",
		"Lava ", "Galaxy ", "Yin and Yang	 "
	}
	
	local baseName = petName
	for _, mut in ipairs(mutations) do
		baseName = baseName:gsub("^" .. mut, "")
	end
	
	-- Check nếu base name khớp
	if baseName == targetPetName then
		return true
	end
	
	-- Check nếu target name nằm trong pet name
	if petName:find(targetPetName, 1, true) then
		return true
	end
	
	return false
end

---------------------------------------------------------------------
-- 🧭 Xử lý 1 con pet
---------------------------------------------------------------------
local function HandlePet(pet, myPlot)
	local targetPos = pet.WorldPivot and pet.WorldPivot.Position
	if not targetPos then return end

	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		AdjustCameraBehindPlayer(pet)
		HoldKeyEReal(HoldTime)

		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
		end
	end
end

---------------------------------------------------------------------
-- 🔍 Quét plots khác
---------------------------------------------------------------------
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			for _, pet in ipairs(plot:GetChildren()) do
				-- Dùng hàm check mới thay vì so sánh trực tiếp
				if IsPetMatch(pet.Name, CurrentPet) then
					print("[FARM] 🎯 Tìm thấy:", pet.Name, "→ Target:", CurrentPet)
					HandlePet(pet, myPlot)
				end
			end
		end
	end
end

---------------------------------------------------------------------
-- 🧩 Check nếu hết pet (FIXED - check cả mutation)
---------------------------------------------------------------------
local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then return true end

	-- Đếm số pet trong config
	local targetPets = {}
	for _, cfg in ipairs(AccHold) do
		targetPets[cfg.Pet] = true
	end

	-- Check xem có pet nào khớp không
	for _, pet in ipairs(myPlot:GetChildren()) do
		for targetPet, _ in pairs(targetPets) do
			if IsPetMatch(pet.Name, targetPet) then
				print("[CHECK] ✅ Còn pet:", pet.Name, "→ Target:", targetPet)
				return false
			end
		end
	end
	
	print("[CHECK] ❌ Không tìm thấy pet nào trong config")
	return true
end

---------------------------------------------------------------------
-- ♻️ Phân vai acc
---------------------------------------------------------------------
if CurrentPet then
	print("[ACC FARM] 🎯", player.Name, "→ gom pet:", CurrentPet)
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
	task.spawn(function()
		while true do
			pcall(function()
				if CheckMyPlotEmpty() then
					print("[KICK] ⚠️ Hết pet trong config, kick sau 5s...")
					task.wait(5)
					player:Kick("🔴 Hết pet cần giữ rồi.")
					return
				end
			end)
			task.wait(2)
		end
	end)
end
