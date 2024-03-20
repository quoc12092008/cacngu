getgenv().config = {
    mailMsg = "hn",
    mailUser = "bomaylatricker1",
    minGems = 1000000,
    fps = 60,
    loops = 40,
    tapTimeout = 5,
    waitForBaloonTimeout = 5,
    waitBeforeLoad = 5,
    waitBeforeOptimize = 5,
}
game.RunService:Set3dRenderingEnabled(true)
pcall(function()
    setfpscap(config.fps)
end)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(config.waitBeforeOptimize)

local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local options = {}
local orbFolder = game:GetService("Workspace"):WaitForChild("__THINGS"):WaitForChild("Orbs")
local lootbagFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Lootbags")
local breakablesFolder = game:GetService("Workspace"):WaitForChild("__THINGS"):WaitForChild("Breakables")
local replicatedStorage = game:GetService("ReplicatedStorage")
local Lib = require(replicatedStorage.Library)
local plrs = game:GetService("Players") 
local plr = plrs.LocalPlayer
local tpService = game:GetService("TeleportService")
local dummyfunc = function() return end

function optimize()
    pcall(function()
        for _, v in pairs(game:GetService("Workspace"):FindFirstChild("__THINGS"):GetChildren()) do
            if table.find({"ShinyRelics", "Ornaments", "Instances", "Ski Chairs"}, v.Name) then
                v:Destroy()
            end
        end

        for _, v in pairs(game:GetService("Workspace"):FindFirstChild("__THINGS").__INSTANCE_CONTAINER.Active.AdvancedFishing:GetChildren()) do
            if string.find(v.Name, "Model") or string.find(v.Name, "Water") or string.find(v.Name, "Debris") or string.find(v.Name, "Interactable") then
                v:Destroy()
            end

            if v.Name == "Map" then
                for _, v in pairs(v:GetChildren()) do
                    if v.Name ~= "Union" then
                        v:Destroy()
                    end
                end
            end
        end

        game:GetService("Workspace"):WaitForChild("ALWAYS_RENDERING"):Destroy()
    end)
	for i,v in game:GetDescendants() do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
	local emitFast = require(game:GetService("ReplicatedStorage").Library.Functions.EmitFast)
	local emit = require(game:GetService("ReplicatedStorage").Library.Functions.Emit)
	hookfunction(emit, dummyfunc)
	hookfunction(emitFast, dummyfunc)
	for i,v in Lib.WorldFX do
		if type(v) == "function" then
			hookfunction(v, dummyfunc)
		end
	end

	for i,v in Lib.WorldFX.Fireworks do
		if type(v) == "function" then
			hookfunction(v, dummyfunc)
		end
	end

	for i,v in Lib.GUIFX do
		if type(v) == "function" then
			hookfunction(v, function() return end)
		end
	end	

	UserSettings():GetService("UserGameSettings").MasterVolume = 0
	local decalsyeeted = true
	local g = game
	local w = g.Workspace
	local l = g.Lighting
	local t = w.Terrain
	sethiddenproperty(l,"Technology",2)
	sethiddenproperty(t,"Decoration",false)
	t.WaterWaveSize = 0
	t.WaterWaveSpeed = 0
	t.WaterReflectance = 0
	t.WaterTransparency = 0
	l.GlobalShadows = 0
	l.FogEnd = 9e9
	l.Brightness = 0
	settings().Rendering.QualityLevel = "1"
	for i, v in pairs(w:GetDescendants()) do
		if v:IsA("BasePart") and not v:IsA("MeshPart") then
			v.Material = "Plastic"
			v.Reflectance = 0
		elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
			v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		elseif v:IsA("Explosion") then
			v.BlastPressure = 1
			v.BlastRadius = 1
		elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
			v.Enabled = false
		elseif v:IsA("SpecialMesh") and decalsyeeted  then
			v.TextureId=0
		elseif v:IsA("ShirtGraphic") and decalsyeeted then
			v.Graphic=1
		elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
			v[v.ClassName.."Template"]=1
		end
	end
	for i = 1,#l:GetChildren() do
		e=l:GetChildren()[i]
		if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
			e.Enabled = false
		end
	end
end

optimize()

function updateSave()
    local SaveFile = Lib.Save.Get()
    local save = {
        diamonds = {}
    }
    for i,v in pairs(SaveFile.Inventory) do
        for ID,list in pairs(v) do
            if list.id == "Diamonds" and i == "Currency" then
                save.diamonds.amount = list._am
                save.diamonds.id = ID
                save.diamonds.type = i
                save.diamonds.name = list.id
            end
        end
    end
    return save
end

function mail(item) -- parse item savefile eg.: save.magic_shards
    arg3 = item.type
    arg4 = item.id
    arg5 = tonumber(item.amount)
    if (not arg3) or (not arg4) or (not arg5) then 
        return false
    end
    local args = {
        [1] = config.mailUser,
        [2] = config.mailMsg,
        [3] = arg3,
        [4] = arg4,
        [5] = arg5,
    }
    if item.name then
        if item.name == "Diamonds" then
            if arg5 > config.minGems then
                args[5] -= 10000
                args[5] = math.floor(args[5])
                return Lib.Network.Invoke("Mailbox: Send", unpack(args))
            end
        end
    end
end

task.wait(config.waitBeforeLoad)

if updateSave().diamonds.amount >= config.minGems then
    print("sending gems")
    mail(updateSave().diamonds)
    print("sent gems")
end

function autoGifts()
    while task.wait(1) do
        Lib.Network.Invoke("GiftBag_Open","Large Gift Bag")
        Lib.Network.Invoke("GiftBag_Open","Gift Bag")
    end
end

function doPresents()
	for _,v in Lib.Save.Get().HiddenPresents do
		if not v.Found and v.ID then
			Lib.Network.Invoke("Hidden Presents: Found",v.ID)
		end
	end
end

function autoHiddenPresents()
    while task.wait(1) do
        doPresents()
    end
end

function antiStaff()
    for i,v in plrs:GetPlayers() do
        if v:IsInGroup(5060810) then
            serverhop()
        end
    end
    plrs.PlayerAdded:Connect(function(player)
        if player:IsInGroup(5060810) then
            serverhop()
        end
    end)
end

function getServers()
    local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=50",game.PlaceId)
    local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet(url)).data
    return servers
end

function serverhop()
    local server
    repeat
        task.wait(1)
        server = getServers()[math.random(30,40)]
    until server.id ~= game.JobId
    tpService:TeleportToPlaceInstance(game.PlaceId, server.id, plr)
end

function getBalloonUID(zoneName) 
    for i,v in pairs(Lib.BreakableCmds.AllByZoneAndClass(zoneName, "Chest")) do
        local isGift = string.find(v:GetAttribute("BreakableID"), "Balloon Gift")
        if v:GetAttribute("OwnerUsername") == plr.Name and isGift then
            return v:GetAttribute("BreakableUID")
        elseif v:GetAttribute("OwnerUserName") ~= plr.Name and isGift then
            return "skip"
        end
    end
end

function getCurrentZone() 
    return Lib.MapCmds.GetCurrentZone() 
end

function autoOrbsLootbags()
    for _, lootbag in pairs(game:GetService("Workspace").__THINGS:FindFirstChild("Lootbags"):GetChildren()) do
        if lootbag then
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Lootbags_Claim"):FireServer(unpack( { [1] = { [1] = lootbag.Name, }, } ))
            lootbag:Destroy()
            task.wait()
        end
    end
    
    game:GetService("Workspace").__THINGS:FindFirstChild("Lootbags").ChildAdded:Connect(function(lootbag)
        task.wait()
        if lootbag then
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Lootbags_Claim"):FireServer(unpack( { [1] = { [1] = lootbag.Name, }, } ))
            lootbag:Destroy()
        end
    end)
    
    game:GetService("Workspace").__THINGS:FindFirstChild("Orbs").ChildAdded:Connect(function(orb)
        task.wait()
        if orb then
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):FindFirstChild("Orbs: Collect"):FireServer(unpack( { [1] = { [1] = tonumber(orb.Name), }, } ))
            orb:Destroy()
        end
    end)
end

local blacklistedIds = {}

function resetSpeed()
    plr.Character:WaitForChild("HumanoidRootPart").AssemblyAngularVelocity = Vector3.new(0,0,0)
    plr.Character:WaitForChild("HumanoidRootPart").AssemblyLinearVelocity = Vector3.new(0,0,0)
    plr.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.new(0,0,0)
end

function baloonLoop()
    local activeBaloons = Lib.Network.Invoke("BalloonGifts_GetActiveBalloons")
    for i,v in activeBaloons do
        if v.Popped == true or table.find(blacklistedIds,i) then
            continue
        end
        getgenv().isExisting = true
        local position = v.Position
        task.spawn(function()
            local tickStart = tick()
            repeat
                plr.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(position)
                task.wait()
            until getBalloonUID(getCurrentZone()) or tick()-tickStart > config.waitForBaloonTimeout
            if tick()-tickStart > config.waitForBaloonTimeout then
                getgenv().isExisting = false
            end
            resetSpeed()
            plr.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(v.LandPosition)
            resetSpeed()
        end)
        if isExisting == false then
            continue
        end
        task.wait()
        local args = {
            [1] = Vector3.new(position.X, position.Y, position.Z),
            [2] = 0.5794160315249014,
            [3] = -0.8331117721691044,
            [4] = 200,
        }
        Lib.Network.Invoke("Slingshot_Toggle")
        Lib.Network.Invoke("Slingshot_FireProjectile",unpack(args))
        local args = {
            [1] = v.Id,
        }
        Lib.Network.Fire("BalloonGifts_BalloonHit",unpack(args))
        task.wait()
        Lib.Network.Invoke("Slingshot_Unequip")
        local tickStart = tick()
        repeat task.wait() until getBalloonUID(getCurrentZone()) or tick()-tickStart > config.waitForBaloonTimeout
        if tick()-tickStart > config.waitForBaloonTimeout then
            table.insert(blacklistedIds,v.Id)
        end
        local breakableUID = getBalloonUID(getCurrentZone())
        task.wait()
        if breakableUID == "skip" then 
            table.insert(blacklistedIds,v.Id)
            continue
        end
        if breakableUID then
            local tickStart = tick()
            repeat task.wait()
                Lib.Network.Fire("Breakables_PlayerDealDamage", breakableUID)
            until (not getBalloonUID(getCurrentZone())) or tick()-tickStart > config.tapTimeout
            if tick()-tickStart > config.tapTimeout then
                table.insert(blacklistedIds,v.Id)
                continue
            else
                game:GetService("Workspace").__THINGS:FindFirstChild("Lootbags").ChildAdded:Wait()
            end
        end
    end
end

function antiAfk()
    local virtualuser = game:GetService("VirtualUser")
    task.spawn(function()
        while task.wait(math.random(500,600)) do
            virtualuser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
			task.wait(3)
			virtualuser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end
    end)
    plr.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
	plr.PlayerScripts.Scripts.Core["Server Closing"].Enabled = false
end

-- CODE EXECUTION START

Lib.Network.Fire("Pets_UnequipAll")
task.spawn(autoHiddenPresents)
task.spawn(autoGifts)
antiStaff()
antiAfk()
autoOrbsLootbags()

for i=1,config.loops do
    print("loop no.", i)
    baloonLoop()
    task.wait(1)
end
print("hopping")

tpService.TeleportInitFailed:Connect(function()
    task.wait(20)
    serverhop()
end)

serverhop()
