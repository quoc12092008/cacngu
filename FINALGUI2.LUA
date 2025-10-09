-- ✅ MULTI-ACCOUNT AUTO FARM (V2 - Neon Compact GUI)
-- ⚡ Full Version: GUI + Logic + AutoStart
-- ⚠️ Yêu cầu: getgenv().AccHold, HoldTime, CheckInterval

-- ⚙️ SERVICES
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- 🧩 PlotController
local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- 🌍 Global States
local farmingActive = false
local farmThread = nil
local checkThread = nil

---------------------------------------------------------------------
-- 🧱 GUI (Neon Compact Design)
---------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0, 370)
MainFrame.Position = UDim2.new(1, -330, 0, 40)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local Border = Instance.new("UIStroke")
Border.Thickness = 1.8
Border.Color = Color3.fromRGB(80, 140, 255)
Border.Transparency = 0.3
Border.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚙️ Auto Farm"
Title.TextColor3 = Color3.fromRGB(120, 200, 255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local function createBtn(txt, color, offset)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 28, 0, 28)
	btn.Position = UDim2.new(1, offset, 0.5, -14)
	btn.BackgroundColor3 = color
	btn.Text = txt
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.Parent = Header
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local MinimizeButton = createBtn("−", Color3.fromRGB(70, 90, 120), -68)
local CloseButton = createBtn("×", Color3.fromRGB(220, 70, 80), -34)

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 1, -60)
Content.Position = UDim2.new(0, 12, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Info = Instance.new("Frame")
Info.Size = UDim2.new(1, 0, 0, 100)
Info.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
Info.Parent = Content
Instance.new("UICorner", Info).CornerRadius = UDim.new(0, 10)

local AccountLabel = Instance.new("TextLabel")
AccountLabel.Size = UDim2.new(1, -16, 0, 22)
AccountLabel.Position = UDim2.new(0, 8, 0, 8)
AccountLabel.BackgroundTransparency = 1
AccountLabel.Text = "👤 " .. player.Name
AccountLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
AccountLabel.TextSize = 13
AccountLabel.Font = Enum.Font.Gotham
AccountLabel.TextXAlignment = Enum.TextXAlignment.Left
AccountLabel.Parent = Info

local RoleLabel = Instance.new("TextLabel")
RoleLabel.Size = UDim2.new(1, -16, 0, 50)
RoleLabel.Position = UDim2.new(0, 8, 0, 36)
RoleLabel.BackgroundTransparency = 1
RoleLabel.Text = "Đang khởi tạo..."
RoleLabel.TextColor3 = Color3.fromRGB(100, 255, 180)
RoleLabel.TextSize = 12
RoleLabel.Font = Enum.Font.GothamMedium
RoleLabel.TextXAlignment = Enum.TextXAlignment.Left
RoleLabel.TextYAlignment = Enum.TextYAlignment.Top
RoleLabel.Parent = Info

-- Settings
local Settings = Instance.new("Frame")
Settings.Size = UDim2.new(1, 0, 0, 120)
Settings.Position = UDim2.new(0, 0, 0, 110)
Settings.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
Settings.Parent = Content
Instance.new("UICorner", Settings).CornerRadius = UDim.new(0, 10)

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, -16, 0, 22)
Label.Position = UDim2.new(0, 8, 0, 6)
Label.BackgroundTransparency = 1
Label.Text = "⚙️ Cài đặt"
Label.TextColor3 = Color3.fromRGB(100, 200, 255)
Label.TextSize = 14
Label.Font = Enum.Font.GothamBold
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = Settings

local function makeInput(title, y, default)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -16, 0, 28)
	Frame.Position = UDim2.new(0, 8, 0, y)
	Frame.BackgroundTransparency = 1
	Frame.Parent = Settings

	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.new(0.55, 0, 1, 0)
	Text.BackgroundTransparency = 1
	Text.Text = title
	Text.TextColor3 = Color3.fromRGB(180, 180, 200)
	Text.TextSize = 12
	Text.Font = Enum.Font.Gotham
	Text.TextXAlignment = Enum.TextXAlignment.Left
	Text.Parent = Frame

	local Box = Instance.new("TextBox")
	Box.Size = UDim2.new(0.45, -4, 1, 0)
	Box.Position = UDim2.new(0.55, 4, 0, 0)
	Box.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
	Box.TextColor3 = Color3.new(1, 1, 1)
	Box.TextSize = 12
	Box.Font = Enum.Font.GothamMedium
	Box.Text = tostring(default)
	Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
	Box.Parent = Frame
	return Box
end

local HoldTimeInput = makeInput("⏱️ Hold Time:", 36, getgenv().HoldTime or 3.5)
local CheckIntervalInput = makeInput("🔄 Interval:", 72, getgenv().CheckInterval or 10)

-- Control
local Control = Instance.new("Frame")
Control.Size = UDim2.new(1, 0, 0, 80)
Control.Position = UDim2.new(0, 0, 0, 240)
Control.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
Control.Parent = Content
Instance.new("UICorner", Control).CornerRadius = UDim.new(0, 10)

local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(1, -16, 0, 34)
StopButton.Position = UDim2.new(0, 8, 0, 8)
StopButton.BackgroundColor3 = Color3.fromRGB(220, 70, 80)
StopButton.Text = "⏹ Dừng Farm"
StopButton.TextColor3 = Color3.new(1, 1, 1)
StopButton.TextSize = 14
StopButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", StopButton).CornerRadius = UDim.new(0, 8)
StopButton.Visible = false
StopButton.Parent = Control

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -16, 0, 32)
StatusText.Position = UDim2.new(0, 8, 0, 46)
StatusText.BackgroundTransparency = 1
StatusText.Text = "🟢 Đang hoạt động..."
StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
StatusText.TextSize = 12
StatusText.Font = Enum.Font.GothamMedium
StatusText.Parent = Control

---------------------------------------------------------------------
-- 🔧 LOGIC FARM
---------------------------------------------------------------------
local function GetMyPlot()
	local plot = PlotController.GetMyPlot()
	if plot and plot.PlotModel then return plot.PlotModel end
	return nil
end

local function GetHomeSpawn(myPlot)
	if not myPlot then return nil end
	local deco = myPlot:FindFirstChild("Decorations")
	if not deco then return nil end
	local spawn = deco:GetChildren()[12]
	if spawn then return spawn.CFrame.Position end
	return nil
end

local function WalkToPosition(target)
	local path = PathfindingService:CreatePath({WaypointSpacing=4})
	path:ComputeAsync(hrp.Position, target)
	if path.Status ~= Enum.PathStatus.Success then return false end
	for _, wp in ipairs(path:GetWaypoints()) do
		if not farmingActive then return false end
		if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
		humanoid:MoveTo(wp.Position)
		humanoid.MoveToFinished:Wait()
	end
	return true
end

local function HoldKeyEReal(time)
	local t0 = tick()
	while tick() - t0 < time and farmingActive do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function HandlePet(pet, plot)
	if not pet then return end
	if WalkToPosition(pet.WorldPivot.Position + Vector3.new(0,2,0)) then
		HoldKeyEReal(getgenv().HoldTime or 3.5)
		local home = GetHomeSpawn(plot)
		if home then WalkToPosition(home + Vector3.new(0,2,0)) end
	end
end

local function ScanAllPlots(currentPet)
	local myPlot = GetMyPlot()
	if not myPlot then return end
	local folder = Workspace:FindFirstChild("Plots")
	if not folder then return end
	for _, plot in ipairs(folder:GetChildren()) do
		if plot ~= myPlot then
			for _, pet in ipairs(plot:GetChildren()) do
				if pet.Name == currentPet then
					HandlePet(pet, myPlot)
				end
			end
		end
	end
end

local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then return true end
	for _, pet in ipairs(myPlot:GetChildren()) do
		for _, cfg in ipairs(getgenv().AccHold or {}) do
			if pet.Name == cfg.Pet then return false end
		end
	end
	return true
end

---------------------------------------------------------------------
-- 🚀 AUTO START LOGIC
---------------------------------------------------------------------
local function updatePetInfo()
	local AccHold = getgenv().AccHold or {}
	local currentPet = nil
	for _, cfg in ipairs(AccHold) do
		if cfg.AccountName == player.Name then
			currentPet = cfg.Pet
			break
		end
	end
	if currentPet then
		RoleLabel.Text = "🎯 FARM MODE\nPet: " .. currentPet
	else
		RoleLabel.Text = "👀 CHECK MODE\nTheo dõi plot"
	end
	return currentPet
end

local function autoStart()
	task.wait(1)
	local currentPet = updatePetInfo()
	farmingActive = true
	StopButton.Visible = true
	StatusText.Text = "🟢 Đang hoạt động..."
	
	if currentPet then
		farmThread = task.spawn(function()
			while farmingActive do
				pcall(function() ScanAllPlots(currentPet) end)
				task.wait(getgenv().CheckInterval or 10)
			end
		end)
	else
		checkThread = task.spawn(function()
			while farmingActive do
				pcall(function()
					if CheckMyPlotEmpty() then
						player:Kick("Plot trống.")
					end
				end)
				task.wait(5)
			end
		end)
	end
end

-- Stop Button
StopButton.MouseButton1Click:Connect(function()
	farmingActive = false
	StatusText.Text = "🔴 Đã dừng"
	StatusText.TextColor3 = Color3.fromRGB(255,100,100)
	StopButton.Visible = false
	if farmThread then task.cancel(farmThread) end
	if checkThread then task.cancel(checkThread) end
end)

-- Dragging + Minimize
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = MainFrame.Position
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
Header.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
end)
UserInputService.InputChanged:Connect(function(i)
	if i == dragInput and dragging then
		local d = i.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	MinimizeButton.Text = minimized and "+" or "−"
	TweenService:Create(MainFrame, TweenInfo.new(0.3), {
		Size = minimized and UDim2.new(0,310,0,42) or UDim2.new(0,310,0,370)
	}):Play()
	Content.Visible = not minimized
end)

CloseButton.MouseButton1Click:Connect(function()
	farmingActive = false
	if farmThread then task.cancel(farmThread) end
	if checkThread then task.cancel(checkThread) end
	ScreenGui:Destroy()
end)

-- Animation entry
MainFrame.Size = UDim2.new(0,0,0,0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
	Size = UDim2.new(0,310,0,370)
}):Play()

task.wait(0.5)
autoStart()

print("✅ AutoFarm GUI V2 Loaded!")
