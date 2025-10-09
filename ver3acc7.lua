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
-- 🔧 Lấy PlotController và đảm bảo Start() được gọi
---------------------------------------------------------------------
local PlotController = nil
pcall(function()
	local Controllers = ReplicatedStorage:WaitForChild("Controllers", 10)
	local Module = Controllers:WaitForChild("PlotController", 10)
	PlotController = require(Module)
end)

if PlotController and PlotController.Start then
	pcall(function() PlotController:Start() end)
else
	warn("[⚠️] Không load được PlotController, chuyển sang chế độ an toàn.")
	PlotController = { GetMyPlot = function() return nil end }
end

---------------------------------------------------------------------
-- 🔒 Anti trùng pet toàn cục (Lua thuần)
---------------------------------------------------------------------
shared.PetLocks = shared.PetLocks or {}

local function round(n) return math.floor(n + 0.5) end
local function getLockKey(pet)
	local pos = (pet.WorldPivot and pet.WorldPivot.Position)
		or (pet.PrimaryPart and pet.PrimaryPart.Position)
		or Vector3.new()
	return string.format("%s|%d,%d,%d", pet:GetFullName(), round(pos.X), round(pos.Y), round(pos.Z))
end

local LOCK_TTL = 12
local function lockExpired(lock)
	return (tick() - (lock.t or 0)) > LOCK_TTL
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
-- 🎨 UI cơ bản
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
-- 🧭 Hàm phụ
---------------------------------------------------------------------
local function GetMyPlot()
	local myPlot = PlotController.GetMyPlot()
	if myPlot and myPlot.PlotModel then
		return myPlot.PlotModel
	end
	return nil
end

local function getPlotOwnerName(plot)
	local owner = plot:FindFirstChild("Owner")
	if not owner then return nil end
	if owner:IsA("StringValue") then
		return owner.Value
	elseif owner:IsA("ObjectValue") and owner.Value then
		if owner.Value:IsA("Player") then
			return owner.Value.Name
		else
			local plr = Players:GetPlayerFromCharacter(owner.Value)
			return plr and plr.Name or owner.Value.Name
		end
	end
	return nil
end

local function isTeammatePlot(plot)
	local ownerName = getPlotOwnerName(plot)
	if not ownerName then return false end
	for _, acc in ipairs(AccHold) do
		if acc.AccountName == ownerName then return true end
	end
	return false
end

local function GetHomeSpawn(myPlot)
	if not myPlot then return nil end
	local deco = myPlot:FindFirstChild("Decorations")
	if not deco then return nil end
	for _, obj in ipairs(deco:GetDescendants()) do
		if obj:IsA("BasePart") then
			if string.find(string.lower(obj.Name), "spawn") or string.find(string.lower(obj.Name), "home") then
				return obj.Position
			end
		end
	end
	return nil
end

local function WalkToPosition(targetPos)
	local path = PathfindingService:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true, WaypointSpacing=4})
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

---------------------------------------------------------------------
-- 🐾 HandlePet
---------------------------------------------------------------------
local function HandlePet(pet, myPlot)
	local targetPos = pet.WorldPivot and pet.WorldPivot.Position
	if not targetPos then return end

	local lockKey = getLockKey(pet)
	local lock = shared.PetLocks[lockKey]
	if lock and lock.owner ~= player.Name and not lockExpired(lock) then
		print("❌", player.Name, "bỏ qua", pet.Name, "(đã bị", lock.owner, "claim)")
		return
	end

	shared.PetLocks[lockKey] = { owner = player.Name, t = tick() }

	local function unlock()
		local cur = shared.PetLocks[lockKey]
		if cur and cur.owner == player.Name then
			shared.PetLocks[lockKey] = nil
		end
	end

	statusText.Text = "Status : Walking to " .. pet.Name
	local ok = WalkToPosition(targetPos + Vector3.new(0, 2, 0))
	if not ok then unlock() return end

	statusText.Text = "Status : Holding E on " .. pet.Name
	local start = tick()
	while tick() - start < HoldTime do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		local cur = shared.PetLocks[lockKey]
		if cur and cur.owner == player.Name then cur.t = tick() end
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

	unlock()

	local homePos = GetHomeSpawn(myPlot)
	if homePos then
		statusText.Text = "Status : Returning home..."
		WalkToPosition(homePos + Vector3.new(0, 2, 0))
	end
	statusText.Text = "Status : Farming " .. CurrentPet
end

---------------------------------------------------------------------
-- 🔁 Scan plots
---------------------------------------------------------------------
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end
	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			if isTeammatePlot(plot) then goto continuePlot end
			for _, pet in ipairs(plot:GetChildren()) do
				if pet.Name == CurrentPet then
					HandlePet(pet, myPlot)
				end
			end
			::continuePlot::
		end
	end
end

---------------------------------------------------------------------
-- 🚀 Main loop
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

print("✅ Pet Farm Anti-Steal + PlotController Fix loaded!")
