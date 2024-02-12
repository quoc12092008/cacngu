-- Thông tin về vị trí đích bạn muốn nhân vật của mình đi đến
local targetPosition = Vector3.new(143.34673614500, 23.6020991104125977, -349.0367736816406)

-- Function để di chuyển nhân vật đến vị trí đích
local function teleportToPosition(position)
    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
end

-- Function để gửi gems cho người chơi khác
local function sendGems(playerName, amount)
    local players = game:GetService("Players")
    local targetPlayer = players:FindFirstChild(playerName)
    
    -- Kiểm tra nếu người chơi cần gửi gems tồn tại
    if targetPlayer then
        local leaderstats = players.LocalPlayer:FindFirstChild("leaderstats")
        local diamondsStat = leaderstats:FindFirstChild("\240\159\146\142 Diamonds") -- Điều chỉnh tên stat nếu cần thiết
        
        -- Kiểm tra nếu có stat diamonds và số lượng gems đủ để gửi
        if diamondsStat and diamondsStat.Value >= amount then
            -- Gửi gems và cập nhật lại số lượng trong stat diamonds
            diamondsStat.Value = diamondsStat.Value - amount
            print("Đã gửi " .. amount .. " gems cho " .. playerName)
        else
            print("Không đủ gems để gửi!")
        end
    else
        print("Không tìm thấy người chơi có tên là " .. playerName)
    end
end

-- Gọi function để di chuyển nhân vật đến vị trí đích
teleportToPosition(targetPosition)

-- Gọi function để gửi gems cho người chơi "chuideptrai12092"
sendGems("chuideptrai12092", 1000000) -- Số lượng gems bạn muốn gửi
