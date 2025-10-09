-- Multi-account auto farm (đã chỉnh để nhận cả pet có Attributes)
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

-- Cấu hình ngoài
local AccHold = getgenv().AccHold or {}
local HoldTime = getgenv().HoldTime or 3.5
local CheckInterval = getgenv().CheckInterval or 10

-- Tìm pet được gán cho acc hiện tại
local CurrentPet = nil
for _, cfg in ipairs(AccHold) do
	if cfg.AccountName == player.Name then
		CurrentPet = cfg.Pet
		break
	end
end

---------------------------------------------------------------------
-- Utility: Lấy plot của chính bạn
---------------------------------------------------------------------
local function GetMyPlot()
	local myPlot = PlotController.GetMyPlot()
	if myPlot and myPlot.PlotModel then
		return myPlot.PlotModel
	end
	return nil
end

---------------------------------------------------------------------
-- Utility: Lấy vị trí spawn (Decorations[12])
---------------------------------------------------------------------
local function GetHomeSpawn(myPlot)
	if not myPlot then return nil end
	local deco = myPlot:FindFirstChild("Decorations")
	if not deco then return nil end
	local children = deco:GetChildren()
	if #children >= 12 then
		local spawnPart = children[12]
		if spawnPart and spawnPart.CFrame then
			return spawnPart.CFrame.Position
		end
	end
	return nil
end

---------------------------------------------------------------------
-- Utility: Lấy vị trí của pet một cách bền vững
---------------------------------------------------------------------
local function GetPetPosition(pet)
	-- Nếu model có WorldPivot (Roblox mới)
	if pet.WorldPivot and pet.WorldPivot.Position then
		return pet.WorldPivot.Position
	end
	-- Nếu model có PrimaryPart
	if pet:IsA("Model") and pet.PrimaryPart and pet.PrimaryPart.Position then
		return pet.PrimaryPart.Position
	end
	-- Tìm part đầu tiên có Position
	for _, c in ipairs(pet:GetDescendants()) do
		if c:IsA("BasePart") and c.Position then
			return c.Position
		end
	end
	return nil
end

---------------------------------------------------------------------
-- Utility: Kiểm tra pet có trùng tên mục tiêu (và không bị bỏ qua vì có Attributes)
-- Nếu cần, có thể mở rộng để match fuzzy / alias
---------------------------------------------------------------------
local function IsMatchingPet(pet, targetName)
	if not pet or not targetName then return false end
	-- So sánh tên trực tiếp
	if pet.Name == targetName then return true end
	-- Một số pets có tên lưu trong Attributes? kiểm tra thêm (nếu dev dùng attribute khác)
	local attrName = pet:GetAttribute("Name") or pet:GetAttribute("PetName")
	if attrName and attrName == targetName then return true end
	-- Nếu pet có Mutation/YinYangPalette nhưng tên vẫn đối chiếu được -> vẫn chấp nhận
	if pet:GetAttribute("Mutation") or pet:GetAttribute("YinYangPalette") then
		-- nhiều cấu trúc vẫn để pet.Name là tên con pet, nên kiểm tra lại pet.Name
		if pet.Name == targetName then return true end
		-- (fallback) nếu PrimaryPart chứa tên trong Tag/Attribute khác có thể mở rộng ở đây
	end
	return false
end

---------------------------------------------------------------------
-- Di chuyển bằng Pathfinding (giữ như cũ)
---------------------------------------------------------------------
local function WalkToPosition(targetPos)
	if not targetPos then return false end
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
		if wp.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end
		humanoid:MoveTo(wp.Position)
		local reached = humanoid.MoveToFinished:Wait()
		if not reached then return false end
	end
	return true
end

---------------------------------------------------------------------
-- Camera phía sau nhân vật
---------------------------------------------------------------------
local function AdjustCameraBehindPlayer(pet)
	local cam = Workspace.CurrentCamera
	if not cam or not pet then return end

	local petPos = GetPetPosition(pet)
	if not petPos then return end

	local direction = (petPos - hrp.Position).Unit
	local behindOffset = -direction * 5 + Vector3.new(0, 3, 0)
	local camPos = hrp.Position + behindOffset

	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0, 2, 0))

	task.delay(4, function()
		pcall(function()
			cam.CameraType = Enum.CameraType.Custom
		end)
	end)
end

---------------------------------------------------------------------
-- Giữ phím E thật
---------------------------------------------------------------------
local function HoldKeyEReal(duration)
	local start = tick()
	while tick() - start < duration do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		RunService.Heartbeat:Wait()
	end
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

---------------------------------------------------------------------
-- Xử lý 1 con pet
---------------------------------------------------------------------
local function HandlePet(pet, myPlot)
	local pos = GetPetPosition(pet)
	if not pos then return end

	-- đi đến pet (đi hơi trước một chút để tránh dính vô model)
	if WalkToPosition(pos + Vector3.new(0, 2, 0)) then
		AdjustCameraBehindPlayer(pet)
		HoldKeyEReal(HoldTime)

		-- quay về home spawn nếu có
		local homePos = GetHomeSpawn(myPlot)
		if homePos then
			WalkToPosition(homePos + Vector3.new(0, 2, 0))
		end
	end
end

---------------------------------------------------------------------
-- Quét plots khác (không bỏ qua pet có Attributes)
---------------------------------------------------------------------
local function ScanAllPlots()
	local myPlot = GetMyPlot()
	if not myPlot then return end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") and plot ~= myPlot then
			for _, child in ipairs(plot:GetChildren()) do
				-- child có thể là model pet hoặc part
				if IsMatchingPet(child, CurrentPet) then
					pcall(function()
						HandlePet(child, myPlot)
					end)
				end
			end
		end
	end
end

---------------------------------------------------------------------
-- Check nếu hết pet trong plot của mình (bây giờ cũng kiểm tra pet có attributes)
---------------------------------------------------------------------
local function CheckMyPlotEmpty()
	local myPlot = GetMyPlot()
	if not myPlot then return true end

	for _, child in ipairs(myPlot:GetChildren()) do
		for _, cfg in ipairs(AccHold) do
			if IsMatchingPet(child, cfg.Pet) then
				return false
			end
		end
	end
	return true
end

---------------------------------------------------------------------
-- Phân vai acc / chạy chính
---------------------------------------------------------------------
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
	print("[ACC CHECK] 👀", player.Name, "không trong danh sách farm, kiểm tra plot riêng.")
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
