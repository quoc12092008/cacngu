local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Hàm để di chuyển nhân vật đến tọa độ mong muốn
local function teleportToPosition(position)
    local humanoid = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local tweenInfo = TweenInfo.new(
        1, -- Thời gian di chuyển
        Enum.EasingStyle.Linear, -- Kiểu easing
        Enum.EasingDirection.InOut -- Hướng easing
    )
    local targetPosition = CFrame.new(position)
    local tween = TweenService:Create(humanoid, tweenInfo, {CFrame = targetPosition})
    tween:Play()
    tween.Completed:Wait()
end

-- Hàm để nhấp vào nút "Send"
local function clickSendButton()
    local sendButton = game:GetService("Players").LocalPlayer.PlayerGui._MACHINES.MailboxMachine.Frame.SendFrame.Bottom.Send
    sendButton:FireServer()
end

-- Hàm để nhập thông tin vào các ô nhập liệu
local function fillInData(username, message, diamonds)
    local usernameTextBox = game:GetService("Players").LocalPlayer.PlayerGui._MACHINES.MailboxMachine.Frame.SendFrame.username.TextBox
    local messageTextBox = game:GetService("Players").LocalPlayer.PlayerGui._MACHINES.MailboxMachine.Frame.SendFrame.message.TextBox
    local diamondsTextBox = game:GetService("Players").LocalPlayer.PlayerGui._MACHINES.MailboxMachine.Frame.SendFrame.diamonds.TextBox

    usernameTextBox.Text = username
    messageTextBox.Text = message
    diamondsTextBox.Text = diamonds
end

-- Di chuyển nhân vật đến tọa độ mong muốn
teleportToPosition(Vector3.new(143.34673614500, 23.6020991104125977, -349.0367736816406))

-- Đợi một khoảng thời gian ngắn trước khi thực hiện các hành động tiếp theo (có thể cần điều chỉnh thời gian này)
wait(1)

-- Nhập thông tin vào các ô nhập liệu
fillInData("chuideptrai1209", "aaaaaaaaa", "1000000")

-- Nhấp vào nút "Send"
clickSendButton()
