local HttpService = game:GetService("HttpService")

local Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- Lấy player và giá trị của Diamonds
local plr = game.Players.LocalPlayer
local leaderstats = plr:FindFirstChild("leaderstats")
local diamondsStat = leaderstats and leaderstats:FindFirstChild("\240\159\146\142 Diamonds")
local diamondsValue = diamondsStat and diamondsStat.Value

-- Lấy tên người chơi Roblox
local robloxUserName = plr and plr.Name

-- Lấy webhookUrl từ biến getgenv().Set.webhook
local webhookUrl = getgenv().Set.webhook

-- Kiểm tra xem có giá trị Diamonds, tên người chơi và webhookUrl hay không
if diamondsValue and robloxUserName and webhookUrl then
    -- Chuẩn bị nội dung thông điệp
    local message = {
        ["username"] = "Ember", -- Đặt tên người gửi là "Ember"
        ["content"] = "```Game: Pet Simulator\nPlayer: " .. robloxUserName .. "\nDiamonds: " .. diamondsValue .. "\nDCT DisplayBlox```"
    }

    -- Chuyển đổi thông điệp thành JSON
    local jsonMessage = HttpService:JSONEncode(message)

    -- Gửi thông điệp đến webhook Discord
    local success, response = pcall(function()
        return Request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonMessage
        })
    end)

    -- Kiểm tra xem gửi thành công hay không
    if success then
        print("DisplayBlox DCT")
    else
        warn("Không thể gửi thông điệp đến webhook Discord:", response)
    end
end
    -- Tạo GUI (User Interface) để hiển thị giá trị Diamonds
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.Players.LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0.5, -100, 0, 50)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(1, 1, 1)
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "Diamonds: " .. tostring(diamondsValue)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Parent = frame
else
    warn("Không tìm thấy giá trị Diamonds, tên người chơi, hoặc webhookUrl.")
end
