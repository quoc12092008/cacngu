--[[ =========================
       Pet Farm v8 (Final)
   - Luân phiên farm 1-2-1-2...
   - Pet cuối (số lẻ) random deterministically cho 1 farm
   - Farm chỉ ăn từ CHECKER, không ăn của farm khác
   - Lock tránh tranh chấp
========================= ]]--

-- Services
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

-- Lấy PlotController
local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- Cấu hình từ getgenv
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

print("[📝] Farm Accounts Config:")
for i, cfg in ipairs(AccHold) do
	print(("  %d. %s (Pet: %s)"):format(i, tostring(cfg.AccountName), tostring(cfg.Pet)))
end

-- Xác định acc hiện tại
local CurrentPet = nil
local farmMode = "Checker"
local IsChecker = true
local MyFarmIndex = 0
local FarmCount = #AccHold

for idx, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		farmMode = "Farmer"
		IsChecker = false
		MyFarmIndex = idx
		break
	end
end

print("[INFO] Account:", player.Name, "| Mode:", farmMode, "| IsChecker:", IsChecker, "| CurrentPet:", CurrentPet, "| MyFarmIndex:", MyFarmIndex, "| FarmCount:", FarmCount)

-- ⚙️ Speed Coil System
local speedCoilActive = false
local speedCoilBought = false
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net", 10)
local remotePath = "RF/CoinsShopService/RequestBuy"
local remoteFunction = Net and Net:FindFirstChild(remotePath, true)

local function BuySpeedCoil()
	if speedCoilBought or not remoteFunction then return end
	local args = { [1] = "Speed Coil" }
	local ok, res = pcall(function()
		return remoteFunction:InvokeServer(unpack(args))
	end)
	if ok then
		speedCoilBought = true
		print("[✅] Mua Speed Coil thành công:", res)
	else
		warn("[❌] Lỗi khi mua Speed Coil:", res)
	end
end

local function EquipSpeedCoil()
	if not speedCoilBought then return end
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
	task.wait(0.1)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
	speedCoilActive = true
	print("[⚡] Speed Coil equipped!")
end

---------------------------------------------------------------------
-- 🔧 HELPER FUNCTIONS
---------------------------------------------------------------------

local function IsFarmAccount(accName)
	for _, cfg in ipairs(AccHold) do
		if cfg.AccountName == accName then
			return true
		end
	end
	return false
end

-- Acc KHÔNG có trong AccHold → CHECKER
local function IsCheckerAccount(accName)
	return not IsFarmAccount(accName)
end

-- Lấy owner của plot
local function GetPlotOwner(plot)
	if not plot then return nil end
	local ownerAttr = plot:GetAttribute("Owner")
	if ownerAttr then
		return ownerAttr
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plot:FindFirstChild("OwnerId") then
			if plot.OwnerId.Value == plr.UserId then
				return plr.Name
			end
		elseif string.find(plot.Name, plr.Name) then
			return plr.Name
		end
	end
	return "Checker"
end

-- Lock state
local LOCK_ATTR = "Claiming"

local function IsPetLocked(pet)
	local by = pet:GetAttribute(LOCK_ATTR)
	if by ~= nil and by ~= "" then return true, by end
	return false, nil
end

local function TryLockPet(pet)
	-- Double-check lock (không atomic, nhưng giảm xung đột)
	local isLocked = pet:GetAttribute(LOCK_ATTR)
	if isLocked and isLocked ~= "" then return false end
	pet:SetAttribute(LOCK_ATTR, player.Name)
	task.wait() -- yield 1 frame
	local recheck = pet:GetAttribute(LOCK_ATTR)
	return recheck == player.Name
end

local function UnlockPet(pet)
	pet:SetAttribute(LOCK_ATTR, nil)
end

-- Stable ID cho pet (dùng để "random" deterministic)
local function StablePetId(pet)
	-- Ưu tiên UUID/Id nếu game có
	local idAttr = pet:GetAttribute("UUID") or pet:GetAttribute("Id") or pet:GetAttribute("GUID")
	if idAttr then return tostring(idAttr) end
	-- Fallback: dùng đường dẫn + DebugId
	local name = pet:GetFullName()
	local dbg = ""
	pcall(function() dbg = pet:GetDebugId() end)
	return (name .. "|" .. dbg)
end

-- Hash djb2 để deterministic
local function djb2_hash(str)
	local hash = 5381
	for i = 1, #str do
		hash = ((hash * 33) ~ string.byte(str, i)) & 0x7fffffff
	end
	return hash
end

-- Sắp xếp pet theo vị trí để thứ tự ổn định giữa các client
local function PetSortKey(p)
	local pos = nil
	pcall(function()
		pos = (p.WorldPivot and p.WorldPivot.Position) or p.Position or p:GetPivot().Position
	end)
	if pos then
		return ("%08.3f|%08.3f|%08.3f|%s"):format(pos.X, pos.Y, pos.Z, p.Name)
	else
		return "ZZZ|" .. p.Name
	end
end

---------------------------------------------------------------------
-- 🔧 CÁC HÀM FARM
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

local function GetAnimalPodiumClaim(myPlot)
	if not myPlot then return nil end
	local animalPodiums = myPlot:FindFirstChild("AnimalPodiums")
	if not animalPodiums then return nil end
	local podium1 = animalPodiums:FindFirstChild("1")
	if not podium1 then return nil end
	local claim = podium1:FindFirstChild("Claim")
	if not claim then return nil end
	local main = claim:FindFirstChild("Main")
	if main and main.CFrame then
		return main.CFrame.Position
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
	local petPos = nil
	pcall(function()
		petPos = (pet.WorldPivot and pet.WorldPivot.Position) or pet.Position or pet:GetPivot().Position
	end)
	if not petPos then return end
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

local function HandlePet(pet, myPlot)
	-- Lock try
	if not TryLockPet(pet) then
		print("[⏭️] Lock fail (someone else claimed):", pet.Name)
		return
	end

	local targetPos = nil
	pcall(function()
		targetPos = (pet.WorldPivot and pet.WorldPivot.Position) or pet.Position or pet:GetPivot().Position
	end)
	if not targetPos then
		UnlockPet(pet)
		return
	end

	print("[🚶] Walking to", pet.Name)
	if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
		AdjustCameraBehindPlayer(pet)
		print("[⏱️] Holding E on", pet.Name)
		HoldTime = tonumber(HoldTime) or 3.5
		HoldKeyEReal(HoldTime)

		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			print("[🏠] Returning home...")
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
			if not speedCoilBought then
				task.wait(1.0)
				local claimPos = GetAnimalPodiumClaim(myPlot)
				if claimPos then
					print("[🎁] Going to Podium...")
					if WalkToPosition(claimPos + Vector3.new(0, 2, 0)) then
						task.wait(0.3)
						BuySpeedCoil()
						task.wait(0.5)
						EquipSpeedCoil()
					end
				end
			else
				task.wait(0.3)
				EquipSpeedCoil()
			end
		end
	end

	UnlockPet(pet)
end

---------------------------------------------------------------------
-- 🎯 PHÂN CÔNG PET: Round-Robin + Remainder deterministic-random
---------------------------------------------------------------------
local function BuildAssignedPetsForFarm(petsListSorted, myFarmIndex, farmCount)
	-- petsListSorted: danh sách pet (đã unlock) trên 1 plot CHECKER, đã sort ổn định
	-- Trả về: pet được gán cho farm này (1 con hoặc nil)
	if farmCount <= 0 then return nil end
	if myFarmIndex <= 0 then return nil end

	local total = #petsListSorted
	if total == 0 then return nil end

	-- Số pet chia đều giữa farm
	local fullBlock = total - (total % farmCount) -- phần chia đều
	local remainder = total - fullBlock           -- phần dư

	-- 1) Phần chia đều: pet i thuộc farm ((i - 1) % farmCount) + 1
	for i = 1, fullBlock do
		local assignedFarm = ((i - 1) % farmCount) + 1
		if assignedFarm == myFarmIndex then
			return petsListSorted[i]
		end
	end

	-- 2) Phần dư: mỗi pet còn lại gán "random" deterministic cho 1 farm
	--    => dùng hash(StablePetId) % farmCount + 1 để chọn farm, đảm bảo mọi client đều tính ra giống nhau.
	for i = fullBlock + 1, total do
		local pet = petsListSorted[i]
		local sid = StablePetId(pet)
		local h = djb2_hash(sid)
		local assignedFarm = (h % farmCount) + 1
		if assignedFarm == myFarmIndex then
			return pet
		end
	end

	return nil
end

---------------------------------------------------------------------
-- 🔍 SCAN LOGIC
---------------------------------------------------------------------
local function ScanAllPlots()
	if IsChecker then return end  -- Farm only

	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			local plotOwner = GetPlotOwner(plot)

			-- FARM chỉ ăn từ CHECKER (acc KHÔNG thuộc AccHold)
			if not IsCheckerAccount(plotOwner) then
				-- plot thuộc farm khác → bỏ
				continue
			end

			-- Gom các pet hợp lệ (đúng tên, chưa lock)
			local candidates = {}
			for _, pet in ipairs(plot:GetChildren()) do
				if pet.Name == CurrentPet then
					local locked, by = IsPetLocked(pet)
					if not locked then
						table.insert(candidates, pet)
					else
						-- print("[⏭️] Pet", pet.Name, "đang bị", by, "claim → skip")
					end
				end
			end

			-- Sort ổn định để round-robin cùng thứ tự giữa 2 farm
			table.sort(candidates, function(a,b)
				return PetSortKey(a) < PetSortKey(b)
			end)

			-- Chọn pet theo round-robin + remainder deterministic
			local targetPet = BuildAssignedPetsForFarm(candidates, MyFarmIndex, FarmCount)
			if targetPet then
				print(("[🎯] %s (Farm#%d) được gán 1 pet từ plot của %s"):format(player.Name, MyFarmIndex, tostring(plotOwner)))
				HandlePet(targetPet, myPlot)
				return -- ăn xong 1 con → thoát, chờ vòng sau
			end
			-- Nếu nil: nghĩa là lượt này không có con nào thuộc farm mình ở plot này → tiếp tục plot kế
		end
	end
end

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

---------------------------------------------------------------------
-- 🚀 KHỞI ĐỘNG
---------------------------------------------------------------------
if not IsChecker then
	print("[ACC FARM] 🎯", player.Name, "→ gom pet:", CurrentPet)
	task.spawn(function()
		while true do
			pcall(ScanAllPlots)
			task.wait(CheckInterval)
		end
	end)
else
	print("[ACC CHECK] 👀", player.Name, "là CHECKER - chỉ check plot riêng")
	task.spawn(function()
		while true do
			pcall(function()
				if CheckMyPlotEmpty() then
					player:Kick("Hết pet rồi.")
				end
			end)
			task.wait(5)
		end
	end)
end

print("✅ Pet Farm v8 loaded (Round-Robin + Deterministic Remainder)")
