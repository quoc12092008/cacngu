-- ✅ Script: Multi-account auto farm v7 (Chúi Hub)
-- ✨ Không trùng pet, không xâm nhà acc farm, auto nhảy khi bị kẹt
-- 📅 Version: 7.0

------------------------------------------------------------
-- 🧱 DỊCH VỤ CẦN DÙNG
------------------------------------------------------------
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

local PlotController = require(ReplicatedStorage.Controllers.PlotController)

------------------------------------------------------------
-- ⚙️ CẤU HÌNH NGOÀI
------------------------------------------------------------
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

-- Danh sách acc farm để tránh xâm nhà nhau
local FarmerNames = {}
for _, cfg in ipairs(AccHold) do
	table.insert(FarmerNames, cfg.AccountName)
end

-- Xác định acc hiện tại có nằm trong danh sách farm hay không
local CurrentPet = nil
for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		break
	end
end

------------------------------------------------------------
-- 🗂️ VÙNG CHIA SẺ PET ĐÃ ĐƯỢC CLAIM (ĐỂ TRÁNH TRÙNG)
------------------------------------------------------------
if not ReplicatedStorage:FindFirstChild("ClaimedPets") then
	local folder = Instance.new("Folder")
	folder.Name = "ClaimedPets"
	folder.Parent = ReplicatedStorage
end
local ClaimedPets = ReplicatedStorage:WaitForChild("ClaimedPets")

local function IsPetFree(checker, petName)
	local key = checker .. "_" .. petName
	return not ClaimedPets:FindFirstChild(key)
end

local function MarkPetTaken(checker, petName, taker)
	local val = Instance.new("StringValue")
	val.Name = checker .. "_" .. petName
	val.Value = taker
	val.Parent = ClaimedPets
end

local function UnmarkPet(checker, petName)
	local key = checker .. "_" .. petName
	local old = ClaimedPets:FindFirstChild(key)
	if old then old:Destroy() end
end

------------------------------------------------------------
-- 🏡 HÀM LẤY PLOT & VỊ TRÍ
------------------------------------------------------------
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

------------------------------------------------------------
-- 🚶‍♂️ PATHFIND + AUTO NHẢY NẾU BỊ KẸT
------------------------------------------------------------
local function IsStuck(lastPos)
	local now = hrp.Position
	return (now - lastPos).Magnitude < 0.2
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
		warn("[Pathfind] ❌ Không thể tính đường đến:", targetPos)
		return false
	end

	for _, wp in ipairs(path:GetWaypoints()) do
		local startPos = hrp.Position
		humanoid:MoveTo(wp.Position)
		local moveStart = tick()

		while task.wait(0.15) do
			local dist = (hrp.Position - wp.Position).Magnitude
			if dist < 2 then break end
			if tick() - moveStart > 5 then break end

			-- Nếu bị kẹt → spam Space
			if IsStuck(startPos) then
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
				task.wait(0.05)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
			end
			startPos = hrp.Position
		end
	end
	return true
end

------------------------------------------------------------
-- ⌨️ GIỮ PHÍM E
------------------------------------------------------------
local function HoldKeyEReal(duration)
	local start = tick()
	while tick() - start < duration do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

------------------------------------------------------------
-- 🧭 XỬ LÝ PET
------------------------------------------------------------
local function HandlePet(pet, myPlot, owner)
	local targetPos = pet.WorldPivot and pet.WorldPivot.Position
	if not targetPos then return end

	print("🚶‍♂️", player.Name, "đến pet:", pet.Name, "tại nhà", owner)
	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		print("⏳ Giữ phím E để nhặt...")
		HoldKeyEReal(HoldTime)

		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			print("🏠 Quay về nhà...")
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
		end
	end
end

------------------------------------------------------------
-- 🔍 QUÉT CÁC NHÀ KHÁC ĐỂ TÌM PET
------------------------------------------------------------
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			-- Không farm trong nhà acc farm khác
			if not table.find(FarmerNames, plot.Name) then
				for _, pet in ipairs(plot:GetChildren()) do
					if pet.Name == CurrentPet and IsPetFree(plot.Name, pet.Name) then
						MarkPetTaken(plot.Name, pet.Name, player.Name)
						HandlePet(pet, myPlot, plot.Name)
						UnmarkPet(plot.Name, pet.Name)
					end
				end
			end
		end
	end
end

------------------------------------------------------------
-- 🧩 KIỂM TRA HẾT PET
------------------------------------------------------------
local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then return true end

	for _, pet in ipairs(myPlot:GetChildren()) do
		for _, cfg in ipairs(AccHold) do
			if pet.Name == cfg.Pet then 
				return false
			end
		end
	end
	return true
end

------------------------------------------------------------
-- ♻️ PHÂN VAI & KHỞI CHẠY
------------------------------------------------------------
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
	print("[ACC CHECK] 👀", player.Name, "là Checker (theo dõi pet trong nhà).")
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
