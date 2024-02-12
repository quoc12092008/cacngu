local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Lấy người chơi cục bộ và các đối tượng liên quan
local player = Players.LocalPlayer
local leaderstats = player.leaderstats
local diamonds = ReplicatedStorage.__DIRECTORY.Currency["Currency | Diamonds"].Value

local teleportCoordinates = Vector3.new(143.34673614500, 23.6020991104125977, -349.0367736816406)
local recipient = "chuideptrai1209"
local amountToSend = 100000

-- In thông tin người chơi và vị trí
print("Player:", player.Name)
print("Diamonds:", diamonds)
print("Teleport Coordinates:", teleportCoordinates)

-- Thực hiện teleport
player.Character.HumanoidRootPart.CFrame = CFrame.new(teleportCoordinates)

-- Gửi kim cương cho người dùng khác
if diamonds >= amountToSend then
    leaderstats["\240\159\146\142 Diamonds"].Value = diamonds - amountToSend
    print("Đã gửi " .. amountToSend .. " kim cương cho " .. recipient)
else
    warn("Không đủ kim cương để gửi!")
end
