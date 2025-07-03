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

local function listPetsInPlot(plot)
    if not plot then
        warn("Plot not found!")
        return
    end

    local podFolder = plot:FindFirstChild("AnimalPodiums")
    if not podFolder then
        warn("No AnimalPodiums folder in plot")
        return
    end

    print("=== 🐾 Pets in Your Plot ===")
    for _, podium in ipairs(podFolder:GetChildren()) do
        local basePart = podium:FindFirstChild("Base")
        local spawn = basePart and basePart:FindFirstChild("Spawn")
        local data = getPetDataFromSpawn(spawn)
        if data then
            print(string.format(
                "🐾 Name: %s | Mutation: %s | Rarity: %s | Price: $%s",
                data.name,
                data.mut,
                data.rar,
                tostring(data.price)
            ))
        else
            print("[Slot " .. podium.Name .. "] Empty or invalid spawn")
        end
    end
end

local myPlot = findMyPlot(true)
listPetsInPlot(myPlot)
