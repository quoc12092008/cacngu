-- 🧩 BANANA FARM SYNC SYSTEM (Full Auto - No GUI)
-- 📅 Version: 1.3 | Config: getgenv().AccHold = FARM accounts
-- 🧠 By Chúi Hub

------------------------------------------------------------
-- 🧱 DỊCH VỤ CẦN DÙNG
------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

------------------------------------------------------------
-- 🧰 MODULE & DỮ LIỆU
------------------------------------------------------------
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local player = Players.LocalPlayer
local playerSync = Synchronizer:Get(player)
local plrAnimalPodiums = playerSync:Get("AnimalPodiums")

------------------------------------------------------------
-- 🗃️ CHIA SẺ DỮ LIỆU GIỮA CÁC ACC
------------------------------------------------------------
if not ReplicatedStorage:FindFirstChild("SharedPets") then
	local folder = Instance.new("Folder")
	folder.Name = "SharedPets"
	folder.Parent = ReplicatedStorage
end
local SharedPets = ReplicatedStorage:WaitForChild("SharedPets")

------------------------------------------------------------
-- ⚙️ CẤU HÌNH CHUNG
------------------------------------------------------------
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 2
local AccHold = getgenv().AccHold or {}

-- Danh sách pet hợp lệ
local AllowedPets = {
	"Spooky Lucky Block"
}

------------------------------------------------------------
-- 🧠 NHẬN DIỆN VAI TRÒ
------------------------------------------------------------
local function IsFarmer()
	for _, cfg in ipairs(AccHold) do
		if cfg.AccountName == player.Name then
			return true
		end
	end
	return false
end

local isFarmer = IsFarmer()
local isChecker = not isFarmer

------------------------------------------------------------
-- ⚙️ HÀM DI CHUYỂN & NHẶT PET
------------------------------------------------------------
local function GetMyPlot()
	local Plots = Workspace:FindFirstChild("Plots")
	if not Plots then return nil end
	return Plots:FindFirstChild(player.Name)
end

local function WalkToPosition(targetPos)
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	if not hrp or not humanoid then return false end

	local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
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

local function HoldKeyE(duration)
	local start = tick()
	while tick() - start < duration do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function HandlePet(petName, checkerName)
	local checkerPlot = Workspace.Plots:FindFirstChild(checkerName)
	if not checkerPlot then return end

	local pet = checkerPlot:FindFirstChild(petName)
	if not pet or not pet:FindFirstChild("HumanoidRootPart") then return end

	print("🚶‍♂️", player.Name, "đi đến pet:", petName, "tại", checkerName)
	if WalkToPosition(pet.HumanoidRootPart.Position + Vector3.new(0, 2, 0)) then
		print("⏳ Giữ E...")
		HoldKeyE(HoldTime)
		task.wait(0.5)

		local myPlot = GetMyPlot()
		if myPlot and myPlot:FindFirstChild("Decorations") then
			local home = myPlot.Decorations:GetChildren()[1]
			if home and home:IsA("BasePart") then
				print("🏠", player.Name, "đang quay về nhà...")
				WalkToPosition(home.Position + Vector3.new(0, 2, 0))
			end
		end
	end
end

------------------------------------------------------------
-- 🟡 CHECKER: GỬI DANH SÁCH PET
------------------------------------------------------------
if isChecker then
	print("[CHECKER] ▶️", player.Name, "đang chia sẻ pet...")
	local checkerFolder = SharedPets:FindFirstChild(player.Name) or Instance.new("Folder")
	checkerFolder.Name = player.Name
	checkerFolder.Parent = SharedPets

	task.spawn(function()
		while task.wait(3) do
			if not plrAnimalPodiums then continue end
			for _, obj in ipairs(checkerFolder:GetChildren()) do obj:Destroy() end

			for slot, data in pairs(plrAnimalPodiums) do
				local petName = (data.Animal and data.Animal.Index) or data.Index
				if petName then
					for _, allowed in ipairs(AllowedPets) do
						if string.lower(petName) == string.lower(allowed) then
							local val = Instance.new("StringValue")
							val.Name = tostring(slot)
							val.Value = petName
							val.Parent = checkerFolder
						end
					end
				end
			end
		end
	end)
end

------------------------------------------------------------
-- 🔵 FARMER: TÌM PET & NHẶT
------------------------------------------------------------
if isFarmer then
	print("[FARMER] ▶️", player.Name, "đang tìm pet...")

	local function GetAvailablePet()
		for _, checkerFolder in ipairs(SharedPets:GetChildren()) do
			if checkerFolder.Name ~= player.Name then
				for _, val in ipairs(checkerFolder:GetChildren()) do
					local tag = val:FindFirstChild("TakenBy")
					if not tag or tag.Value == "" then
						local newTag = tag or Instance.new("StringValue")
						newTag.Name = "TakenBy"
						newTag.Value = player.Name
						newTag.Parent = val

						print("🎯", player.Name, "đã claim pet", val.Value, "từ", checkerFolder.Name)
						return {Checker = checkerFolder.Name, PetName = val.Value, Slot = val.Name}
					end
				end
			end
		end
		return nil
	end

	task.spawn(function()
		while task.wait(CheckInterval) do
			local info = GetAvailablePet()
			if info then
				HandlePet(info.PetName, info.Checker)
			end
		end
	end)
end

------------------------------------------------------------
-- ⚪ NẾU KHÔNG NẰM TRONG DANH SÁCH
------------------------------------------------------------
if not isChecker and not isFarmer then
	warn("[❌]", player.Name, "không nằm trong danh sách AccHold hoặc không có dữ liệu.")
end
