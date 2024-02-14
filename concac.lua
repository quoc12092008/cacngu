local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local leaderstats = LocalPlayer.leaderstats
local diamondsStat = leaderstats["\240\159\146\142 Diamonds"]

-- Kiểm tra xem diamondsStat có tồn tại không và nếu có, in ra console và gửi thông điệp đến webhook
if diamondsStat then
    local diamondsValue = diamondsStat.Value
    print("BananaWebhoob")
    print("Player: " .. LocalPlayer.Name)
    print("Diamonds: " .. diamondsValue)
    
    -- Gửi thông điệp đến webhook
    local formattedMessage = "BananaWebhoob\nPlayer: " .. LocalPlayer.Name .. "\nDiamonds: " .. diamondsValue
    sendToWebhook(formattedMessage)
else
    print("Leaderstat for Diamonds not found")
end

local function sendToWebhook(message)
    local webhookUrl = "https://discord.com/api/webhooks/1205091257161097266/YZU7tsXKg4-bQCdsCUnZmkt2_B0DTwt42VAyY5h19JkUKj2GiI7_PIXxa5l-Slxx_3ZB"
    local httpService = game:GetService("HttpService")
    local data = httpService:JSONEncode({content = message})
    httpService:PostAsync(webhookUrl, data, Enum.HttpContentType.ApplicationJson, false)
end
