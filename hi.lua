-- ✅ Multi-account auto pet collector
-- Version: 1.2 | Fix Mutation detection + Multi-config + Smooth walk

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

-- ⚙️ Controllers
local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- 🧠 External Config
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

-- 🧾 Determine current acc role & pet type
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
-- 🚶‍♂️ Walk To Position (smooth pathfinding)
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
-- 🎥 Camera Behind Character
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

	task.delay(3.5, function()
		cam.CameraType = Enum.CameraType.Custom
	end)
end

---------------------------------------------------------------------
-- ⌨️ Hold E (Real)
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
-- 🧭 Handle Pet
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
-- 🔍 Scan All Plots
---------------------------------------------------------------------
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			for _, pet in ipairs(plot:GetChildren()) do
				local baseName = string.lower(pet.Name)
				local currentName = string.lower(CurrentPet or "")
				-- ✅ Mutation fix: lấy mọi biến thể cùng loại
				if string.find(baseName, currentName) then
					print("[PetDetect] 🎯 Đang xử lý:", pet.Name)
					HandlePet(pet, myPlot)
				end
			end
		end
	end
end

---------------------------------------------------------------------
-- 🧩 Check if My Plot is Empty
---------------------------------------------------------------------
-- ✅ Kiểm tra plot của bạn còn pet hợp lệ (kể cả có Mutation)
local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then 
		warn("[PlotCheck] ❌ Không tìm thấy plot của bạn.")
		return true 
	end

	local found = false

	-- Hàm đệ quy quét tất cả thư mục con (Animals, AnimalPodiums, Decorations, v.v.)
	local function scanFolder(folder)
		for _, obj in ipairs(folder:GetChildren()) do
			if obj:IsA("Model") then
				local baseName = string.lower(obj.Name)

				-- Kiểm tra mọi pet hợp lệ trong danh sách AccHold
				for _, cfg in ipairs(AccHold) do
					local cfgName = string.lower(cfg.Pet)
					if string.find(baseName, cfgName) then
						-- Nếu có mutation thì vẫn tính
						local hasMutation = obj:GetAttribute("Mutation")
						if hasMutation then
							print(string.format("[PlotCheck] ✅ Tìm thấy pet có Mutation: %s (%s)", obj.Name, tostring(hasMutation)))
						else
							print(string.format("[PlotCheck] ✅ Tìm thấy pet: %s", obj.Name))
						end
						found = true
						break
					end
				end
			end

			-- Nếu là Folder hoặc Model chứa nhiều pet bên trong thì tiếp tục quét
			if obj:IsA("Folder") or obj:IsA("Model") then
				scanFolder(obj)
			end
		end
	end

	scanFolder(myPlot)

	if not found then
		warn("[PlotCheck] ⚠️ Không còn pet hợp lệ trong plot của bạn.")
	end

	return not found
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
