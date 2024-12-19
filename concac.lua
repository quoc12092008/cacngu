local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Đảm bảo game đã tải xong và LocalPlayer tồn tại
repeat wait() until game:IsLoaded() and Players.LocalPlayer
local player = Players.LocalPlayer

-- Kiểm tra nếu game đang ở PlaceId đúng (13775256536)
if game.PlaceId ~= 13775256536 then
    print("Đây không phải game đúng. Script không chạy.")
    return -- Dừng script nếu không phải game đúng
end

-- Hàm lấy số Candy Cane
local function getCandyCaneAmount()
    local lobbyGui = player:WaitForChild("PlayerGui"):FindFirstChild("Lobby")
        and player.PlayerGui.Lobby:FindFirstChild("CurrenciesFrame")
    
    if lobbyGui then
        local candyCaneAmount = lobbyGui:FindFirstChild("CandyCaneAmount")
            and lobbyGui.CandyCaneAmount:FindFirstChild("CurrencyLayout")
            and lobbyGui.CandyCaneAmount.CurrencyLayout:FindFirstChild("AmountLabel")
        
        if candyCaneAmount then
            return tostring(candyCaneAmount.Text)
        else
            return "0"
        end
    else
        return "0"
    end
end

-- Hàm lấy thông tin từ leaderstats
local function getLeaderStats()
    local leaderstats = player:FindFirstChild("leaderstats")
    
    if not leaderstats then
        return {
            coins = 0,
            gems = 0,
            wins = 0
        }
    end
    
    return {
        coins = leaderstats:FindFirstChild("Coins") and leaderstats.Coins.Value or 0,
        gems = leaderstats:FindFirstChild("Gems") and leaderstats.Gems.Value or 0,
        wins = leaderstats:FindFirstChild("Wins") and leaderstats.Wins.Value or 0
    }
end

-- Hàm gửi thông tin tracking
local function sendTrackData(webhookUrl)
    local leaderStats = getLeaderStats()
    local candyCane = getCandyCaneAmount()
    
    local data = {
        username = player.Name,
        userId = player.UserId,  -- Thêm UserId vào dữ liệu
        coins = leaderStats.coins,
        gems = leaderStats.gems,
        wins = leaderStats.wins,
        candyCane = candyCane,
        receivedAt = os.date("%Y-%m-%d %H:%M:%S") -- Thời gian nhận
    }
    
    local success, result = pcall(function()
        return request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success then
        print(string.format("Tracked: %s (ID: %d, Candy Cane: %s)", 
            player.Name, player.UserId, candyCane))
        return true
    else
        warn("Tracking failed: " .. tostring(result))
        return false
    end
end

-- Hàm chính
local function main()
    repeat wait() until game:IsLoaded()
    
    local webhookUrl = getgenv().Set and getgenv().Set.WEBHOOK_URL or 
        "https://055b-171-243-48-226.ngrok-free.app/webhook"
    
    local success = sendTrackData(webhookUrl)
    
    if not success then
        wait(5)
        sendTrackData(webhookUrl)
    end
end

-- Chạy script trong một luồng
spawn(main)
