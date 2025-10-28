-- // ========================= Pet Farm (No-Overlap, Checker-Only) =========================
-- // Im lặng console, chỉ in thông báo rất quan trọng (kick, lỗi nặng)
-- // Checker = acc KHÔNG nằm trong AccHold (auto detect)
-- // Farm chỉ lấy pet từ nhà Checker, bỏ qua nhà acc farm khác
-- // Chống trùng pet bằng Attribute Claiming + ClaimStart, janitor tự unlock sau 10s
-- // Giữ nguyên Speed Coil / Camera / về nhà / buy coil

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

-- Controllers
local PlotController = require(ReplicatedStorage.Controllers.PlotController)

-- Cấu hình từ getgenv
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

-- Xác định acc hiện tại
local CurrentPet = nil
local farmMode = "Checker"
for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		farmMode = "Farmer"
		break
	end
end

-- Tạo set tên acc farm để tra nhanh
local FarmNameSet = {}
for _, cfg in ipairs(AccHold) do
	if type(cfg.AccountName) == "string" then
		FarmNameSet[cfg.AccountName] = true
	end
end

local function IsFarmAccount(name)
	return name and FarmNameSet[name] == true
end

local function IsCheckerAccount(name)
	-- Checker = KHÔNG nằm trong AccHold
	return name and not IsFarmAccount(name)
end

-- ⚙️ Speed Coil System
local speedCoilBought = false
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net", 10)
local remotePath = "RF/CoinsShopService/RequestBuy"
local remoteFunction = Net and Net:FindFirstChild(remotePath, true)

local function BuySpeedCoil()
	if speedCoilBought or not remoteFunction then return end
	local args = { [1] = "Speed Coil" }
	local ok, result = pcall(function()
		return remoteFunction:InvokeServer(unpack(args))
	end)
	if ok then
		speedCoilBought = true
	end
end

local function EquipSpeedCoil()
	if not speedCoilBought then return end
	-- Ấn phím số 2 để equip Speed Coil
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
	task.wait(0.1)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
end

-- 🔧 CÁC HÀM FARM CŨ
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
	local t0 = tick()
	while tick() - t0 < duration do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- 🔍 Tìm chủ sở hữu của Plot (cố gắng đa nguồn; nếu không xác định → bỏ qua)
local function GetPlotOwnerName(plot)
	if not plot then return nil end
	-- Thử Attribute string
	local okAttr, ownerAttr = pcall(function() return plot:GetAttribute("Owner") end)
	if okAttr and type(ownerAttr) == "string" and ownerAttr ~= "" then
		return ownerAttr
	end
	local okAttr2, ownerAttr2 = pcall(function() return plot:GetAttribute("OwnerName") end)
	if okAttr2 and type(ownerAttr2) == "string" and ownerAttr2 ~= "" then
		return ownerAttr2
	end
	-- Thử ValueObject
	local ownerValue = plot:FindFirstChild("Owner")
	if ownerValue and ownerValue:IsA("StringValue") and ownerValue.Value ~= "" then
		return ownerValue.Value
	end
	local ownerIdValue = plot:FindFirstChild("OwnerUserId")
	if ownerIdValue and ownerIdValue:IsA("NumberValue") then
		local plr = Players:GetPlayerByUserId(ownerIdValue.Value)
		if plr then return plr.Name end
	end
	-- Thử hàm trong PlotController nếu có
	if PlotController and typeof(PlotController) == "table" then
		if type(PlotController.GetOwnerName) == "function" then
			local ok3, name3 = pcall(function() return PlotController.GetOwnerName(plot) end)
			if ok3 and type(name3) == "string" and name3 ~= "" then
				return name3
			end
		end
		if type(PlotController.GetPlotOwner) == "function" then
			local ok4, plr4 = pcall(function() return PlotController.GetPlotOwner(plot) end)
			if ok4 and typeof(plr4) == "Instance" and plr4:IsA("Player") then
				return plr4.Name
			end
		end
	end
	return nil
end

-- 🧹 Janitor: auto unlock Claim sau 10s (anti kẹt)
local CLAIM_TIMEOUT = 10
task.spawn(function()
	while true do
		local plotsFolder = workspace:FindFirstChild("Plots")
		if plotsFolder then
			for _, plot in ipairs(plotsFolder:GetChildren()) do
				if plot:IsA("Model") then
					for _, pet in ipairs(plot:GetChildren()) do
						if pet and pet:IsA("Model") or pet:IsA("BasePart") then
							local claimer = pet:GetAttribute("Claiming")
							local tStart = pet:GetAttribute("ClaimStart")
							if claimer ~= nil and type(tStart) == "number" then
								if (os.clock() - tStart) > CLAIM_TIMEOUT then
									-- bất kỳ client nào cũng có thể dọn kẹt
									pet:SetAttribute("Claiming", nil)
									pet:SetAttribute("ClaimStart", nil)
								end
							end
						end
					end
				end
			end
		end
		task.wait(5)
	end
end)

-- 🔒 Claim helper (ngăn race condition set đè)
local function TryClaimPet(pet, claimerName)
	if not pet or not claimerName then return false end
	if pet:GetAttribute("Claiming") ~= nil then
		return false
	end
	-- Đặt claim
	pet:SetAttribute("Claiming", claimerName)
	pet:SetAttribute("ClaimStart", os.clock())
	-- Nhường 1 heartbeat để các client khác thấy
	RunService.Heartbeat:Wait()
	-- Xác nhận vẫn là mình (nếu race, có thể bị đè)
	return pet:GetAttribute("Claiming") == claimerName
end

local function ReleasePetClaimIfMine(pet, claimerName)
	if not pet then return end
	if pet:GetAttribute("Claiming") == claimerName then
		pet:SetAttribute("Claiming", nil)
		pet:SetAttribute("ClaimStart", nil)
	end
end

-- 🧠 HandlePet với Claiming
local function HandlePet(pet, myPlot)
	if not pet or not myPlot then return end

	-- Nếu đã có người claim thì bỏ
	if pet:GetAttribute("Claiming") ~= nil then
		return
	end
	-- Cố gắng claim
	if not TryClaimPet(pet, player.Name) then
		return
	end

	-- Từ đây trở đi, chỉ mình xử lý; luôn nhớ giải phóng claim ở cuối
	local ok = false
	local function _cleanup()
		ReleasePetClaimIfMine(pet, player.Name)
	end

	local function _process()
		local targetPos = pet.WorldPivot and pet.WorldPivot.Position
		if not targetPos then return end

		if WalkToPosition(targetPos + Vector3.new(0, 2, 0)) then
			AdjustCameraBehindPlayer(pet)

			-- Tắt speed coil (unequip) khi cầm E
			-- (chỉ cần bỏ equip lại sau khi về nhà)
			HoldKeyEReal(HoldTime)

			local homePos = GetHomeSpawn(myPlot)
			if homePos then
				WalkToPosition(homePos + Vector3.new(0, 2, 0))

				-- Sau khi về nhà: đi podium + mua/equip coil (chỉ lần đầu)
				if not speedCoilBought then
					task.wait(1.2)
					local claimPos = GetAnimalPodiumClaim(myPlot)
					if claimPos and WalkToPosition(claimPos + Vector3.new(0, 2, 0)) then
						task.wait(0.4)
						BuySpeedCoil()
						task.wait(0.6)
						EquipSpeedCoil()
					end
				else
					-- Re-equip coil lại (vì cầm E có thể mất equip)
					task.wait(0.3)
					EquipSpeedCoil()
				end
			end
		end
	end

	ok = pcall(_process)
	_cleanup()
end

-- 🔎 Quét chỉ các plot của CHECKER
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			-- Xác định chủ plot
			local ownerName = GetPlotOwnerName(plot)
			-- Chỉ farm từ nhà CHECKER (acc không nằm trong AccHold)
			if ownerName and IsCheckerAccount(ownerName) then
				-- Quét pet phù hợp
				for _, pet in ipairs(plot:GetChildren()) do
					if pet and pet.Name == CurrentPet then
						-- Bỏ qua nếu pet đang bị người khác claim
						if pet:GetAttribute("Claiming") == nil then
							HandlePet(pet, myPlot)
						end
					end
				end
			else
				-- Bỏ qua nhà không xác định/ không phải checker / là farm khác
				-- (im lặng theo yêu cầu)
			end
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

-- 🚀 KHỞI ĐỘNG
if CurrentPet and farmMode == "Farmer" then
	-- Vòng farm (im lặng)
	task.spawn(function()
		while true do
			pcall(ScanAllPlots)
			task.wait(CheckInterval)
		end
	end)
else
	-- Checker mode: chỉ tự kiểm tra plot mình, hết pet thì kick
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

-- Thông báo ngắn (có thể xoá nếu muốn im tuyệt đối)
print("✅ Pet Farm Script loaded (No-Overlap, Checker-Only, Auto-Unlock 10s)")
-- // ========================= END =========================
