local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Lấy thông tin người chơi và số kim cương từ các đối tượng local đã đề cập
local player = Players.chuideptrai1209
local playerName = player.Name
local diamondsStat = player.leaderstats["\240\159\146\142 Diamonds"]
local diamondsValue = diamondsStat and diamondsStat.Value or "N/A"

-- Định dạng thông điệp
local message = "Tiêu đề: Bananawebhook\nTên người dùng: " .. playerName .. "\nSố Diamonds: " .. diamondsValue

-- Định dạng thông điệp trong JSON
local postData = HttpService:JSONEncode({
    content = message
})

-- URL của webhook Discord
local webhookUrl = "https://discord.com/api/webhooks/1205091257161097266/YZU7tsXKg4-bQCdsCUnZmkt2_B0DTwt42VAyY5h19JkUKj2GiI7_PIXxa5l-Slxx_3ZB"

-- Gửi yêu cầu POST đến webhook
local success, response = pcall(function()
    return HttpService:PostAsync(webhookUrl, postData, Enum.HttpContentType.ApplicationJson, false)
end)

if success then
    print("Webhook response: " .. response)
else
    warn("Failed to send webhook: " .. tostring(response))
end
