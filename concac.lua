-- Webhook URL của bạn
local WEBHOOK_URL = "https://discord.com/api/webhooks/1378811253765574767/t5lFqOqiM641yFiPN6_GJpiTlzzY3m2UIMIH7g9Jye_lfZUIyXkPQum5IiwPmRWbp7pe"

-- Tìm Plot của mình
local function findMyPlot(verbose)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local plotsFolder = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Houses")
    if not plotsFolder then
        warn("Không tìm thấy folder chứa plots (Plots/Houses)!")
        return nil
    end

    for _, plot in pairs(plotsFolder:GetChildren()) do
        local owner = plot:FindFirstChild("Owner")
        if owner and owner.Value == LocalPlayer.Name then
            if verbose then
                print("✅ Tìm thấy plot của bạn: " .. plot.Name)
            end
            return plot
        end
    end

    warn("Không tìm thấy plot của bạn!")
    return nil
end

-- Đọc thông tin Pet từ Spawn
local function getPetDataFromSpawn(spawn)
    if not spawn then
        return nil
    end

    local nameValue = spawn:FindFirstChild("PetName")
    local mutValue = spawn:FindFirstChild("Mutation")
    local rarValue = spawn:FindFirstChild("Rarity")
    local priceValue = spawn:FindFirstChild("Price")

    if nameValue and mutValue and rarValue and priceValue then
        return {
            name = nameValue.Value,
            mut = mutValue.Value,
            rar = rarValue.Value,
            price = priceValue.Value
        }
    else
        return nil
    end
end

-- In danh sách Pet và trả text
local function listPetsText(plot)
    if not plot then
        warn("Plot not found!")
        return "❌ Plot not found!"
    end

    local podFolder = plot:FindFirstChild("AnimalPodiums")
    if not podFolder then
        warn("No AnimalPodiums folder in plot")
        return "❌ No AnimalPodiums in plot!"
    end

    local result = {}
    table.insert(result, "=== 🐾 Pets in Your Plot ===")

    for _, podium in ipairs(podFolder:GetChildren()) do
        local basePart = podium:FindFirstChild("Base")
        local spawn = basePart and basePart:FindFirstChild("Spawn")
        local data = getPetDataFromSpawn(spawn)
        if data then
            table.insert(result, string.format(
                "🐾 Name: %s | Mutation: %s | Rarity: %s | Price: $%s",
                data.name,
                data.mut,
                data.rar,
                tostring(data.price)
            ))
        else
            table.insert(result, "[Slot " .. podium.Name .. "] Empty or invalid spawn")
        end
    end

    return table.concat(result, "\n")
end

-- Gửi nội dung text về webhook
local function sendToWebhook(content)
    local HttpService = game:GetService("HttpService")

    local data = {
        ["username"] = "Pet Reporter",
        ["content"] = content
    }

    local json = HttpService:JSONEncode(data)

    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, json)
    end)

    if success then
        print("✅ Đã gửi dữ liệu về Discord webhook.")
    else
        warn("❌ Lỗi gửi webhook: " .. tostring(err))
    end
end

-- 🚀 Chạy
local myPlot = findMyPlot(true)
local text = listPetsText(myPlot)
sendToWebhook(text)
