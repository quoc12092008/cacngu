-- Import các service cần thiết
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Đảm bảo game đã tải xong và LocalPlayer tồn tại
repeat wait() until game:IsLoaded() and Players.LocalPlayer
local player = Players.LocalPlayer

-- Cố định URL webhook
local webhookUrl = "https://6b83-113-175-43-76.ngrok-free.app/webhook"

-- Hàm gửi thông tin tracking cơ bản
local function sendBasicTrackData()
    local data = {
        username = player.Name,
        userId = player.UserId, -- Thêm UserId vào dữ liệu
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
        print(string.format("Basic Track: %s (ID: %d)", player.Name, player.UserId))
        return true
    else
        warn("Basic Tracking failed: " .. tostring(result))
        return false
    end
end

-- Hàm gửi thông tin tracking đầy đủ
local function sendFullTrackData()
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

    local leaderStats = getLeaderStats()
    local candyCane = getCandyCaneAmount()

    local data = {
        username = player.Name,
        userId = player.UserId, -- Thêm UserId vào dữ liệu
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
        print(string.format("Full Track: %s (ID: %d, Candy Cane: %s)", player.Name, player.UserId, candyCane))
        return true
    else
        warn("Full Tracking failed: " .. tostring(result))
        return false
    end
end

-- Hàm chính
local function main()
    repeat wait() until game:IsLoaded()

    if game.PlaceId ~= 13775256536 then
        -- Nếu không phải ID game đúng, chỉ gửi thông tin cơ bản
        sendBasicTrackData()
    else
        -- Nếu là game đúng, gửi thông tin đầy đủ
        local success = sendFullTrackData()

        if not success then
            wait(5)
            sendFullTrackData()
        end
    end
end

-- Chạy script trong một luồng
spawn(main)

-- Thêm chờ khi game tải xong
repeat wait(5) until game:IsLoaded()

-- Chạy vòng lặp cố định
local max_iterations = 2

for i = 1, max_iterations do
    wait(10)
    print(string.format("Iteration %d completed.", i))
end
