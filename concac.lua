local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local emeraldsDataStore = DataStoreService:GetDataStore("PlayerEmeralds")

-- Function để đặt số lượng Emeralds của một Player lên 100.000
local function setEmeraldsTo100K(player)
    local success, errorMessage = pcall(function()
        emeraldsDataStore:SetAsync(player.UserId, 100000)
    end)
    if not success then
        warn("Error setting emeralds for player " .. player.Name .. ": " .. errorMessage)
    else
        print("Successfully set emeralds for player " .. player.Name .. " to 100,000.")
    end
end

-- Lắng nghe sự kiện khi một Player tham gia vào trò chơi
Players.PlayerAdded:Connect(function(player)
    -- Kiểm tra xem số lượng Emeralds của người chơi đã được đặt chưa
    local success, currentEmeralds = pcall(function()
        return emeraldsDataStore:GetAsync(player.UserId)
    end)
    
    -- Nếu số lượng Emeralds chưa được đặt, thực hiện đặt số lượng Emeralds lên 100.000
    if not success or not currentEmeralds then
        setEmeraldsTo100K(player)
    end
end)
