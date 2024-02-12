local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Lấy người chơi cục bộ và các đối tượng liên quan
local player = Players.LocalPlayer
local leaderstats = player.leaderstats
local diamonds = leaderstats["\240\159\146\142 Diamonds"].Value

-- In giá trị kim cương
print("Số lượng kim cương:", diamonds)

-- Nếu số kim cương lớn hơn 1 triệu, thực hiện teleport đến vị trí đã cho
if diamonds > 1000000 then
    local teleportCoordinates = Vector3.new(143.34673614500, 23.6020991104125977, -349.0367736816406)
    player.Character.HumanoidRootPart.CFrame = CFrame.new(teleportCoordinates)
    
    -- Gửi 1 triệu kim cương cho tài khoản "chuideptrai1209"
    local amountToSend = 1000000
    local recipient = "chuideptrai1209"
    
    -- Fire the RemoteEvent to send diamonds
    local SendDiamondsEvent = ReplicatedStorage:WaitForChild("SendDiamondsEvent")
    SendDiamondsEvent:FireServer(player, recipient, amountToSend)
end
