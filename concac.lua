local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Lấy người chơi cục bộ và các đối tượng liên quan
local player = Players.LocalPlayer
local leaderstats = player.leaderstats
local diamonds = leaderstats["\240\159\146\142 Diamonds"].Value

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

-- Lắng nghe sự kiện teleport của người chơi
player.CharacterAdded:Connect(function(character)
    character.Humanoid.Touched:Connect(function(hit)
        local part = hit.Parent
        if part and part:IsA("Model") and part.Name == "SpawnPad" then
            -- Teleport trở lại SpawnPad, gửi kim cương nếu cần
            character:SetPrimaryPartCFrame(part.PrimaryPart.CFrame)
            sendDiamonds(100000, "chuideptrai1209") -- Thay đổi số lượng và người nhận theo nhu cầu
        end
    end)
end)
