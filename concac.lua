--=== CONFIG ===--
local webhookUrl = "https://discord.com/api/webhooks/1378811253765574767/t5lFqOqiM641yFiPN6_GJpiTlzzY3m2UIMIH7g9Jye_lfZUIyXkPQum5IiwPmRWbp7pe"

--=== SUPPORT ===--
function findMyPlot(debug)
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        local owner = plot:FindFirstChild("Owner")
        if owner and owner.Value == game.Players.LocalPlayer then
            if debug then print("Found plot: "..plot.Name) end
            return plot
        end
    end
    return nil
end

function getPetDataFromSpawn(spawn)
    if not spawn then return nil end
    local petModel = spawn:FindFirstChildOfClass("Model")
    if not petModel then return nil end

    local name = petModel.Name
    local mut = petModel:FindFirstChild("Mutation") and petModel.Mutation.Value or "Normal"
    local rar = petModel:FindFirstChild("Rarity") and petModel.Rarity.Value or "Common"
    local price = petModel:FindFirstChild("Price") and petModel.Price.Value or 0

    return {
        name = name,
        mut = mut,
        rar = rar,
        price = price
    }
end

function sendWebhook(content)
    local HttpService = game:GetService("HttpService")
    local data = {
        ["content"] = content
    }
    local jsonData = HttpService:JSONEncode(data)

    syn.request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = jsonData
    })
end

function listPetsInPlot()
    local plot = findMyPlot(true)
    if not plot then
        warn("Plot not found!")
        return
    end

    local podFolder = plot:FindFirstChild("AnimalPodiums")
    if not podFolder then
        warn("No AnimalPodiums folder in plot")
        return
    end

    local finalLog = "=== Pets in Your Plot ===\n"

    for _, podium in ipairs(podFolder:GetChildren()) do
        local basePart = podium:FindFirstChild("Base")
        local spawn = basePart and basePart:FindFirstChild("Spawn")
        local data = getPetDataFromSpawn(spawn)
        if data then
            local line = string.format(
                ":feet: Name: %s | Mutation: %s | Rarity: %s | Price: $%s",
                data.name,
                data.mut,
                data.rar,
                tostring(data.price)
            )
            print(line)
            finalLog = finalLog .. line .. "\n"
        else
            local line = "[Slot " .. podium.Name .. "] Empty or invalid spawn"
            print(line)
            finalLog = finalLog .. line .. "\n"
        end
    end

    -- Send to Discord
    sendWebhook(finalLog)
end

--=== SIMPLE GUI ===--
local library = loadstring(game:HttpGet("https://pastebin.com/raw/Z6T6rEwT"))()
local window = library:CreateWindow("Steal Brainrot Pet Viewer")

window:AddButton(":package: Quét Pet + Gửi Discord", function()
    listPetsInPlot()
end)

window:AddButton(":x: Đóng GUI", function()
    library:Destroy()
end)
