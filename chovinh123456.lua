-- ✅ Script: Multi-account auto farm v10 (Chúi Hub)
-- 📦 Di chuyển thông minh, kiểm tra vị trí liên tục, nhặt chính xác
-- 📅 Version: 10.0

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

local FarmerNames = {}
for _, cfg in ipairs(AccHold) do table.insert(FarmerNames, cfg.AccountName) end

local CurrentPet = nil
for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		break
	end
end

------------------------------------------------------------
-- 🗂️ SHARED CLAIMED PETS
------------------------------------------------------------
if not ReplicatedStorage:FindFirstChild("ClaimedPets") then
	local f = Instance.new("Folder")
	f.Name = "ClaimedPets"
	f.Parent = ReplicatedStorage
end
local ClaimedPets = ReplicatedStorage:WaitForChild("ClaimedPets")

local function IsPetFree(owner, petName)
	local key = owner .. "_" .. petName
	return not ClaimedPets:FindFirstChild(key)
end

local function MarkPetTaken(owner, petName)
	local key = owner .. "_" .. petName
	if ClaimedPets:FindFirstChild(key) then return false end
	local v = Instance.new("StringValue")
	v.Name = key
	v.Value = player.Name
	v.Parent = ClaimedPets
	return true
end

local function UnmarkPet(owner, petName)
	local key = owner .. "_" .. petName
	local v = ClaimedPets:FindFirstChild(key)
	if v then v:Destroy() end
end

------------------------------------------------------------
-- 🏡 GET MY PLOT
------------------------------------------------------------
local function GetMyPlot()
	local myPlot = PlotController.GetMyPlot()
	return myPlot and myPlot.PlotModel or nil
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
-- 🚶‍♂️ SMART PATHFINDING (TỰ CHỈNH ĐƯỜNG LIÊN TỤC)
------------------------------------------------------------
local function WalkToPosition(targetPos)
	local success = false
	for _ = 1, 3 do
		local path = PathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanJump = true,
			WaypointSpacing = 3
		})
		path:ComputeAsync(hrp.Position, targetPos)
		if path.Status ~= Enum.PathStatus.Success then
			task.wait(0.3)
			continue
		end

		for _, wp in ipairs(path:GetWaypoints()) do
			if math.abs(wp.Position.Y - hrp.Position.Y) > 1.5 then
				humanoid.Jump = true
			end
			humanoid:MoveTo(wp.Position)
			local reached = humanoid.MoveToFinished:Wait()
			if not reached then break end

			-- nếu đi lệch xa mục tiêu >5 stud thì tính lại đường
			if (hrp.Position - targetPos).Magnitude > 5 then
				break
			end
		end
		success = true
		break
	end
	return success
end

------------------------------------------------------------
-- 🔍 TÌM PROMPT “E”
------------------------------------------------------------
local function FindPrompt(pet)
	if not pet then return nil end
	for _, d in ipairs(pet:GetDescendants()) do
		if d:IsA("ProximityPrompt") and d.Enabled then
			return d
		end
	end
	return nil
end

------------------------------------------------------------
-- ⌨️ GIỮ PHÍM E (CHỜ PROMPT THẬT)
------------------------------------------------------------
local function HoldUntilPickup(pet)
	for _ = 1, 3 do -- thử 3 lần
		local prompt = FindPrompt(pet)
		if prompt then
			print("✅ Thấy nút E, bắt đầu nhặt...")
			local start = tick()
			while tick() - start < HoldTime and prompt.Enabled do
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
				RunService.Heartbeat:Wait()
			end
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
			task.wait(0.2)
			if not FindPrompt(pet) then
				print("🎯 Đã nhặt xong pet", pet.Name)
				return true
			end
		else
			print("🔎 Chưa thấy E, tiến gần hơn...")
			WalkToPosition(pet.WorldPivot.Position + Vector3.new(0, 1, 0))
		end
	end
	return false
end

------------------------------------------------------------
-- 🧭 HANDLE PET
------------------------------------------------------------
local function HandlePet(pet, myPlot, owner)
	if not pet then return end
	local targetPos = pet.WorldPivot and pet.WorldPivot.Position or pet.Position
	if not targetPos then return end

	print("🚶‍♂️", player.Name, "đến pet:", pet.Name, "tại nhà", owner)
	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		local got = HoldUntilPickup(pet)
		if got then
			local homePos = GetHomeSpawn(myPlot)
			if homePos then
				print("🏠 Quay về nhà...")
				WalkToPosition(homePos + Vector3.new(0, 2, 0))
			end
		else
			print("❌ Không nhặt được pet", pet.Name)
		end
	end
end

------------------------------------------------------------
-- 🔄 QUÉT PLOTS KHÁC
------------------------------------------------------------
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			if not table.find(FarmerNames, plot.Name) then
				for _, pet in ipairs(plot:GetChildren()) do
					if pet.Name == CurrentPet and IsPetFree(plot.Name, pet.Name) then
						if MarkPetTaken(plot.Name, pet.Name) then
							print("🎯", player.Name, "đã claim pet:", pet.Name, "từ nhà", plot.Name)
							HandlePet(pet, myPlot, plot.Name)
							UnmarkPet(plot.Name, pet.Name)
							return
						end
					end
				end
			end
		end
	end
end

------------------------------------------------------------
-- 🧩 CHECK HẾT PET
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
			pcall(ScanAllPlots)
			task.wait(CheckInterval)
		end
	end)
else
	print("[ACC CHECK] 👀", player.Name, "là Checker.")
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
