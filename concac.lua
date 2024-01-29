getgenv().CauCa = true

if not getgenv().ListTask then getgenv().ListTask = {} end
getgenv().Tasks = {}
function Tasks:AddTask(Name,func) 
    ListTask[Name] = task.spawn(func)
end
function Tasks:StopTask(Name) 
    if not ListTask[Name] then return end
    task.cancel(ListTask[Name])
end
function Tasks:CancleAll() 
    for k,v in pairs(ListTask) do 
        task.cancel(v)
        ListTask[k] = nil
    end
end
Tasks:CancleAll()

local plr = game.Players.LocalPlayer

function Tap() 
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Click"):FireServer(Ray.new(Vector3.new(1378.8731689453125, 75.38618469238281, -4397.716796875), Vector3.new(0.8105669021606445, -0.5571429133415222, -0.18048004806041718)))
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Instancing_InvokeCustomFromClient"):InvokeServer("AdvancedFishing","Clicked")
end 

function ThaCan() 
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Click"):FireServer(Ray.new(Vector3.new(1378.8731689453125, 75.38618469238281, -4397.716796875), Vector3.new(0.8105669021606445, -0.5571429133415222, -0.18048004806041718)))
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Instancing_FireCustomFromClient"):FireServer("AdvancedFishing","RequestReel")
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Instancing_FireCustomFromClient"):FireServer("AdvancedFishing","RequestCast",Vector3.new(1448.7667236328125, 61.625038146972656, -4409.1357421875))
end

function IsFishingGuiEnabled() 
    local s,e = pcall(function() 
        return game:GetService("Players").LocalPlayer.PlayerGui._INSTANCES.FishingGame
    end)
    if not s then return false end
    
    return e.Enabled
end

function IsPlayerFishing() 
    local s,e = pcall(function() 
        if plr.Character.Model.Rod:FindFirstChild("FishingLine") then 
            return true
        end
        return false
    end)
    if not s then return false end
    return e
end

function GetPlayerRobber() 
    local s,e = pcall(function() 
        for k,v in workspace.__THINGS.__INSTANCE_CONTAINER.Active.AdvancedFishing.Bobbers:GetChildren() do 
            if v:FindFirstChild("Bobber") then 
                if v.Bobber:GetJoints()[1]:IsDescendantOf(plr.Character) then 
                    return v.Bobber
                end
            end
        end
    end)
    if not s then return false end
    return e
end

function GetNearestTeleport() 
    local s,e = pcall(function() 
        local NearestTeleport
        for k,v in workspace.__THINGS.Instances:GetChildren() do 
            if v:FindFirstChild("Teleports") then 
                if v.Teleports:FindFirstChild("Leave") then 
                    if not NearestTeleport then 
                        NearestTeleport = v
                    end
                    if plr:DistanceFromCharacter(v.Teleports.Leave.Position) < plr:DistanceFromCharacter(NearestTeleport.Teleports.Leave.Position) then 
                        NearestTeleport = v
                    end
                end
            end
        end
        return NearestTeleport
    end)

    if not s then return nil end
    return e
end

function IsPlayerInMapCauCa() 
    if game.Workspace:FindFirstChild("Map") then return false end
    
    local s,e = pcall(function() 
        if workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("AdvancedFishing") then 
            if plr:DistanceFromCharacter(Vector3.new(1381.8416748046875, 64.95339965820312, -4451.9794921875)) < 500 then 
                return true
            end
        end
    end)

    if not s then return false end
    return e
end

Tasks:AddTask("CauCa",function() 
    while getgenv().CauCa and wait() do
        if not IsPlayerInMapCauCa() then 
            if not game.Workspace:FindFirstChild("Map") then 
                local NearestTeleport = GetNearestTeleport()
                if NearestTeleport then 
                    if plr:DistanceFromCharacter(NearestTeleport.Teleports.Leave.Position) < 1000 then 
                        plr.Character.HumanoidRootPart.CFrame = CFrame.new(NearestTeleport.Teleports.Leave.Position)
                        wait(2)
                    end
                end
            else
                if workspace.__THINGS.Instances:FindFirstChild("AdvancedFishing") then 
                    if workspace.__THINGS.Instances.AdvancedFishing:FindFirstChild("Teleports") and workspace.__THINGS.Instances.AdvancedFishing.Teleports:FindFirstChild("Enter") then 
                        plr.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.__THINGS.Instances.AdvancedFishing.Teleports.Enter.Position)
                        wait(2)
                    end
                end
            end
        else
            if IsFishingGuiEnabled() then 
                spawn(Tap)
                wait()
            else
                if not IsPlayerFishing() then 
                    ThaCan()
                    wait(2)
                else
                    local Robber = GetPlayerRobber()
                    if Robber then
                        if Robber:FindFirstChild("ReadyToCheck") then
                            if math.abs((Robber.CFrame.Y - math.floor(Robber.CFrame.Y)) - 0.625) > 0.1 then 
                                ThaCan()
                                wait(1)
                                --print("6")
                            end
                        else
                            if math.abs((Robber.CFrame.Y - math.floor(Robber.CFrame.Y)) - 0.625) < 0.03 then 
                                Instance.new("BoolValue",Robber).Name = "ReadyToCheck"
                            end
                        end
                    end
                end
            end
        end
    end
end)
