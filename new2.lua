-- ✅ Script: Multi-account auto farm (Fixed - không kick nhầm acc có pet)

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
-- 🧭 Xử lý 1 con pet (debug + auto chọn WorldPivot / RootPart)
---------------------------------------------------------------------
local function HandlePet(pet, myPlot)
	local targetPos

	-- Ưu tiên WorldPivot
	if pet.WorldPivot then
		targetPos = pet.WorldPivot.Position
		print(("[DEBUG] 🧭 Pet '%s' có WorldPivot: %s"):format(pet.Name, tostring(targetPos)))
	elseif pet.PrimaryPart then
		targetPos = pet.PrimaryPart.Position
		print(("[DEBUG] 🧩 Pet '%s' dùng PrimaryPart: %s"):format(pet.Name, tostring(targetPos)))
	else
		local root = pet:FindFirstChild("RootPart") or pet:FindFirstChildWhichIsA("BasePart")
		if root then
			targetPos = root.Position
			print(("[DEBUG] 🦴 Pet '%s' dùng RootPart/BasePart: %s"):format(pet.Name, tostring(targetPos)))
		end
	end

	if not targetPos then
		warn("[Pet] ❌ Không tìm thấy vị trí hợp lệ cho:", pet.Name)
		return
	end

	print(("[DEBUG] 🚶‍♂️ Đang di chuyển tới pet '%s'..."):format(pet.Name))
	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		print(("[DEBUG] 🎯 Đã đến vị trí pet '%s', bắt đầu giữ phím E..."):format(pet.Name))
		AdjustCameraBehindPlayer(pet)
		HoldKeyEReal(HoldTime)

		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			print(("[DEBUG] 🏠 Quay về vị trí nhà: %s"):format(tostring(homePos)))
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
		end
	else
		warn("[Pathfind] ❌ Không thể di chuyển đến:", pet.Name)
	end
end

---------------------------------------------------------------------
-- 🧮 Chuẩn hóa tên (so sánh không phân biệt hoa thường)
---------------------------------------------------------------------
local function normalizeName(s)
	if not s then return "" end
	return tostring(s):gsub("^%s+", ""):gsub("%s+$", ""):lower()
end

---------------------------------------------------------------------
-- 🔍 Quét plots khác (chỉ lấy đúng pet trong danh sách)
---------------------------------------------------------------------
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then
		warn("[DEBUG] ⚠️ Không tìm thấy plot của bạn!")
		return
	end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then
		warn("[DEBUG] ⚠️ Không tìm thấy thư mục Plots!")
		return
	end

	print("[DEBUG] 🔎 Bắt đầu quét tất cả plots...")
	print(("[DEBUG] 🎯 Pet cần tìm: %s"):format(tostring(CurrentPet)))

	local normalizedTarget = normalizeName(CurrentPet)

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			print(("[DEBUG] 🧱 Đang kiểm tra plot: %s"):format(plot.Name))
			for _, pet in ipairs(plot:GetChildren()) do
				if not pet:IsA("Model") then continue end

				local petName = pet.Name or ""
				local mutation = pet:GetAttribute("Mutation")
				local yin = pet:GetAttribute("YinYangPalette")
				local hasPivot = pet.WorldPivot ~= nil

				-- debug log tất cả
				print(("[DEBUG] 📦 Pet: %s | Mutation=%s | YinYang=%s | HasPivot=%s"):format(
					petName, tostring(mutation), tostring(yin), tostring(hasPivot)
				))

				if normalizeName(petName) == normalizedTarget then
					print(("[Pet Found] 🎯 Hợp lệ: %s → Bắt đầu xử lý..."):format(petName))
					HandlePet(pet, myPlot)
				end
			end
		end
	end

	print("[DEBUG] ✅ Quét xong plots.")
end

---------------------------------------------------------------------
-- 🧩 Check nếu hết pet TRONG DANH SÁCH CONFIG
---------------------------------------------------------------------
local noPetCount = 0  -- đếm số lần liên tiếp không thấy pet

local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then
		warn("[DEBUG] ⚠️ Không tìm thấy plot của chính bạn.")
		return false
	end

	-- ✅ Lấy danh sách pet của acc này từ config
	local myPets = {}
	for _, cfg in ipairs(AccHold) do
		if cfg.AccountName == player.Name then
			table.insert(myPets, normalizeName(cfg.Pet))
		end
	end

	if #myPets == 0 then
		warn("[DEBUG] ⚠️ Acc này không có pet nào trong config.")
		return false
	end

	-- ✅ Đếm pet trong danh sách còn trong plot
	local foundPets = 0
	for _, obj in ipairs(myPlot:GetChildren()) do
		if obj:IsA("Model") then
			local isDecoration = obj.Name == "Decorations" or obj:FindFirstChild("Decorations")
			if not isDecoration then
				local petName = normalizeName(obj.Name)
				for _, configPet in ipairs(myPets) do
					if petName == configPet then
						foundPets += 1
						print(("[DEBUG] 🐾 Pet trong config còn lại: %s"):format(obj.Name))
						break
					end
				end
			end
		end
	end

	if foundPets > 0 then
		noPetCount = 0
		print(("[DEBUG] ✅ Còn %d pet trong danh sách config."):format(foundPets))
		return false
	else
		noPetCount += 1
		print(("[DEBUG] ⚠️ Lần %d không thấy pet nào trong config."):format(noPetCount))
	end

	-- Chỉ kick nếu 3 lần liên tiếp không thấy pet trong config
	if noPetCount >= 3 then
		print("[DEBUG] ❌ Xác nhận hết pet trong danh sách config sau 3 lần kiểm tra.")
		return true
	end

	return false
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
					player:Kick("Hết pet rồi.")
					return
				end
			end)
			task.wait(5)
		end
	end)
end
