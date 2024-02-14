local socket = require("socket")

-- Hàm gửi thông điệp đến webhook
local function sendToWebhook(playerName, diamondsValue)
    local webhookUrl = "https://discord.com/api/webhooks/1205091257161097266/YZU7tsXKg4-bQCdsCUnZmkt2_B0DTwt42VAyY5h19JkUKj2GiI7_PIXxa5l-Slxx_3ZB"
    
    local message = "BananaWebhoob\nPlayer: " .. playerName .. "\nDiamonds: " .. diamondsValue
    
    local body = '{"content":"' .. message .. '"}'
    local headers = {
        ["Content-Type"] = "application/json",
        ["Content-Length"] = tostring(#body)
    }
    
    local host = "discord.com"
    local port = 443
    
    local conn = socket.tcp()
    conn:settimeout(5) -- Đặt thời gian chờ kết nối
    
    conn:connect(host, port)
    conn:send("POST " .. webhookUrl .. " HTTP/1.1\r\n")
    
    for key, value in pairs(headers) do
        conn:send(key .. ": " .. value .. "\r\n")
    end
    
    conn:send("\r\n")
    conn:send(body)
    
    local response, err = conn:receive("*a")
    conn:close()
    
    if response then
        print("Webhook response: " .. response)
    else
        print("Failed to send webhook: " .. err)
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
