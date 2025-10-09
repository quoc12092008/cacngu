-- ✅ Multi-account Auto Farm Script với GUI tích hợp

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

-- 🎨 Tạo GUI
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

-- 📦 Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- 🎯 Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderBottom = Instance.new("Frame")
HeaderBottom.Size = UDim2.new(1, 0, 0, 12)
HeaderBottom.Position = UDim2.new(0, 0, 1, -12)
HeaderBottom.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
HeaderBottom.BorderSizePixel = 0
HeaderBottom.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 Auto Farm Manager"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -45, 0.5, -17.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- 📋 Content Frame
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -30, 1, -80)
Content.Position = UDim2.new(0, 15, 0, 65)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 6
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.Parent = Content

-- 📊 Status Section
local StatusSection = Instance.new("Frame")
StatusSection.Name = "StatusSection"
StatusSection.Size = UDim2.new(1, 0, 0, 80)
StatusSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
StatusSection.BorderSizePixel = 0
StatusSection.Parent = Content

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = StatusSection

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "📊 Trạng thái"
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
StatusLabel.TextSize = 16
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusSection

local AccountStatus = Instance.new("TextLabel")
AccountStatus.Name = "AccountStatus"
AccountStatus.Size = UDim2.new(1, -20, 0, 20)
AccountStatus.Position = UDim2.new(0, 10, 0, 40)
AccountStatus.BackgroundTransparency = 1
AccountStatus.Text = "👤 Account: " .. player.Name
AccountStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
AccountStatus.TextSize = 14
AccountStatus.Font = Enum.Font.Gotham
AccountStatus.TextXAlignment = Enum.TextXAlignment.Left
AccountStatus.Parent = StatusSection

-- 🎮 Control Section
local ControlSection = Instance.new("Frame")
ControlSection.Name = "ControlSection"
ControlSection.Size = UDim2.new(1, 0, 0, 200)
ControlSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
ControlSection.BorderSizePixel = 0
ControlSection.Parent = Content

local ControlCorner = Instance.new("UICorner")
ControlCorner.CornerRadius = UDim.new(0, 10)
ControlCorner.Parent = ControlSection

local ControlLabel = Instance.new("TextLabel")
ControlLabel.Size = UDim2.new(1, -20, 0, 25)
ControlLabel.Position = UDim2.new(0, 10, 0, 10)
ControlLabel.BackgroundTransparency = 1
ControlLabel.Text = "⚙️ Cài đặt"
ControlLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
ControlLabel.TextSize = 16
ControlLabel.Font = Enum.Font.GothamBold
ControlLabel.TextXAlignment = Enum.TextXAlignment.Left
ControlLabel.Parent = ControlSection

local HoldTimeLabel = Instance.new("TextLabel")
HoldTimeLabel.Size = UDim2.new(0.5, -15, 0, 30)
HoldTimeLabel.Position = UDim2.new(0, 10, 0, 45)
HoldTimeLabel.BackgroundTransparency = 1
HoldTimeLabel.Text = "⏱️ Hold Time (giây):"
HoldTimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HoldTimeLabel.TextSize = 13
HoldTimeLabel.Font = Enum.Font.Gotham
HoldTimeLabel.TextXAlignment = Enum.TextXAlignment.Left
HoldTimeLabel.Parent = ControlSection

local HoldTimeInput = Instance.new("TextBox")
HoldTimeInput.Name = "HoldTimeInput"
HoldTimeInput.Size = UDim2.new(0.5, -15, 0, 30)
HoldTimeInput.Position = UDim2.new(0.5, 5, 0, 45)
HoldTimeInput.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
HoldTimeInput.Text = tostring(getgenv().HoldTime or 3.5)
HoldTimeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
HoldTimeInput.TextSize = 14
HoldTimeInput.Font = Enum.Font.Gotham
HoldTimeInput.PlaceholderText = "3.5"
HoldTimeInput.Parent = ControlSection

local HoldTimeCorner = Instance.new("UICorner")
HoldTimeCorner.CornerRadius = UDim.new(0, 6)
HoldTimeCorner.Parent = HoldTimeInput

local CheckIntervalLabel = Instance.new("TextLabel")
CheckIntervalLabel.Size = UDim2.new(0.5, -15, 0, 30)
CheckIntervalLabel.Position = UDim2.new(0, 10, 0, 85)
CheckIntervalLabel.BackgroundTransparency = 1
CheckIntervalLabel.Text = "🔄 Check Interval (giây):"
CheckIntervalLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CheckIntervalLabel.TextSize = 13
CheckIntervalLabel.Font = Enum.Font.Gotham
CheckIntervalLabel.TextXAlignment = Enum.TextXAlignment.Left
CheckIntervalLabel.Parent = ControlSection

local CheckIntervalInput = Instance.new("TextBox")
CheckIntervalInput.Name = "CheckIntervalInput"
CheckIntervalInput.Size = UDim2.new(0.5, -15, 0, 30)
CheckIntervalInput.Position = UDim2.new(0.5, 5, 0, 85)
CheckIntervalInput.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
CheckIntervalInput.Text = tostring(getgenv().CheckInterval or 10)
CheckIntervalInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckIntervalInput.TextSize = 14
CheckIntervalInput.Font = Enum.Font.Gotham
CheckIntervalInput.PlaceholderText = "10"
CheckIntervalInput.Parent = ControlSection

local CheckIntervalCorner = Instance.new("UICorner")
CheckIntervalCorner.CornerRadius = UDim.new(0, 6)
CheckIntervalCorner.Parent = CheckIntervalInput

local SaveButton = Instance.new("TextButton")
SaveButton.Name = "SaveButton"
SaveButton.Size = UDim2.new(1, -20, 0, 40)
SaveButton.Position = UDim2.new(0, 10, 0, 145)
SaveButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
SaveButton.Text = "💾 Lưu cài đặt"
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.TextSize = 15
SaveButton.Font = Enum.Font.GothamBold
SaveButton.Parent = ControlSection

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 8)
SaveCorner.Parent = SaveButton

-- 🐾 Pet Config Section
local PetSection = Instance.new("Frame")
PetSection.Name = "PetSection"
PetSection.Size = UDim2.new(1, 0, 0, 120)
PetSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
PetSection.BorderSizePixel = 0
PetSection.Parent = Content

local PetCorner = Instance.new("UICorner")
PetCorner.CornerRadius = UDim.new(0, 10)
PetCorner.Parent = PetSection

local PetLabel = Instance.new("TextLabel")
PetLabel.Size = UDim2.new(1, -20, 0, 25)
PetLabel.Position = UDim2.new(0, 10, 0, 10)
PetLabel.BackgroundTransparency = 1
PetLabel.Text = "🐾 Cấu hình Pet"
PetLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
PetLabel.TextSize = 16
PetLabel.Font = Enum.Font.GothamBold
PetLabel.TextXAlignment = Enum.TextXAlignment.Left
PetLabel.Parent = PetSection

local CurrentPetLabel = Instance.new("TextLabel")
CurrentPetLabel.Name = "CurrentPetLabel"
CurrentPetLabel.Size = UDim2.new(1, -20, 0, 75)
CurrentPetLabel.Position = UDim2.new(0, 10, 0, 40)
CurrentPetLabel.BackgroundTransparency = 1
CurrentPetLabel.Text = "Đang kiểm tra cấu hình..."
CurrentPetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CurrentPetLabel.TextSize = 13
CurrentPetLabel.Font = Enum.Font.Gotham
CurrentPetLabel.TextWrapped = true
CurrentPetLabel.TextXAlignment = Enum.TextXAlignment.Left
CurrentPetLabel.TextYAlignment = Enum.TextYAlignment.Top
CurrentPetLabel.Parent = PetSection

-- 🎬 Action Buttons
local ActionSection = Instance.new("Frame")
ActionSection.Name = "ActionSection"
ActionSection.Size = UDim2.new(1, 0, 0, 100)
ActionSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
ActionSection.BorderSizePixel = 0
ActionSection.Parent = Content

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 10)
ActionCorner.Parent = ActionSection

local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.Size = UDim2.new(1, -20, 0, 40)
StartButton.Position = UDim2.new(0, 10, 0, 10)
StartButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
StartButton.Text = "▶️ Bắt đầu Farm"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.TextSize = 16
StartButton.Font = Enum.Font.GothamBold
StartButton.Parent = ActionSection

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = StartButton

local StopButton = Instance.new("TextButton")
StopButton.Name = "StopButton"
StopButton.Size = UDim2.new(1, -20, 0, 40)
StopButton.Position = UDim2.new(0, 10, 0, 55)
StopButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
StopButton.Text = "⏹️ Dừng Farm"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.TextSize = 16
StopButton.Font = Enum.Font.GothamBold
StopButton.Visible = false
StopButton.Parent = ActionSection

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 8)
StopCorner.Parent = StopButton

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

local function addHoverEffect(button)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), 0.1)}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.fromRGB(0, 0, 0), 0.1)}):Play()
	end)
end

addHoverEffect(CloseButton)
addHoverEffect(SaveButton)
addHoverEffect(StartButton)
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

CloseButton.MouseButton1Click:Connect(function()
	farmingActive = false
	if farmThread then task.cancel(farmThread) end
	if checkThread then task.cancel(checkThread) end
	ScreenGui:Destroy()
end)

SaveButton.MouseButton1Click:Connect(function()
	local holdTime = tonumber(HoldTimeInput.Text)
	local checkInterval = tonumber(CheckIntervalInput.Text)
	
	if holdTime and holdTime > 0 then
		getgenv().HoldTime = holdTime
	end
	
	if checkInterval and checkInterval > 0 then
		getgenv().CheckInterval = checkInterval
	end
	
	SaveButton.Text = "✅ Đã lưu!"
	SaveButton.BackgroundColor3 = Color3.fromRGB(25, 135, 84)
	wait(1.5)
	SaveButton.Text = "💾 Lưu cài đặt"
	SaveButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
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
		CurrentPetLabel.Text = "✅ Vai trò: FARM PET\n🎯 Pet được giao: " .. currentPet .. "\n📍 Sẽ quét các plot khác để thu thập pet"
		CurrentPetLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	else
		CurrentPetLabel.Text = "👀 Vai trò: KIỂM TRA\n⚠️ Account này không trong danh sách farm\n📊 Sẽ kiểm tra plot của bạn và kick khi hết pet"
		CurrentPetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	end
	
	return currentPet
end

local currentPet = updatePetInfo()

StartButton.MouseButton1Click:Connect(function()
	if not farmingActive then
		farmingActive = true
		StartButton.Visible = false
		StopButton.Visible = true
		AccountStatus.Text = "👤 Account: " .. player.Name .. " | 🟢 Đang farm..."
		AccountStatus.TextColor3 = Color3.fromRGB(100, 255, 150)
		
		if currentPet then
			print("[ACC FARM] 🎯", player.Name, "→ gom pet:", currentPet)
			farmThread = task.spawn(function()
				while farmingActive do
					pcall(function()
						ScanAllPlots(currentPet)
					end)
					task.wait(getgenv().CheckInterval or 10)
				end
			end)
		else
			print("[ACC CHECK] 👀", player.Name, "kiểm tra plot riêng.")
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
end)

StopButton.MouseButton1Click:Connect(function()
	farmingActive = false
	StopButton.Visible = false
	StartButton.Visible = true
	AccountStatus.Text = "👤 Account: " .. player.Name .. " | 🔴 Đã dừng"
	AccountStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
	
	if farmThread then
		task.cancel(farmThread)
		farmThread = nil
	end
	
	if checkThread then
		task.cancel(checkThread)
		checkThread = nil
	end
end)

print("✅ Auto Farm GUI loaded successfully!")
print("🎯 Account:", player.Name)
if currentPet then
	print("🐾 Pet assigned:", currentPet)
else
	print("👀 Mode: Plot checker")
end
