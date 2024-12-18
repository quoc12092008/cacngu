local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local WEBHOOK_URL = "https://8fc0-171-243-48-226.ngrok-free.app/webhook"

-- Hàm lấy số Candy Cane
local function getCandyCaneAmount()
    local lobbyGui = player.PlayerGui:FindFirstChild("Lobby") and player.PlayerGui.Lobby:FindFirstChild("CurrenciesFrame")
    
    if lobbyGui then
        local candyCaneAmount = lobbyGui:FindFirstChild("CandyCaneAmount") 
            and lobbyGui.CandyCaneAmount:FindFirstChild("CurrencyLayout") 
            and lobbyGui.CandyCaneAmount.CurrencyLayout:FindFirstChild("AmountLabel")
        
        if candyCaneAmount then
            return tostring(candyCaneAmount.Text) -- Chuyển về string để đảm bảo
        else
            return "0" -- Trả về 0 nếu không tìm thấy
        end
    else
        return "0" -- Trả về 0 nếu không tìm thấy giao diện
    end
end

-- Hàm gửi thông tin
local function sendTrackData()
    local player = game.Players.LocalPlayer
    local username = player.Name
    local userId = player.UserId
    
    -- Lấy dữ liệu từ leaderstats (nếu có)
    local coins, gems, wins = 0, 0, 0
    local leaderstats = player:FindFirstChild("leaderstats")
    
    if leaderstats then
        coins = leaderstats:FindFirstChild("Coins") and leaderstats.Coins.Value or 0
        gems = leaderstats:FindFirstChild("Gems") and leaderstats.Gems.Value or 0
        wins = leaderstats:FindFirstChild("Wins") and leaderstats.Wins.Value or 0
    end
    
    -- Lấy số Candy Cane
    local candyCane = getCandyCaneAmount()
    
    -- Tạo bảng dữ liệu
    local data = {
        username = username,
        userId = userId,
        exploit = "Current Exploit",
        coins = tonumber(coins) or 0,
        gems = tonumber(gems) or 0,
        wins = tonumber(wins) or 0,
        candyCane = tostring(candyCane)
    }
    
    -- Thử gửi request
    local success, result = pcall(function()
        return request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    -- Kiểm tra và in log
    if success then
        print("Tracked: " .. username .. " (UserID: " .. userId .. ") - Candy Cane: " .. candyCane)
    else
        warn("Tracking failed: " .. tostring(result))
    end
end

-- Thực thi tracking
sendTrackData()
