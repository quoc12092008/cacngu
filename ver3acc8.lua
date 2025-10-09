-- 🧹 Xóa UI cũ nếu có
if game.CoreGui:FindFirstChild("BananaStatsChecker") then
	game.CoreGui.BananaStatsChecker:Destroy()
end

-- ⚙️ Services
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

---------------------------------------------------------------------
-- 🔧 Lấy PlotController an toàn + Start()
---------------------------------------------------------------------
local PlotController = nil
pcall(function()
	local Controllers = ReplicatedStorage:WaitForChild("Controllers", 10)
	local Module = Controllers:WaitForChild("PlotController", 10)
	PlotController = require(Module)
end)

if PlotController and PlotController.Start then
	task.spawn(function()
		pcall(function()
			PlotController:Start()
			print("[✅] PlotController started successfully!")
		end)
	end)
else
	warn("[⚠️] Không load được PlotController, chuyển sang chế độ tạm.")
	PlotController = { GetMyPlot = function() return nil end }
end

---------------------------------------------------------------------
-- ⚙️ Config
---------------------------------------------------------------------
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

local CurrentPet = nil
local farmMode = "Checker"
for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		farmMode = "Farmer"
		break
	end
end

---------------------------------------------------------------------
-- 🎨 UI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BananaStatsChecker"

local statusFrame = Instance.new("Frame", gui)
statusFrame.AnchorPoint = Vector2.new(0.5, 0)
statusFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
statusFrame.Size = UDim2.new(0, 380, 0, 42)
statusFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
statusFrame.BackgroundTransparency = 0.2

local statusCorner = Instance.new("UICorner", statusFrame)
statusCorner.CornerRadius = UDim.new(0, 8)

local statusStroke = Instance.new("UIStroke", statusFrame)
statusStroke.Color = Color3.fromRGB(255, 180, 0)
statusStroke.Thickness = 2

local statusText = Instance.new("TextLabel", statusFrame)
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamBold
statusText.TextColor3 = Color3.fromRGB(255, 200, 40)
statusText.TextSize = 17
statusText.Text = "Status : Initializing..."

---------------------------------------------------------------------
-- 🧠 Các hàm hỗ trợ
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
	for _, obj in ipairs(deco:GetDescendants()) do
		if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "spawn") or string.find(string.lower(obj.Name), "home")) then
			return obj.Position
		end
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
	if path.Status ~= Enum.PathStatus.Success then return false end
	for _, wp in ipairs(path:GetWaypoints()) do
		if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
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

---------------------------------------------------------------------
-- 🧱 Anti trùng pet đơn giản (local lock)
---------------------------------------------------------------------
shared.PetLocks = shared.PetLocks or {}

local function HandlePet(pet, myPlot)
	if not pet or not myPlot then return end

	if shared.PetLocks[pet.Name] and shared.PetLocks[pet.Name] ~= player.Name then
		return
	end
	shared.PetLocks[pet.Name] = player.Name

	local targetPos = pet.WorldPivot and pet.WorldPivot.Position
	if not targetPos then return end

	statusText.Text = "Status : Walking to " .. pet.Name
	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		AdjustCameraBehindPlayer(pet)
		statusText.Text = "Status : Holding E on " .. pet.Name
		HoldKeyEReal(HoldTime)
		shared.PetLocks[pet.Name] = nil

		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			statusText.Text = "Status : Returning home..."
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
		end
	end
	statusText.Text = "Status : Farming " .. CurrentPet
end

---------------------------------------------------------------------
-- 🔁 Quét plots
---------------------------------------------------------------------
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

---------------------------------------------------------------------
-- 🚀 Khởi động farm
---------------------------------------------------------------------
if CurrentPet then
	print("[ACC FARM] 🎯", player.Name, "→ gom pet:", CurrentPet)
	statusText.Text = "Status : Farming " .. CurrentPet
	task.spawn(function()
		while task.wait(CheckInterval) do
			pcall(ScanAllPlots)
		end
	end)
else
	print("[ACC CHECK] 👀", player.Name, "không trong danh sách farm, kiểm tra plot riêng.")
	statusText.Text = "Status : Monitoring Plot"
	task.spawn(function()
		while task.wait(5) do
			pcall(function()
				local myPlot = GetMyPlot()
				if myPlot and #myPlot:GetChildren() == 0 then
					player:Kick("Hết pet rồi.")
				end
			end)
		end
	end)
end

print("✅ Pet Farm UI + PlotController Fix loaded!")
