task.wait(5)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

getgenv().LUCKY_BLOCK_CONFIG = getgenv().LUCKY_BLOCK_CONFIG or {
    ["La Vacca Saturno Saturnita"] = true,
}

getgenv().BASE_FULL_CONFIG = getgenv().BASE_FULL_CONFIG or {
    MAX_ITEMS = 10,
}

local MIN_HORIZONTAL_DISTANCE = getgenv().MIN_HORIZONTAL_DISTANCE or 65
local MAX_VERTICAL_DISTANCE = getgenv().MAX_VERTICAL_DISTANCE or 20
local HOLD_E_TIME = getgenv().HOLD_E_TIME or 1.7

getgenv().WEBHOOK_URL = getgenv().WEBHOOK_URL or ""

local function writeToAccountsFile()
    local player = game.Players.LocalPlayer
    local username = player.Name
    local text = username .. ":Done"
    
    if isfile("accounts.txt") then
        local existingContent = readfile("accounts.txt")
        writefile("accounts.txt", existingContent .. "\n" .. text)
        print("✓ Appended to accounts.txt: " .. text)
    else
        writefile("accounts.txt", text)
        print("✓ Created accounts.txt with: " .. text)
    end
end

local function closeGame()
    task.spawn(function()
        task.wait(0.5)
        pcall(function() game:Shutdown() end)
    end)
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local startTime = tick()
repeat 
    task.wait(0.05)
    if tick() - startTime > 20 then break end
until workspace:FindFirstChild("Plots")

task.wait(0.2)

local spawnPosition = humanoidRootPart.CFrame

local collecting = false
local collectedItems = {}
local characterDied = false
local playerBase = nil  

local function setupCharacterMonitor()
    characterDied = false
    
    humanoid.Died:Connect(function()
        characterDied = true
    end)
end

setupCharacterMonitor()

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    spawnPosition = humanoidRootPart.CFrame
    
    setupCharacterMonitor()
    
    task.wait(0.2)
    characterDied = false
    collecting = false
end)

local function findPlayerBase()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        return nil
    end
    
    local closestBase = nil
    local closestDistance = math.huge
    
    for _, base in ipairs(plots:GetChildren()) do
        local basePos
        if base:IsA("Model") then
            basePos = base:GetPivot().Position
        elseif base:IsA("BasePart") then
            basePos = base.Position
        else
            continue
        end
        
        local distance = (basePos - spawnPosition.Position).Magnitude
        if distance < closestDistance and distance < 100 then
            closestDistance = distance
            closestBase = base
        end
    end
    
    if closestBase then
        print("✓ Found base at", math.floor(closestDistance), "studs")
        return closestBase
    end
    
    return nil
end

local function countItemsInBase(base)
    if not base or not base.Parent then 
        return 0, {}
    end
    
    local count = 0
    local itemNames = {}
    
    local itemContainer = base:FindFirstChild("Podium") or 
                         base:FindFirstChild("Base") or 
                         base:FindFirstChild("Items") or
                         base:FindFirstChild("Inventory") or
                         base
    
    for _, item in ipairs(itemContainer:GetChildren()) do
        local skipNames = {
            "Owner", "Value", "Configuration", "Settings", 
            "HumanoidRootPart", "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg",
            "Humanoid", "Part", "MeshPart",
            "FriendPanel", "Panel", "GUI", "Button", "Frame", "Screen",
            "Glow", "Light", "Effect", "Decoration"
        }
        
        local shouldSkip = false
        for _, skipName in ipairs(skipNames) do
            if item.Name == skipName or item.Name:find(skipName) then
                shouldSkip = true
                break
            end
        end
        
        if not shouldSkip and item:IsA("Model") then
            count = count + 1
            table.insert(itemNames, item.Name)
        end
    end
    
    return count, itemNames
end

playerBase = findPlayerBase()

if playerBase then
    local initialCount, initialItems = countItemsInBase(playerBase)
    print("Base items:", initialCount, "/", getgenv().BASE_FULL_CONFIG.MAX_ITEMS)
    
    if initialCount >= getgenv().BASE_FULL_CONFIG.MAX_ITEMS then
        print("✓✓✓ BASE FULL ON STARTUP ✓✓✓")
        writeToAccountsFile()
        closeGame()
        return
    end
end

local function findTargetItem()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        return nil, nil
    end
    
    local enabledItems = {}
    for targetName, enabled in pairs(getgenv().LUCKY_BLOCK_CONFIG) do
        if enabled then
            enabledItems[targetName] = true
        end
    end
    
    for _, plot in ipairs(plots:GetChildren()) do
        for _, obj in ipairs(plot:GetChildren()) do
            if enabledItems[obj.Name] and not collectedItems[obj] then
                local itemPos
                if obj:IsA("Model") then
                    itemPos = obj:GetPivot().Position
                elseif obj:IsA("BasePart") then
                    itemPos = obj.Position
                else
                    continue
                end
                
                local horizontalDistance = (Vector3.new(itemPos.X, 0, itemPos.Z) - 
                                           Vector3.new(humanoidRootPart.Position.X, 0, humanoidRootPart.Position.Z)).Magnitude
                
                local verticalDistance = itemPos.Y - humanoidRootPart.Position.Y
                
                if horizontalDistance >= MIN_HORIZONTAL_DISTANCE and verticalDistance <= MAX_VERTICAL_DISTANCE then
                    print(string.format("FOUND: %s - H:%.0f V:+%.1f", obj.Name, horizontalDistance, verticalDistance))
                    return obj, itemPos
                end
            end
        end
    end
    
    return nil, nil
end

local initialItem, initialPos = findTargetItem()

if not initialItem then
    print("No items found - disconnecting...")
    closeGame()
    return
end

print("Items found! Starting...")

spawn(function()
    while true do
        task.wait(0.08)
        if not collecting and not characterDied then
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.01)
                vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end
end)

local HttpService = game:GetService("HttpService")

local function sendWebhook(itemName)
    if not getgenv().WEBHOOK_URL or getgenv().WEBHOOK_URL == "" then
        return
    end
    
    task.spawn(function()
        pcall(function()
            local data = {
                ["embeds"] = {{
                    ["title"] = "Hi guys",
                    ["description"] = string.format("**%s**", itemName),
                    ["color"] = 16744192,
                    ["fields"] = {
                        {
                            ["name"] = "🔸 Rarity:",
                            ["value"] = "Secret",
                            ["inline"] = false
                        },
                        {
                            ["name"] = "💰 Check:",
                            ["value"] = "222",
                            ["inline"] = false
                        },
                        {
                            ["name"] = "👤",
                            ["value"] = player.Name,
                            ["inline"] = false
                        }
                    },
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
                }}
            }
            
            local jsonData = HttpService:JSONEncode(data)
            
            request({
                Url = getgenv().WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData
            })
        end)
    end)
end

local lastPath = nil

local function walkTo(targetPos, useSavedPath)
    local waypoints
    
    if useSavedPath and lastPath then
        waypoints = {}
        for i = #lastPath, 1, -1 do
            table.insert(waypoints, lastPath[i])
        end
    else
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentCanClimb = true,
            WaypointSpacing = 8,
            Costs = {
                Water = math.huge,
                Danger = math.huge
            }
        })
        
        local success = pcall(function()
            path:ComputeAsync(humanoidRootPart.Position, targetPos)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            waypoints = path:GetWaypoints()
            lastPath = waypoints
        else
            humanoid:MoveTo(targetPos)
            humanoid.MoveToFinished:Wait()
            return true
        end
    end
    
    for i, waypoint in ipairs(waypoints) do
        if characterDied then
            return false
        end
        
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        
        humanoid:MoveTo(waypoint.Position)
        
        local reachedWaypoint = false
        local connection
        connection = humanoid.MoveToFinished:Connect(function(reached)
            reachedWaypoint = true
            connection:Disconnect()
        end)
        
        local startTime = tick()
        local lastPosition = humanoidRootPart.Position
        local stuckCheckTime = tick()
        
        while not reachedWaypoint and (humanoidRootPart.Position - waypoint.Position).Magnitude > 4 do
            if characterDied then
                if connection then connection:Disconnect() end
                return false
            end
            
            if tick() - stuckCheckTime > 0.5 then
                local distanceMoved = (humanoidRootPart.Position - lastPosition).Magnitude
                if distanceMoved < 0.5 then
                    for j = 1, 5 do
                        humanoid.Jump = true
                        task.wait(0.03)
                    end
                    humanoid:MoveTo(waypoint.Position)
                    break
                end
                lastPosition = humanoidRootPart.Position
                stuckCheckTime = tick()
            end
            
            if tick() - startTime > 3 then
                break
            end
            task.wait(0.01)
        end
        
        if connection then connection:Disconnect() end
    end
    
    return true
end

local function collect()
    collecting = true
    
    humanoid:Move(Vector3.new(0, 0, 0))
    task.wait(0.05)
    
    local originalCam = workspace.CurrentCamera.CFrame
    
    local cam = workspace.CurrentCamera
    cam.CFrame = cam.CFrame * CFrame.Angles(math.rad(-89), 0, 0)
    task.wait(0.05)
    
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(HOLD_E_TIME)
    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    
    task.wait(0.05)
    workspace.CurrentCamera.CFrame = originalCam
    
    task.wait(0.1)
    collecting = false
end

local cycle = 0

while true do
    if characterDied then
        task.wait(0.3)
        continue
    end
    
    cycle = cycle + 1
    print("\n[CYCLE", cycle, "]")
    
    local item, itemPos = findTargetItem()
    
    if not item then
        print("No items - disconnecting...")
        closeGame()
        break
    else
        collectedItems[item] = true
        
        if not item or not item.Parent then
            collectedItems[item] = nil
            continue
        end
        
        local success = walkTo(itemPos, false)
        
        if not success or characterDied then
            collectedItems[item] = nil
            task.wait(0.3)
            continue
        end
        
        collect()
        sendWebhook(item.Name)
        
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            for i = 1, 4 do
                vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                
                vim:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                
                vim:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
                
                vim:SendKeyEvent(true, Enum.KeyCode.Four, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.Four, false, game)
                break
            end
        end)
        
        success = walkTo(spawnPosition.Position, true)
        
        if not success or characterDied then
            task.wait(0.3)
            continue
        end
        
        if playerBase and playerBase.Parent then
            local itemCount, itemNames = countItemsInBase(playerBase)
            print("Base:", itemCount, "/", getgenv().BASE_FULL_CONFIG.MAX_ITEMS)
            
            if itemCount >= getgenv().BASE_FULL_CONFIG.MAX_ITEMS then
                print("✓✓✓ BASE FULL ✓✓✓")
                writeToAccountsFile()
                closeGame()
                break
            end
        else
            playerBase = findPlayerBase()
        end
        
        lastPath = nil
    end
end
