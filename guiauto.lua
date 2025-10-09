-- ✅ Multi-account Auto Farm (Optimized + GUI + Structured Logs)
-- Yêu cầu: executor hỗ trợ VirtualInputManager & setfpscap (tùy chọn)

-- =========[ USER CONFIG qua getgenv() ]=========
getgenv().AccHold       = getgenv().AccHold or {
    -- { AccountName = "YourNameHere", Pet = "Taco Lucky Block" },
}
getgenv().HoldTime      = getgenv().HoldTime or 3.5     -- thời gian giữ phím E
getgenv().CheckInterval = getgenv().CheckInterval or 10 -- giây giữa mỗi lần quét
getgenv().ShowUI        = (getgenv().ShowUI ~= false)   -- mặc định bật UI
getgenv().MaxWalkTime   = getgenv().MaxWalkTime or 10   -- timeout MoveTo 1 waypoint
getgenv().RepathDist    = getgenv().RepathDist or 12    -- re-path nếu lệch quá N studs
getgenv().SafeHeight    = getgenv().SafeHeight or 2     -- offset Y khi đến mục tiêu
getgenv().KickOnEmpty   = (getgenv().KickOnEmpty ~= false)

-- =========[ SERVICES & SHORTCUTS ]=========
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- FPS cap (nếu có)
pcall(function() if setfpscap then setfpscap(7) end end)

-- =========[ SAFETY: CHỜ NHÂN VẬT ]=========
local function waitForCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, humanoid, hrp
end

local character, humanoid, hrp = waitForCharacter()

-- =========[ PLOT CONTROLLER ]=========
local PlotController
do
    local ok, mod = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("PlotController"))
    end)
    if ok then PlotController = mod end
end

-- =========[ LOGGER + GUI ]=========
local UI = { Enabled = getgenv().ShowUI, LogMax = 200, Log = {}, Success = 0, Fail = 0 }
local ScreenGui, StatusLabel, DetailLabel, ProgressBar, ProgressFill, LogFrame, LogList, FpsLabel

local function pushLog(level, msg)
    local t = os.date("%H:%M:%S")
    local line = string.format("[%s] [%s] %s", t, level, msg)
    print(line)
    table.insert(UI.Log, line)
    if #UI.Log > UI.LogMax then
        table.remove(UI.Log, 1)
    end
    if LogList and UI.Enabled then
        local item = Instance.new("TextLabel")
        item.BackgroundTransparency = 1
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.TextYAlignment = Enum.TextYAlignment.Center
        item.Font = Enum.Font.Code
        item.TextSize = 14
        item.TextWrapped = false
        item.RichText = false
        item.Size = UDim2.new(1, -6, 0, 18)
        item.Text = line
        item.TextColor3 =
            level == "ERROR" and Color3.fromRGB(255, 95, 95)
            or level == "WARN" and Color3.fromRGB(255, 190, 90)
            or Color3.fromRGB(210, 210, 210)
        item.Parent = LogList
        -- giữ list gọn
        if #LogList:GetChildren() > UI.LogMax then
            LogList:GetChildren()[1]:Destroy()
        end
    end
end
local function info(msg)  pushLog("INFO", msg)  end
local function warn(msg)  pushLog("WARN", msg)  end
local function err(msg)   pushLog("ERROR", msg) end

-- GUI builder
local function buildUI()
    if not UI.Enabled then return end
    pcall(function()
        if ScreenGui then ScreenGui:Destroy() end
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "FarmMonitorUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.IgnoreGuiInset = false
        ScreenGui.Parent = CoreGui

        -- Container
        local main = Instance.new("Frame")
        main.Name = "Main"
        main.Parent = ScreenGui
        main.BackgroundColor3 = Color3.fromRGB(19, 19, 23)
        main.BackgroundTransparency = 0.05
        main.BorderSizePixel = 0
        main.Position = UDim2.new(0, 20, 0, 120)
        main.Size = UDim2.new(0, 380, 0, 320)
        main.ClipsDescendants = true

        local corner = Instance.new("UICorner", main) corner.CornerRadius = UDim.new(0, 12)
        local stroke = Instance.new("UIStroke", main) stroke.Thickness = 1 stroke.Color = Color3.fromRGB(60,60,70)
        local padding = Instance.new("UIPadding", main) padding.PaddingTop = UDim.new(0, 10) padding.PaddingLeft = UDim.new(0, 10) padding.PaddingRight = UDim.new(0, 10)

        -- Header
        local header = Instance.new("TextLabel")
        header.Parent = main
        header.BackgroundTransparency = 1
        header.Font = Enum.Font.GothamBold
        header.TextSize = 18
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.TextColor3 = Color3.fromRGB(230,230,235)
        header.Position = UDim2.new(0, 0, 0, 0)
        header.Size = UDim2.new(1, -20, 0, 24)
        header.Text = "Auto Farm Monitor"

        -- Status
        StatusLabel = Instance.new("TextLabel")
        StatusLabel.Parent = main
        StatusLabel.BackgroundTransparency = 1
        StatusLabel.Font = Enum.Font.Gotham
        StatusLabel.TextSize = 14
        StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        StatusLabel.TextColor3 = Color3.fromRGB(210,210,210)
        StatusLabel.Position = UDim2.new(0, 0, 0, 28)
        StatusLabel.Size = UDim2.new(1, -20, 0, 20)
        StatusLabel.Text = "Status: Initializing..."

        -- Detail
        DetailLabel = Instance.new("TextLabel")
        DetailLabel.Parent = main
        DetailLabel.BackgroundTransparency = 1
        DetailLabel.Font = Enum.Font.Gotham
        DetailLabel.TextSize = 13
        DetailLabel.TextXAlignment = Enum.TextXAlignment.Left
        DetailLabel.TextYAlignment = Enum.TextYAlignment.Top
        DetailLabel.TextWrapped = true
        DetailLabel.TextColor3 = Color3.fromRGB(180,180,190)
        DetailLabel.Position = UDim2.new(0, 0, 0, 50)
        DetailLabel.Size = UDim2.new(1, -20, 0, 56)
        DetailLabel.Text = "-"

        -- Progress
        ProgressBar = Instance.new("Frame")
        ProgressBar.Parent = main
        ProgressBar.Position = UDim2.new(0, 0, 0, 110)
        ProgressBar.Size = UDim2.new(1, -20, 0, 10)
        ProgressBar.BackgroundColor3 = Color3.fromRGB(28,28,34)
        ProgressBar.BorderSizePixel = 0
        local pbCorner = Instance.new("UICorner", ProgressBar) pbCorner.CornerRadius = UDim.new(0, 6)

        ProgressFill = Instance.new("Frame")
        ProgressFill.Parent = ProgressBar
        ProgressFill.Size = UDim2.new(0, 0, 1, 0)
        ProgressFill.BackgroundColor3 = Color3.fromRGB(120,190,255)
        ProgressFill.BorderSizePixel = 0
        local pfCorner = Instance.new("UICorner", ProgressFill) pfCorner.CornerRadius = UDim.new(0, 6)

        -- FPS label
        FpsLabel = Instance.new("TextLabel")
        FpsLabel.Parent = main
        FpsLabel.BackgroundTransparency = 1
        FpsLabel.Font = Enum.Font.Gotham
        FpsLabel.TextSize = 12
        FpsLabel.TextXAlignment = Enum.TextXAlignment.Right
        FpsLabel.TextColor3 = Color3.fromRGB(160,160,170)
        FpsLabel.Position = UDim2.new(0, 0, 0, 92)
        FpsLabel.Size = UDim2.new(1, -20, 0, 16)
        FpsLabel.Text = "FPS: -"

        -- Log Frame
        LogFrame = Instance.new("ScrollingFrame")
        LogFrame.Parent = main
        LogFrame.Position = UDim2.new(0, 0, 0, 130)
        LogFrame.Size = UDim2.new(1, -20, 1, -150)
        LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        LogFrame.ScrollBarThickness = 6
        LogFrame.BackgroundColor3 = Color3.fromRGB(22,22,26)
        LogFrame.BorderSizePixel = 0
        local logCorner = Instance.new("UICorner", LogFrame) logCorner.CornerRadius = UDim.new(0, 8)
        local logPad = Instance.new("UIPadding", LogFrame) logPad.PaddingTop = UDim.new(0, 6) logPad.PaddingLeft = UDim.new(0, 6) logPad.PaddingRight = UDim.new(0, 6)

        LogList = Instance.new("Frame")
        LogList.Parent = LogFrame
        LogList.BackgroundTransparency = 1
        LogList.Size = UDim2.new(1, -12, 0, 0)
        local list = Instance.new("UIListLayout", LogList)
        list.Padding = UDim.new(0, 2)
        list.FillDirection = Enum.FillDirection.Vertical
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LogList.Size = UDim2.new(1, -12, 0, list.AbsoluteContentSize.Y)
            LogFrame.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
            LogFrame.CanvasPosition = Vector2.new(0, math.max(0, LogFrame.AbsoluteCanvasSize.Y))
        end)

        -- Toggle UI: RightShift
        game:GetService("UserInputService").InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == Enum.KeyCode.RightShift then
                UI.Enabled = not UI.Enabled
                main.Visible = UI.Enabled
            end
        end)
    end)
end

buildUI()

local function setStatus(text, detail)
    if StatusLabel then StatusLabel.Text = "Status: " .. (text or "-") end
    if DetailLabel and detail then DetailLabel.Text = detail end
end

-- FPS monitor
do
    local frames, last = 0, time()
    RunService.Heartbeat:Connect(function()
        frames += 1
        local now = time()
        if now - last >= 1 then
            if FpsLabel then
                FpsLabel.Text = ("FPS: %d | OK:%d / FAIL:%d"):format(frames, UI.Success, UI.Fail)
            end
            frames = 0
            last = now
        end
    end)
end

-- =========[ ACCOUNT ROLE: chọn pet cho acc ]=========
local CurrentPet = nil
for _, cfg in ipairs(getgenv().AccHold) do
    if cfg.AccountName == player.Name then
        CurrentPet = cfg.Pet
        break
    end
end
if CurrentPet then
    info(("Account '%s' → gom pet: %s"):format(player.Name, tostring(CurrentPet)))
else
    warn(("Account '%s' không có trong AccHold → chế độ tự kiểm tra plot."):format(player.Name))
end

-- =========[ UTILITIES ]=========
local function safePosOfModel(model)
    if not model then return nil end
    local ok, pivot = pcall(function()
        if model.WorldPivot then
            return model.WorldPivot.Position
        elseif model.GetPivot then
            return model:GetPivot().Position
        else
            return model.PrimaryPart and model.PrimaryPart.Position or model:GetModelCFrame().p
        end
    end)
    if ok then return pivot end
    return nil
end

local function distance(a, b)
    return (a - b).Magnitude
end

-- Lấy plot của mình
local function GetMyPlot()
    if not PlotController then return nil end
    local ok, my = pcall(function() return PlotController.GetMyPlot() end)
    if not ok or not my then return nil end
    if my.PlotModel then return my.PlotModel end
    return nil
end

-- Lấy vị trí home/spawn trong plot: ưu tiên part tên chứa "Spawn"/"Home", fallback index 12 nếu tồn tại
local function GetHomeSpawn(myPlot)
    if not myPlot then return nil end
    local deco = myPlot:FindFirstChild("Decorations")
    if not deco then return nil end
    -- tìm theo tên
    for _, c in ipairs(deco:GetChildren()) do
        if c:IsA("BasePart") and (string.find(string.lower(c.Name), "spawn") or string.find(string.lower(c.Name), "home")) then
            return c.Position
        end
    end
    -- fallback index 12 (nếu có)
    local children = deco:GetChildren()
    local spawnPart = children[12]
    if spawnPart and spawnPart:IsA("BasePart") then
        return spawnPart.Position
    end
    -- fallback 1: lấy part cao nhất
    local best, bestY
    for _, c in ipairs(children) do
        if c:IsA("BasePart") then
            if not bestY or c.Position.Y > bestY then
                bestY = c.Position.Y
                best = c.Position
            end
        end
    end
    return best
end

-- Pathfinding an toàn (re-path nếu lệch, timeout MoveTo)
local function WalkToPosition(targetPos)
    if not humanoid or not hrp then return false end
    if not targetPos then return false end

    local function computePath(fromPos, toPos)
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            WaypointSpacing = 4
        })
        path:ComputeAsync(fromPos, toPos)
        return path
    end

    local start = tick()
    local currentPath = computePath(hrp.Position, targetPos)
    if currentPath.Status ~= Enum.PathStatus.Success then
        warn(("[Path] Không thể tính đường đến (%.1f, %.1f, %.1f)"):format(targetPos.X, targetPos.Y, targetPos.Z))
        return false
    end

    for _, wp in ipairs(currentPath:GetWaypoints()) do
        if (tick() - start) > (getgenv().MaxWalkTime * 8) then
            warn("[Path] Timeout tổng khi đi đường, hủy.")
            return false
        end

        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end

        humanoid:MoveTo(wp.Position)
        -- chờ với timeout nhỏ cho từng waypoint
        local reached = false
        local t0 = tick()
        while tick() - t0 < getgenv().MaxWalkTime do
            if distance(hrp.Position, wp.Position) <= 2.5 then
                reached = true
                break
            end
            -- nếu lệch xa khỏi path → re-path
            if distance(hrp.Position, targetPos) > getgenv().RepathDist then
                currentPath = computePath(hrp.Position, targetPos)
                if currentPath.Status ~= Enum.PathStatus.Success then
                    warn("[Path] Re-path thất bại.")
                    return false
                end
                -- bắt đầu lại theo path mới
                return WalkToPosition(targetPos)
            end
            RunService.Heartbeat:Wait()
        end

        if not reached then
            warn("[Path] Không tới được waypoint, thử re-path.")
            return WalkToPosition(targetPos) -- thử lại 1 vòng
        end
    end

    return true
end

-- Camera theo sau lưng nhìn về nhân vật (nhìn thoáng qua pet)
local function AdjustCameraBehindPlayer(targetModel)
    local cam = Workspace.CurrentCamera
    if not cam or not targetModel or not hrp then return end
    local petPos = safePosOfModel(targetModel) or hrp.Position + Vector3.new(0, 0, -6)
    local direction = (petPos - hrp.Position).Unit
    local behindOffset = -direction * 5 + Vector3.new(0, 3, 0)
    local camPos = hrp.Position + behindOffset

    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0, 2, 0))
    task.delay(3.5, function()
        pcall(function() cam.CameraType = Enum.CameraType.Custom end)
    end)
end

-- Giữ phím E với progress bar
local function HoldKeyEReal(duration)
    duration = math.max(0.1, duration or getgenv().HoldTime)
    local start = tick()
    while tick() - start < duration do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        if ProgressFill then
            local ratio = math.clamp((tick() - start) / duration, 0, 1)
            ProgressFill.Size = UDim2.new(ratio, 0, 1, 0)
        end
        RunService.Heartbeat:Wait()
    end
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    if ProgressFill then ProgressFill.Size = UDim2.new(0, 0, 1, 0) end
end

-- Xử lý 1 pet
local function HandlePet(pet, myPlot)
    local targetPos = safePosOfModel(pet)
    if not targetPos then
        warn("[Pet] Không lấy được vị trí pet.")
        UI.Fail += 1
        return
    end

    setStatus("Đang tiếp cận pet", ("Target: %s | Dist: %.1f"):format(pet.Name, distance(hrp.Position, targetPos)))
    info(("[Move] Đi tới %s (%.1f studs)"):format(pet.Name, distance(hrp.Position, targetPos)))

    if WalkToPosition(targetPos + Vector3.new(0, getgenv().SafeHeight, 0)) then
        AdjustCameraBehindPlayer(pet)
        setStatus("Giữ phím E", ("Pet: %s | Thời gian: %.1fs"):format(pet.Name, getgenv().HoldTime))
        info("[Interact] Giữ phím E...")
        HoldKeyEReal(getgenv().HoldTime)

        -- trở về nhà
        local homePos = GetHomeSpawn(myPlot)
        if homePos then
            setStatus("Quay về nhà", "Điểm home/spawn")
            info("[Return] Quay về vị trí home/spawn")
            WalkToPosition(homePos + Vector3.new(0, getgenv().SafeHeight, 0))
        end

        UI.Success += 1
        info("[Done] Hoàn tất 1 vòng gom.")
        setStatus("Hoàn tất 1 vòng", ("OK:%d | FAIL:%d"):format(UI.Success, UI.Fail))
    else
        UI.Fail += 1
        warn("[Move] Không tới được pet, bỏ qua.")
        setStatus("Không tới được pet", "Sẽ quét lại ở vòng sau.")
    end
end

-- Quét toàn bộ plots và xử lý pet trùng tên
local function ScanAllPlots()
    local myPlot = GetMyPlot()
    if not myPlot then
        warn("[Plot] Không lấy được plot của bạn.")
        return
    end

    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then
        warn("[Plot] Không tìm thấy workspace.Plots")
        return
    end

    local found = 0
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        if plot:IsA("Model") and plot ~= myPlot then
            -- duyệt child cấp 1 (tuỳ game có thể cần :GetDescendants())
            for _, pet in ipairs(plot:GetChildren()) do
                if pet.Name == CurrentPet then
                    found += 1
                    info(("[Scan] Thấy '%s' tại plot khác → xử lý."):format(CurrentPet))
                    HandlePet(pet, myPlot)
                end
            end
        end
    end

    if found == 0 then
        setStatus("Không tìm thấy pet mục tiêu", ("Pet: %s | Sẽ thử lại sau %ds"):format(tostring(CurrentPet), getgenv().CheckInterval))
        info("[Scan] Không thấy pet mục tiêu ở plots khác.")
    end
end

-- Kiểm tra plot mình đã hết pet chưa
local function CheckMyPlotEmpty()
    local myPlot = GetMyPlot()
    if not myPlot then return true end
    for _, pet in ipairs(myPlot:GetChildren()) do
        for _, cfg in ipairs(getgenv().AccHold) do
            if pet.Name == cfg.Pet then
                return false
            end
        end
    end
    return true
end

-- Respawn-safe: cập nhật lại tham chiếu khi chết/respawn
humanoid.Died:Connect(function()
    warn("[Character] Died → chờ respawn...")
    character = player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
    info("[Character] Respawned & references refreshed.")
end)

-- =========[ MAIN LOOPS ]=========
if CurrentPet then
    setStatus("Sẵn sàng", ("Acc: %s → Pet: %s"):format(player.Name, CurrentPet))
    task.spawn(function()
        while true do
            local ok, e = pcall(function()
                ScanAllPlots()
            end)
            if not ok then
                err("[Loop-Scan] " .. tostring(e))
                UI.Fail += 1
            end
            task.wait(getgenv().CheckInterval)
        end
    end)
else
    setStatus("Chế độ tự kiểm tra plot", "Acc không có nhiệm vụ farm cố định")
    task.spawn(function()
        while true do
            local ok, e = pcall(function()
                if getgenv().KickOnEmpty and CheckMyPlotEmpty() then
                    warn("[Plot] Hết pet trong plot của bạn → Kick.")
                    player:Kick("Hết pet rồi.")
                end
            end)
            if not ok then
                err("[Loop-Check] " .. tostring(e))
            end
            task.wait(5)
        end
    end)
end

info("✅ Auto Farm đã khởi động.")
