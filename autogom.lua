-- ✅ Script: Multi-account auto farm (chia pet riêng từng acc, đọc config từ getgenv)

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
-- 🔍 Quét plots khác (debug chi tiết)
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

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			print(("[DEBUG] 🧱 Đang kiểm tra plot: %s"):format(plot.Name))
			for _, pet in ipairs(plot:GetChildren()) do
				if not pet:IsA("Model") then continue end

				local mutation = pet:GetAttribute("Mutation")
				local yin = pet:GetAttribute("YinYangPalette")
				local hasPivot = pet.WorldPivot ~= nil
				local match = false

				-- ✅ Kiểm tra theo tên
				if pet.Name == CurrentPet then
					match = true
				end

				-- ✅ Kiểm tra Attributes (in ra dù có hay không)
				print(("[DEBUG] 📦 Pet: %s | Mutation=%s | YinYang=%s | HasPivot=%s"):format(
					pet.Name,
					tostring(mutation),
					tostring(yin),
					tostring(hasPivot)
				))

				if mutation or yin then
					match = true
				end

				if match then
					print(("[Pet Found] 🎯 Hợp lệ: %s → Bắt đầu xử lý..."):format(pet.Name))
					HandlePet(pet, myPlot)
				end
			end
		end
	end

	print("[DEBUG] ✅ Quét xong plots.")
end

---------------------------------------------------------------------
-- 🧩 Check nếu hết pet (fix nhận dạng Attributes)
---------------------------------------------------------------------
local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then
		warn("[DEBUG] ⚠️ Không tìm thấy plot của chính bạn.")
		return true
	end

	for _, pet in ipairs(myPlot:GetChildren()) do
		if not pet:IsA("Model") then continue end

		local mutation = pet:GetAttribute("Mutation")
		local yin = pet:GetAttribute("YinYangPalette")

		for _, cfg in ipairs(AccHold) do
			-- kiểm tra theo cả tên và attribute
			if pet.Name == cfg.Pet or mutation or yin then
				print(("[DEBUG] 🐾 Vẫn còn pet hợp lệ: %s | Mutation=%s | YinYang=%s"):format(
					pet.Name, tostring(mutation), tostring(yin)
				))
				return false -- còn pet
			end
		end
	end

	print("[DEBUG] ❌ Không tìm thấy pet nào phù hợp trong plot của bạn.")
	return true -- hết pet
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
