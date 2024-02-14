-- Hàm gửi thông điệp đến webhook
local function sendToWebhook(playerName, diamondsValue)
    local webhookUrl = "https://discord.com/api/webhooks/1205091257161097266/YZU7tsXKg4-bQCdsCUnZmkt2_B0DTwt42VAyY5h19JkUKj2GiI7_PIXxa5l-Slxx_3ZB"
    
    local message = "BananaWebhoob\nPlayer: " .. playerName .. "\nDiamonds: " .. diamondsValue
    
    local httpService = game:GetService("HttpService")
    local postData = httpService:JSONEncode({content = message})
    
    local success, response = pcall(function()
        return httpService:PostAsync(webhookUrl, postData, Enum.HttpContentType.ApplicationJson, false)
    end)
    
    if success then
        print("Webhook response: " .. response)
    else
        warn("Failed to send webhook: " .. tostring(response))
    end
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local leaderstats = LocalPlayer.leaderstats
local diamondsStat = leaderstats["\240\159\146\142 Diamonds"]

-- Kiểm tra xem diamondsStat có tồn tại không và nếu có, in ra console và gửi thông điệp đến webhook
if diamondsStat then
    local diamondsValue = diamondsStat.Value
    local playerName = LocalPlayer.Name
    print("BananaWebhoob")
    print("Player: " .. playerName)
    print("Diamonds: " .. diamondsValue)
    
    -- Gửi thông điệp đến webhook
    sendToWebhook(playerName, diamondsValue)
else
    print("Leaderstat for Diamonds not found")
end
