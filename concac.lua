local Players = game:GetService("Players")

local function formatDiamonds(value)
    return "diamonds: " .. tostring(value)
end

local function sendToWebhook(message)
local webhookUrl = "https://discord.com/api/webhooks/1205091257161097266/YZU7tsXKg4-bQCdsCUnZmkt2_B0DTwt42VAyY5h19JkUKj2GiI7_PIXxa5l-Slxx_3ZB"
local httpService = game:GetService("HttpService")
local data = httpService:JSONEncode({content = message})
httpService:PostAsync(webhookUrl, data, Enum.HttpContentType.ApplicationJson, false)
    print("Sent to Discord Webhook: " .. message) -- Đoạn này chỉ để mô phỏng, hãy thay thế bằng gửi webhook thực sự
end

local function onLeaderstatsChanged(player)
    local diamondsValue = player.leaderstats["\240\159\146\142 Diamonds"]
    local formattedValue = formatDiamonds(diamondsValue.Value)
    sendToWebhook(formattedValue)
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        local leaderstats = player:WaitForChild("leaderstats")
        leaderstats.ChildAdded:Connect(function(child)
            if child.Name == "\240\159\146\142 Diamonds" then
                onLeaderstatsChanged(player)
            end
        end)
        leaderstats.ChildRemoved:Connect(function(child)
            if child.Name == "\240\159\146\142 Diamonds" then
                -- Handle removal if needed
            end
        end)
    end)
end

Players.PlayerAdded:Connect(setupPlayer)

-- Khi script chạy, nếu có người chơi hiện tại, hãy thiết lập cho họ ngay lập tức
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end
