-- ✅ Multi-account Auto Farm v1.8 (Acc FARM + Acc CHECK ổn định)
-- Tác giả: Quốc | Cập nhật: 2025-10-09

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

-- ⚙️ PlotController
local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- ⚙️ Config
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

-- 🧠 Xác định acc FARM
local CurrentPet = nil
for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		break
	end
end

---------------------------------------------------------------------
-- 🧩 Helpers
---------------------------------------------------------------------
local function normalizeName(s)
	if not s then return "" end
	return tostring(s):gsub("^%s+", ""):gsub("%s+$", ""):lower()
end

local function IsPetModel(m)
	if not (m and m:IsA("Model")) then return false end
	if m:GetAttribute("Mutation") ~= nil then return true end
	if m:GetAttribute("YinYangPalette") ~= nil then return true end
	if m.WorldPivot then
		local hasPart = m.PrimaryPart or m:FindFirstChild("RootPart") or m:FindFirstChildWhichIsA("BasePart")
		if hasPart and m.Name ~= "FriendPanel" and m.Name ~= "Decorations" then
			return true
		end
	end
	return false
end

---------------------------------------------------------------------
-- 📦 Lấy plot
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
-- 🚶 Di chuyển bằng Pathfinding
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
-- 🎥 Camera sau lưng
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
	task.delay(4, function() cam.CameraType = Enum.CameraType.Custom end)
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
-- 🧭 Xử lý 1 pet
---------------------------------------------------------------------
local PetHandled = 0

local function HandlePet(pet, myPlot)
	local targetPos
	if pet.WorldPivot then
		targetPos = pet.WorldPivot.Position
	elseif pet.PrimaryPart then
		targetPos = pet.PrimaryPart.Position
	else
		local root = pet:FindFirstChild("RootPart") or pet:FindFirstChildWhichIsA("BasePart")
		if root then targetPos = root.Position end
	end
	if not targetPos then return end

	print(("[DEBUG] 🚶 Tới pet '%s'..."):format(pet.Name))
	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		PetHandled += 1
		print(("[DEBUG] 🎯 Đã đến '%s' → giữ E... (Tổng đã gom: %d)"):format(pet.Name, PetHandled))
		AdjustCameraBehindPlayer(pet)
		HoldKeyEReal(HoldTime)
		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			print("[DEBUG] 🏠 Quay về nhà:", tostring(homePos))
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
		end
	end
end

---------------------------------------------------------------------
-- 🔍 Quét plots khác (Acc FARM)
---------------------------------------------------------------------
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end
	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	print("[DEBUG] 🔎 Quét plots... Target:", CurrentPet)
	local normalizedTarget = normalizeName(CurrentPet)

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			for _, pet in ipairs(plot:GetChildren()) do
				if not pet:IsA("Model") then continue end
				if normalizeName(pet.Name) == normalizedTarget then
					print(("[Pet Found] 🎯 %s → Xử lý..."):format(pet.Name))
					HandlePet(pet, myPlot)
				end
			end
		end
	end
end

---------------------------------------------------------------------
-- 🧩 Kiểm tra hết pet (Acc CHECK + FARM)
---------------------------------------------------------------------
local noPetCount = 0
local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then return false end
	local target = CurrentPet and normalizeName(CurrentPet) or nil
	local found = false
	local foundName = nil

	for _, child in ipairs(myPlot:GetChildren()) do
		if not child:IsA("Model") then continue end
		if target then
			if normalizeName(child.Name) == target then
				found, foundName = true, child.Name
				break
			end
		else
			if IsPetModel(child) then
				found, foundName = true, child.Name
				break
			end
		end
	end

	if found then
		noPetCount = 0
		print(("[DEBUG] 🐾 Plot còn pet (%s): %s")
			:format(target and "Target" or "Any", foundName))
		return false
	else
		noPetCount += 1
		print(("[DEBUG] ⚠️ Lần %d không thấy pet (%s).")
			:format(noPetCount, target and "Target" or "Any"))
		if noPetCount >= 3 then
			print("[DEBUG] ❌ Xác nhận hết pet sau 3 lần liên tiếp.")
			return true
		end
		return false
	end
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
				print(("[DEBUG] 🔁 Tổng số pet đã gom: %d"):format(PetHandled))
			end)
			task.wait(CheckInterval)
		end
	end)
else
	print("[ACC CHECK] 👀", player.Name, "không trong danh sách farm, kiểm tra plot riêng.")
	task.spawn(function()
		while true do
			pcall(function()
				task.wait(2)
				if CheckMyPlotEmpty() then
					player:Kick("Hết pet rồi.")
					return
				end
			end)
			task.wait(5)
		end
	end)
end
