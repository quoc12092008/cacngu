local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SendDiamondsEvent = ReplicatedStorage:WaitForChild("SendDiamondsEvent")

local player = game:GetService("Players").LocalPlayer
local leaderstats = player.leaderstats
local diamonds = leaderstats["\240\159\146\142 Diamonds"].Value

print("Số lượng kim cương:", diamonds) -- In ra giá trị kim cương trên console

if diamonds >= 100000 then
    -- Giảm số lượng kim cương của người chơi đi 100,000
    leaderstats["\240\159\146\142 Diamonds"].Value = diamonds - 100000
    
    -- Fire the RemoteEvent to signal the ServerScript to send diamonds
    SendDiamondsEvent:FireServer(player, "chuideptrai1209", 100000)
end

-- Kết nối sự kiện từ máy chủ
SendDiamondsEvent.OnClientEvent:Connect(function(success)
    if success then
        print("Gửi kim cương thành công!")
    else
        warn("Gửi kim cương thất bại!")
    end
end)
