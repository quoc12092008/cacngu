-- ✅ Auto Pet Collector v1.4 | Multi-account + Mutation Fix + DisplayName Detection
-- 👑 by Quốc (quoc12092008)

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

-- ⚙️ Controller
local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- 🧠 External Config
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

-- 🔍 Determine this account’s target pet
local CurrentPet = nil
for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		break
	end
end

---------------------------------------------------------------------
-- 📦 Get My Plot
---------------------------------------------------------------------
local function GetMyPlot()
	local myPlot = PlotController.GetMyPlot()
	if myPlot and myPlot.PlotModel then
		return myPlot.PlotModel
	end
	return nil
end

---------------------------------------------------------------------
-- 🏠 Get Home Spawn (Decorations[12])
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
-- 🚶‍♂️ Smooth Walking (Pathfinding)
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
-- 🎥 Camera Behind Player
---------------------------------------------------------------------
local function AdjustCameraBehindPlayer(targetPos)
	local cam = Workspace.CurrentCamera
	if not cam or not targetPos then return end
	local dir = (targetPos - hrp.Position).Unit
	local camPos = hrp.Position + (-dir * 5) + Vector3.new(0, 3, 0)
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0, 2, 0))
	task.delay(3.5, function()
		cam.CameraType = Enum.CameraType.Custom
	end)
end

---------------------------------------------------------------------
-- ⌨️ Hold E Real
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
-- 🧩 Get Pet Targets (DisplayName logic)
---------------------------------------------------------------------
local function GetPetTargetsFromPlot(plot, desiredName)
	local targets = {}
	if not plot then return targets end

	local desired = desiredName and desiredName:lower() or nil
	local pods = plot:FindFirstChild("AnimalPodiums")

	-- 1️⃣ Quét AnimalPodiums (ưu tiên vì có Overhead)
	if pods then
		for _, podium in ipairs(pods:GetChildren()) do
			local base = podium:FindFirstChild("Base")
			local spawn = base and base:FindFirstChild("Spawn")
			local attach = spawn and spawn:FindFirstChild("Attachment")
			local oh = attach and attach:FindFirstChild("AnimalOverhead")
			local lbl = oh and oh:FindFirstChild("DisplayName")
			local name = lbl and lbl.Text
			if name and name ~= "" then
				local n = name:lower()
				if (not desired) or n:find(desired, 1, true) then
					table.insert(targets, {
						name = name,
						pos = spawn and spawn.Position or podium:GetPivot().Position,
						instance = spawn or podium
					})
				end
			end
		end
	end

	-- 2️⃣ Fallback: quét Model trực tiếp
	for _, obj in ipairs(plot:GetChildren()) do
		if obj:IsA("Model") then
			local nm = obj.Name:lower()
			if (not desired) or nm:find(desired, 1, true) then
				local pv = (obj.WorldPivot and obj.WorldPivot.Position)
					or (obj.PrimaryPart and obj.PrimaryPart.Position)
				if pv then
					table.insert(targets, { name = obj.Name, pos = pv, instance = obj })
				end
			end
		end
	end

	return targets
end

---------------------------------------------------------------------
-- 🧭 Handle Pet
---------------------------------------------------------------------
local function HandlePet(target, myPlot)
	local targetPos = target and target.pos
	if not targetPos then return end

	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		AdjustCameraBehindPlayer(targetPos)
		HoldKeyEReal(HoldTime)

		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
		end
	end
end

---------------------------------------------------------------------
-- 🔍 Scan All Plots
---------------------------------------------------------------------
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			local targets = GetPetTargetsFromPlot(plot, CurrentPet)
			for _, t in ipairs(targets) do
				print("[PetDetect] 🎯 Đang xử lý:", t.name)
				HandlePet(t, myPlot)
			end
		end
	end
end

---------------------------------------------------------------------
-- 🏁 Check My Plot Empty (use DisplayName)
---------------------------------------------------------------------
local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then 
		warn("[PlotCheck] ❌ Không tìm thấy plot của bạn.")
		return true 
	end

	local want = {}
	for _, cfg in ipairs(AccHold) do
		if cfg.Pet then want[cfg.Pet:lower()] = true end
	end
	if next(want) == nil then return false end

	local targets = GetPetTargetsFromPlot(myPlot, nil)
	for _, t in ipairs(targets) do
		local n = (t.name or ""):lower()
		for petName in pairs(want) do
			if n:find(petName, 1, true) then
				print("[PlotCheck] ✅ Còn pet:", t.name)
				return false
			end
		end
	end

	warn("[PlotCheck] ⚠️ Không còn pet hợp lệ trong plot của bạn.")
	return true
end

---------------------------------------------------------------------
-- ♻️ Main Logic
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
