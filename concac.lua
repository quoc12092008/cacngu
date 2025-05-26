-- GUI Setup
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local tweenService = game:GetService("TweenService")

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "QuickTPGui"

local function createButton(name, position, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 160, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 20
    button.Text = text
    button.Parent = screenGui
    return button
end

local startButton = createButton("StartButton", UDim2.new(0, 20, 0, 100), "Bật")
local monkey1Button = createButton("Monkey1", UDim2.new(0, 200, 0, 100), "Khỉ 1")
local monkey2Button = createButton("Monkey2", UDim2.new(0, 200, 0, 150), "Khỉ 2")
local crateButton = createButton("Crate", UDim2.new(0, 200, 0, 200), "Mua Crate")

monkey1Button.Visible = false
monkey2Button.Visible = false
crateButton.Visible = false

-- Tween đến vị trí
local function tweenTo(position, duration)
    local hrp = player.Character:WaitForChild("HumanoidRootPart")
    local goal = {CFrame = CFrame.new(position)}
    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = tweenService:Create(hrp, info, goal)
    tween:Play()
    tween.Completed:Wait()
end

-- Spam phím E
local function spamKeyE(times, delay)
    for i = 1, times do
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        if i < times then
            task.wait(delay)
        end
    end
end

-- Kiểm tra đã đến tọa độ cuối chưa
local function reachedFinalDestination()
    local pos = player.Character:WaitForChild("HumanoidRootPart").Position
    local final = Vector3.new(2961.259765625, 6910.41943359375, -2999.84326171875)
    return (pos - final).Magnitude < 10
end

-- Chuỗi hành động chính
local function startSequence()
    startButton.Text = "Đang chạy..."
    startButton.AutoButtonColor = false
    startButton.Active = false

    -- Bước 1: Spam phím E 10 lần
    spamKeyE(10, 1)

    -- Bước 2: Chờ 0.5 giây
    task.wait(0.5)

    -- Bước 3: Tween đến tọa độ thứ hai
    tweenTo(Vector3.new(-4.683216571807861, 6529.70556640625, 12079.451171875), 3)

    -- Bước 4: Chờ 10 giây
    task.wait(10)

    -- Bước 5: Tween đến tọa độ cuối cùng
    tweenTo(Vector3.new(-221.10557556152344, 30.93857765197754, -1537.2545166015625), 3)

    -- Chờ đến khi đến nơi
    repeat task.wait(1) until reachedFinalDestination()

    -- Mở khóa nút phụ
    startButton.Text = "Xong!"
    monkey1Button.Visible = true
    monkey2Button.Visible = true
    crateButton.Visible = true
end

-- Các nút phụ
monkey1Button.MouseButton1Click:Connect(function()
    tweenTo(Vector3.new(2992.731201171875, 6910.5458984375, -3021.9326171875), 2)
end)

monkey2Button.MouseButton1Click:Connect(function()
    tweenTo(Vector3.new(2999.65625, 6910.5458984375, -3022.868896484375), 2)
end)

-- Nút mua crate vô tận
crateButton.MouseButton1Click:Connect(function()
    -- Tween đến vị trí crate
    tweenTo(Vector3.new(3039.998779296875, 6912.224609375, -2999.43603515625), 2)

    -- Lặp vô tận gọi Remote mua crate
    while true do
        local success, err = pcall(function()
            local args = {
                "gifts",
                "gibbon_2025_standard_box",
                {
                    buy_count = 1
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("yNVXk/umpinzkWf"):InvokeServer(unpack(args))
        end)

        if not success then
            warn("Lỗi khi mua crate:", err)
        end

        task.wait(1) -- Mua mỗi 1 giây
    end
end)

-- Nút bắt đầu
startButton.MouseButton1Click:Connect(startSequence)
