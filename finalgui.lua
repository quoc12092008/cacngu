-- ✅ Multi-account Auto Farm Script với GUI tích hợp (Auto Start + Compact Design)

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

-- ⚙️ Lấy PlotController
local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- 🧠 Biến toàn cục
local farmingActive = false
local farmThread = nil
local checkThread = nil

-- 🎨 Tạo GUI (Compact & Modern)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- 📦 Main Frame (Smaller & Cleaner)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(1, -340, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Gradient Background
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- 🎯 Header (Compact)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local HeaderBottom = Instance.new("Frame")
HeaderBottom.Size = UDim2.new(1, 0, 0, 16)
HeaderBottom.Position = UDim2.new(0, 0, 1, -16)
HeaderBottom.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
HeaderBottom.BorderSizePixel = 0
HeaderBottom.Parent = Header

-- Glow effect for header
local HeaderGlow = Instance.new("UIGradient")
HeaderGlow.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
}
HeaderGlow.Rotation = 90
HeaderGlow.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 Auto Farm"
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Status indicator (animated dot)
local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 90, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Header

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0.5, -15)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 220)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = Header

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 80)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 22
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- 📋 Content (Compact)
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -24, 1, -57)
Content.Position = UDim2.new(0, 12, 0, 51)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Info Card (Compact)
local InfoCard = Instance.new("Frame")
InfoCard.Name = "InfoCard"
InfoCard.Size = UDim2.new(1, 0, 0, 110)
InfoCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
InfoCard.BorderSizePixel = 0
InfoCard.Parent = Content

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 12)
InfoCorner.Parent = InfoCard

local InfoGradient = Instance.new("UIGradient")
InfoGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 40))
}
InfoGradient.Rotation = 135
InfoGradient.Parent = InfoCard

local AccountLabel = Instance.new("TextLabel")
AccountLabel.Size = UDim2.new(1, -16, 0, 20)
AccountLabel.Position = UDim2.new(0, 8, 0, 8)
AccountLabel.BackgroundTransparency = 1
AccountLabel.Text = "👤 " .. player.Name
AccountLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
AccountLabel.TextSize = 13
AccountLabel.Font = Enum.Font.Gotham
AccountLabel.TextXAlignment = Enum.TextXAlignment.Left
AccountLabel.Parent = InfoCard

local RoleLabel = Instance.new("TextLabel")
RoleLabel.Name = "RoleLabel"
RoleLabel.Size = UDim2.new(1, -16, 0, 60)
RoleLabel.Position = UDim2.new(0, 8, 0, 32)
RoleLabel.BackgroundTransparency = 1
RoleLabel.Text = "Đang khởi tạo..."
RoleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
RoleLabel.TextSize = 12
RoleLabel.Font = Enum.Font.Gotham
RoleLabel.TextWrapped = true
RoleLabel.TextXAlignment = Enum.TextXAlignment.Left
RoleLabel.TextYAlignment = Enum.TextYAlignment.Top
RoleLabel.Parent = InfoCard

-- Settings Card
local SettingsCard = Instance.new("Frame")
SettingsCard.Name = "SettingsCard"
SettingsCard.Size = UDim2.new(1, 0, 0, 130)
SettingsCard.Position = UDim2.new(0, 0, 0, 118)
SettingsCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SettingsCard.BorderSizePixel = 0
SettingsCard.Parent = Content

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 12)
SettingsCorner.Parent = SettingsCard

local SettingsHeader = Instance.new("TextLabel")
SettingsHeader.Size = UDim2.new(1, -16, 0, 24)
SettingsHeader.Position = UDim2.new(0, 8, 0, 6)
SettingsHeader.BackgroundTransparency = 1
SettingsHeader.Text = "⚙️ Cài đặt"
SettingsHeader.TextColor3 = Color3.fromRGB(100, 200, 255)
SettingsHeader.TextSize = 14
SettingsHeader.Font = Enum.Font.GothamBold
SettingsHeader.TextXAlignment = Enum.TextXAlignment.Left
SettingsHeader.Parent = SettingsCard

-- Hold Time (Inline)
local HoldContainer = Instance.new("Frame")
HoldContainer.Size = UDim2.new(1, -16, 0, 30)
HoldContainer.Position = UDim2.new(0, 8, 0, 36)
HoldContainer.BackgroundTransparency = 1
HoldContainer.Parent = SettingsCard

local HoldLabel = Instance.new("TextLabel")
HoldLabel.Size = UDim2.new(0.55, 0, 1, 0)
HoldLabel.BackgroundTransparency = 1
HoldLabel.Text = "⏱️ Hold Time:"
HoldLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
HoldLabel.TextSize = 12
HoldLabel.Font = Enum.Font.Gotham
HoldLabel.TextXAlignment = Enum.TextXAlignment.Left
HoldLabel.Parent = HoldContainer

local HoldTimeInput = Instance.new("TextBox")
HoldTimeInput.Name = "HoldTimeInput"
HoldTimeInput.Size = UDim2.new(0.45, -4, 1, 0)
HoldTimeInput.Position = UDim2.new(0.55, 4, 0, 0)
HoldTimeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
HoldTimeInput.Text = tostring(getgenv().HoldTime or 3.5)
HoldTimeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
HoldTimeInput.TextSize = 12
HoldTimeInput.Font = Enum.Font.GothamMedium
HoldTimeInput.PlaceholderText = "3.5"
HoldTimeInput.Parent = HoldContainer

local HoldInputCorner = Instance.new("UICorner")
HoldInputCorner.CornerRadius = UDim.new(0, 6)
HoldInputCorner.Parent = HoldTimeInput

-- Check Interval (Inline)
local IntervalContainer = Instance.new("Frame")
IntervalContainer.Size = UDim2.new(1, -16, 0, 30)
IntervalContainer.Position = UDim2.new(0, 8, 0, 72)
IntervalContainer.BackgroundTransparency = 1
IntervalContainer.Parent = SettingsCard

local IntervalLabel = Instance.new("TextLabel")
IntervalLabel.Size = UDim2.new(0.55, 0, 1, 0)
IntervalLabel.BackgroundTransparency = 1
IntervalLabel.Text = "🔄 Interval:"
IntervalLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
IntervalLabel.TextSize = 12
IntervalLabel.Font = Enum.Font.Gotham
IntervalLabel.TextXAlignment = Enum.TextXAlignment.Left
IntervalLabel.Parent = IntervalContainer

local CheckIntervalInput = Instance.new("TextBox")
CheckIntervalInput.Name = "CheckIntervalInput"
CheckIntervalInput.Size = UDim2.new(0.45, -4, 1, 0)
CheckIntervalInput.Position = UDim2.new(0.55, 4, 0, 0)
CheckIntervalInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
CheckIntervalInput.Text = tostring(getgenv().CheckInterval or 10)
CheckIntervalInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckIntervalInput.TextSize = 12
CheckIntervalInput.Font = Enum.Font.GothamMedium
CheckIntervalInput.PlaceholderText = "10"
CheckIntervalInput.Parent = IntervalContainer

local IntervalInputCorner = Instance.new("UICorner")
IntervalInputCorner.CornerRadius = UDim.new(0, 6)
IntervalInputCorner.Parent = CheckIntervalInput

-- Control Buttons
local ControlCard = Instance.new("Frame")
ControlCard.Name = "ControlCard"
ControlCard.Size = UDim2.new(1, 0, 0, 85)
ControlCard.Position = UDim2.new(0, 0, 0, 256)
ControlCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ControlCard.BorderSizePixel = 0
ControlCard.Parent = Content

local ControlCorner = Instance.new("UICorner")
ControlCorner.CornerRadius = UDim.new(0, 12)
ControlCorner.Parent = ControlCard

local StopButton = Instance.new("TextButton")
StopButton.Name = "StopButton"
StopButton.Size = UDim2.new(1, -16, 0, 36)
StopButton.Position = UDim2.new(0, 8, 0, 8)
StopButton.BackgroundColor3 = Color3.fromRGB(220, 60, 80)
StopButton.Text = "⏹ Dừng Farm"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.TextSize = 14
StopButton.Font = Enum.Font.GothamBold
StopButton.Visible = false
StopButton.Parent = ControlCard

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 8)
StopCorner.Parent = StopButton

local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(1, -16, 0, 36)
StatusText.Position = UDim2.new(0, 8, 0, 48)
StatusText.BackgroundTransparency = 1
StatusText.Text = "🟢 Đang hoạt động..."
StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
StatusText.TextSize = 12
StatusText.Font = Enum.Font.GothamMedium
StatusText.Parent = ControlCard

---------------------------------------------------------------------
-- 🔧 FARMING FUNCTIONS
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
		if not farmingActive then return false end
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
	while tick() - start < duration and farmingActive do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function HandlePet(pet, myPlot)
	if not farmingActive then return end
	local targetPos = pet.WorldPivot and pet.WorldPivot.Position
	if not targetPos then return end

	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		AdjustCameraBehindPlayer(pet)
		HoldKeyEReal(getgenv().HoldTime or 3.5)

		local homePos = GetHomeSpawn(myPlot)
		if homePos and farmingActive then
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
		end
	end
end

local function ScanAllPlots(currentPet)
	if not farmingActive then return end
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if not farmingActive then break end
		if plot:IsA("Model") and plot ~= myPlot then
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

	local AccHold = getgenv().AccHold or {}
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
-- 🔧 GUI FUNCTIONALITY
---------------------------------------------------------------------

local function addHoverEffect(button, brightnessFactor)
	brightnessFactor = brightnessFactor or 0.15
	local originalColor = button.BackgroundColor3
	
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			BackgroundColor3 = originalColor:Lerp(Color3.fromRGB(255, 255, 255), brightnessFactor)
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			BackgroundColor3 = originalColor
		}):Play()
	end)
end

addHoverEffect(CloseButton)
addHoverEffect(MinimizeButton)
addHoverEffect(StopButton)

-- Draggable GUI
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Minimize functionality
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local targetSize = isMinimized and UDim2.new(0, 320, 0, 45) or UDim2.new(0, 320, 0, 380)
	MinimizeButton.Text = isMinimized and "+" or "−"
	
	TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Size = targetSize
	}):Play()
	
	Content.Visible = not isMinimized
end)

CloseButton.MouseButton1Click:Connect(function()
	farmingActive = false
	if farmThread then task.cancel(farmThread) end
	if checkThread then task.cancel(checkThread) end
	ScreenGui:Destroy()
end)

-- Auto-save settings when changed
HoldTimeInput.FocusLost:Connect(function()
	local holdTime = tonumber(HoldTimeInput.Text)
	if holdTime and holdTime > 0 then
		getgenv().HoldTime = holdTime
	else
		HoldTimeInput.Text = tostring(getgenv().HoldTime or 3.5)
	end
end)

CheckIntervalInput.FocusLost:Connect(function()
	local checkInterval = tonumber(CheckIntervalInput.Text)
	if checkInterval and checkInterval > 0 then
		getgenv().CheckInterval = checkInterval
	else
		CheckIntervalInput.Text = tostring(getgenv().CheckInterval or 10)
	end
end)

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
		RoleLabel.Text = "✅ FARM MODE\n🎯 Pet: " .. currentPet .. "\n📍 Quét plots khác"
		RoleLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	else
		RoleLabel.Text = "👀 CHECK MODE\n⚠️ Không farm\n📊 Kiểm tra plot & auto kick"
		RoleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	end
	
	return currentPet
end

local function animateStatusDot()
	while true do
		if farmingActive then
			TweenService:Create(StatusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundColor3 = Color3.fromRGB(100, 255, 150)
			}):Play()
			task.wait(0.8)
			TweenService:Create(StatusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundColor3 = Color3.fromRGB(60, 200, 100)
			}):Play()
			task.wait(0.8)
		else
			StatusDot.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
			task.wait(1)
		end
	end
end

task.spawn(animateStatusDot)

StopButton.MouseButton1Click:Connect(function()
	farmingActive = false
	StopButton.Visible = false
	StatusText.Text = "🔴 Đã dừng"
	StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
	StatusDot.BackgroundColor3 = Color3.fromRGB(220, 60, 80)
	
	if farmThread then
		task.cancel(farmThread)
		farmThread = nil
	end
	
	if checkThread then
		task.cancel(checkThread)
		checkThread = nil
	end
end)

-- 🚀 AUTO START
local function autoStart()
	local currentPet = updatePetInfo()
	
	task.wait(1)
	
	farmingActive = true
	StopButton.Visible = true
	StatusText.Text = "🟢 Đang hoạt động..."
	StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
	
	if currentPet then
		print("[AUTO FARM] 🎯", player.Name, "→ Pet:", currentPet)
		farmThread = task.spawn(function()
			while farmingActive do
				pcall(function()
					ScanAllPlots(currentPet)
				end)
				task.wait(getgenv().CheckInterval or 10)
			end
		end)
	else
		print("[AUTO CHECK] 👀", player.Name, "→ Plot checker")
		checkThread = task.spawn(function()
			while farmingActive do
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
end

-- Entry animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(1, 0, 0, 20)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0, 320, 0, 380),
	Position = UDim2.new(1, -340, 0, 20)
}):Play()

task.wait(0.5)
autoStart()

print("✅ Auto Farm GUI loaded!")
print("🚀 Auto-started farming")
print("🎯 Account:", player.Name)
