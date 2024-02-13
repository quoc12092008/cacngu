repeat wait()
until game:IsLoaded() and game.Players.LocalPlayer
getgenv().HideUI = true
local TimeDelayIntro = tick()
repeat wait()
    pcall(function()
        for i,v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui["__INTRO"].Frame.Skip.MouseButton1Up)) do
            v.Function()
        end
    end)
    if tick()-TimeDelayIntro >= 100 then 
        game:Shutdown()
    end
until  not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("__INTRO")
repeat wait()
until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Loading") and not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Loading").Enabled and game:GetService("Players").LocalPlayer:FindFirstChild("__LOADED") and game:GetService("Players").LocalPlayer["__LOADED"].Value
spawn(function()
    local FPSboost 
    FPSboost = hookfunction(getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Coins).CoinDamageAnimation,function(p10,p11)
        return nil
    end)
end)

local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local plr = game.Players.LocalPlayer
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Window = Library:CreateWindow({
    Title = 'Loi Nuoc Ngot  Hub',
    Center = true, 
    AutoShow = true,
})
local Tabs = {
    Main = Window:AddTab('Main Farm'),
    MainSellpet = game.PlaceId == 7722306047 and  Window:AddTab('Main Sell'),
    MainBoost = Window:AddTab("Main Boost"),
}
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
wait(1)
vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)
local Settings = {}
local HttpService = game:GetService("HttpService")
local FolderName = "loi nuoc ngot Hub"
local SaveFileNameGame = "-psx.json"
if game.PlaceId == 10321372166 then 
    SaveFileNameGame = "-Hardcorepsx.json"
end
local SaveFileName = game.Players.LocalPlayer.Name..SaveFileNameGame
local SettingHopServer = {}
local DefaultSettingHopServer = {}
function SaveSettings(fff,fff2)
    if fff~=nil then
        Settings[fff] = fff2
    end
    HttpService = game:GetService("HttpService")
    if not isfolder(FolderName) then
        makefolder(FolderName)
    end
    writefile(FolderName.."/" .. SaveFileName, HttpService:JSONEncode(Settings))
end
function ReadSetting()
  local s,e = pcall(function()
      HttpService = game:GetService("HttpService")
      if not isfolder(FolderName) then
          makefolder(FolderName)
      end
      return HttpService:JSONDecode(readfile(FolderName.."/" .. SaveFileName))
  end)
  if s then return e
  else
      SaveSettings()
      return ReadSetting()
  end
end
Settings = ReadSetting()

local LeftGroupFarm = Tabs.Main:AddLeftGroupbox('Main')
local Client = require(game.ReplicatedStorage.Library.Client)
local FrameworkLibrary = require(game.ReplicatedStorage.Framework.Library)
local v11 = require(game.ReplicatedStorage.Library.Directory);
getrenv().require = getgenv().require -- method tvk hihi (iu tvk vcl)
debug.setupvalue(Client.Network.Invoke, 1, function() return true end)
debug.setupvalue(Client.Network.Fire, 1, function() return true end)
require(game.ReplicatedStorage.Framework.Library).WorldCmds.CanDoAction = function() return true end 
local Orbs = getsenv(game.Players.LocalPlayer.PlayerScripts.Scripts.Game.Orbs)
local Lootbags = getsenv(game.Players.LocalPlayer.PlayerScripts.Scripts.Game.Lootbags)
local areas = {}

function DetectUpdgrade()
    for i,v in next,FrameworkLibrary.Directory.Upgrades do
        if v.currency ~= "Yeet Orbs" and not v.isLuckyBlockEvent and not v.isHalloweenEvent then 
            if   not FrameworkLibrary.Save.Get().Upgrades[i] or (FrameworkLibrary.Save.Get().Upgrades[i] and FrameworkLibrary.Save.Get().Upgrades[i] < 5)  then
                if game.Players.LocalPlayer.leaderstats.Diamonds.Value >= v.prices[FrameworkLibrary.Save.Get().Upgrades[i] or 1] then
                    return i,v
                end
            end
        end
    end
end
repeat wait()
    if DetectUpdgrade()  then
        if not game:GetService("Workspace").__MAP.Interactive:FindFirstChild("Upgrade Station") then 
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport("Shop",true)
        else
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").__MAP.Interactive["Upgrade Station"].Pad.CFrame 
            local v1, v2 = Client.Network.Invoke("Buy Upgrade", DetectUpdgrade())
        end
    end
until not DetectUpdgrade()
FrameworkLibrary.Save.Get().Settings.PetsControl = 1
getsenv(plr.PlayerScripts.Scripts.GUIs.Settings).Update()
for _, areaScript in ipairs(game:GetService("ReplicatedStorage")["__DIRECTORY"].Areas:GetDescendants()) do
    if areaScript:IsA("ModuleScript") then
        for i, val in pairs(require(areaScript)) do

            if not val['hidden'] and not table.find(areas, val['name']) then
                table.insert(areas, val['name'])
            end
        end
    end
end
LeftGroupFarm:AddSlider('MySliderTimeRejoin', {
    Text = 'Time Rejoin',
    Default = Settings["Time Rejoin"] or 10,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Compact = false, 
    Callback = function(value)
        SaveSettings("Time Rejoin",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleAutoRejoin', {
    Text = 'Auto Rejoin',
    Default = Settings["Auto Rejoin"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Auto Rejoin",value)
    end
})
spawn(function()
    while wait() do 
        pcall(function()
            if Options.MySliderTimeRejoin.Value and Options.MyToggleAutoRejoin.Value then
                local TimeDelay = tick()
                repeat wait() until tick()-TimeDelay >= Options.MySliderTimeRejoin.Value*60 
                game:Shutdown()
            end
        end)
    end
end)
LeftGroupFarm:AddDropdown('MyDropdownSelectAreas', {
    Values = areas,
    Default = Settings["Select Areas"] or 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected
    Text = 'Select Areas',
    Callback = function(value)
        SaveSettings("Select Areas",value)
    end
})
LeftGroupFarm:AddDropdown('MyDropdownSelectAreas2', {
    Values = areas,
    Default = Settings["Select Area 2"] or 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected
    Text = 'Select Area 2',
    Callback = function(value)
        SaveSettings("Select Area 2",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleFarm2Map', {
    Text = 'Farm 2 Maps',
    Default = Settings["Farm 2 Maps"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Farm 2 Maps",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleFarmFruit', {
    Text = 'Farm Fruit Only Map 1',
    Default = Settings["Farm Fruit"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Farm Fruit",value)
    end
})
LeftGroupFarm:AddSlider('MySliderTimeMap1', {
    Text = 'Time Map 1',
    Default = Settings["Time Map 1"] or 10,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Compact = false, 
    Callback = function(value)
        SaveSettings("Time Map 1",value)
    end
})

LeftGroupFarm:AddSlider('MySliderSpeedFarm1', {
    Text = 'Speed Farm Map 1',
    Default = Settings["Speed Farm Map 1"] or 0.2,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = true, 
    Callback = function(value)
        SaveSettings("Speed Farm Map 1",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleFarmSendAllPet1', {
    Text = 'Send All Pet Map 1',
    Default = Settings["Send All Pet Map 1"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Send All Pet Map 1",value)
    end
})
LeftGroupFarm:AddSlider('MySliderTimeMap2', {
    Text = 'Time Map 2',
    Default = Settings["Time Map 2"] or 10,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Compact = false, 
    Callback = function(value)
        SaveSettings("Time Map 2",value)
    end
})

LeftGroupFarm:AddSlider('MySliderSpeedFarm2', {
    Text = 'Speed Farm Map 2',
    Default = Settings["Speed Farm Map 2"] or 0.2,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = true, 
    Callback = function(value)
        SaveSettings("Speed Farm Map 2",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleFarmSendAllPet2', {
    Text = 'Send All Pet Map 2',
    Default = Settings["Send All Pet Map 2"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Send All Pet Map 2",value)
    end
})
local map1 = true 
local map2 = true
local NameAreaFarm2Map
local TimeDelayAreaFarm2Map
local SpeedFarmAreaFarm2Map
local SendAllPetAreaFarm2Map
local Fruits = {
    "Orange",
    "Apple"
}
function DetectFruit(x)
    local xxx = {}
    for v5,v6 in next, require(game.ReplicatedStorage.Framework.Library).FruitCmds.Directory do
        if table.find(Fruits,v5) and math.round(require(game.ReplicatedStorage.Framework.Library).FruitCmds.Get(require(game.ReplicatedStorage.Framework.Library).LocalPlayer, v6))+1 <= x then
            table.insert(xxx,v5)
        end
    end
    return xxx
end

getgenv().FarmFruitt = false
spawn(function()
    while wait() do 
        pcall(function()
            if Toggles.MyToggleFarm2Map.Value then 
                if map1 then
                    print("b")
                    SendAllPetAreaFarm2Map = Toggles.MyToggleFarmSendAllPet1.Value 
                    NameAreaFarm2Map  = Options.MyDropdownSelectAreas.Value 
                    SpeedFarmAreaFarm2Map = Options.MySliderSpeedFarm1.Value
                    local timeDelay = tick()
                    repeat wait() until (not Toggles.MyToggleFarmFruit.Value and tick()-timeDelay >= Options.MySliderTimeMap1.Value*60) or not Toggles.MyToggleFarm2Map.Value or (Toggles.MyToggleFarmFruit.Value and not getgenv().FarmFruitt) 
                    print("map1")
                    map1 = false
                elseif map2 then 
                    print("a")
                    SendAllPetAreaFarm2Map = Toggles.MyToggleFarmSendAllPet2.Value 
                    NameAreaFarm2Map  = Options.MyDropdownSelectAreas2.Value
                    SpeedFarmAreaFarm2Map = Options.MySliderSpeedFarm2.Value
                    local timeDelay = tick()
                    repeat wait() 

                    until (tick()-timeDelay >= Options.MySliderTimeMap2.Value*60 and not Toggles.MyToggleFarmFruit.Value) or not Toggles.MyToggleFarm2Map.Value or (Toggles.MyToggleFarmFruit.Value and getgenv().FarmFruitt)
                    print("map2")
                    map2 = false
                else
                    map1 = true 
                    map2 = true
                end
            else
                map1 = true 
                map2 = true
            end
        end)
    end
end)

spawn(function()
    while wait() do 
        if Toggles.MyToggleFarmFruit.Value then 
            pcall(function()
                if #DetectFruit(Options.MySliderTimeMap1.Value) == 2 then 
                    getgenv().FarmFruitt = true  
                elseif #DetectFruit(199) == 0  and FarmFruitt then 
                    getgenv().FarmFruitt = false
                end
            end)
        end
    end
end)
spawn(function()
    while wait() do 
        if Toggles.MyToggleFarmFruit.Value and not Toggles.MyToggleFarm2Map.Value and getgenv().FarmFruitt then 
            pcall(function()
                local NameAreass = "Pixel Vault"
                if NameAreass == "Pixel Vault" and require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Pixel" then 
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(3587.955810546875, -16.700345993041992, 2457.21044921875)*CFrame.new(0,-150,0)
                else
                    getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport(NameAreass,true)
                end
                if NameAreass == "Pixel Vault" then
                    GetCoinallll = GetCoinss(NameAreass)
                end
                if #PetTarget < #GetEquippedPets() then 
                    if NameAreass == "Pixel Vault" then
                        FrameworkLibrary.Save.Get().Settings.PetsControl = 1
                        getsenv(plr.PlayerScripts.Scripts.GUIs.Settings).Update()
                        for i,v in next,GetCoinallll do 
                            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Select Coins"]).SelectCoin(v)
                            task.wait(0.1)
                        end
                    else
                        if GetCoinallll.POS:FindFirstChild("HUD") then 
                            FrameworkLibrary.Save.Get().Settings.PetsControl = 2
                            getsenv(plr.PlayerScripts.Scripts.GUIs.Settings).Update()
                        else
                            FrameworkLibrary.Save.Get().Settings.PetsControl = 1
                            getsenv(plr.PlayerScripts.Scripts.GUIs.Settings).Update()
                        end
                        task.wait()
                        getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Select Coins"]).SelectCoin(GetCoinallll)
                        task.wait(0.1)
                    end
                end
            end)
        end
    end
end)
LeftGroupFarm:AddToggle('MyToggleHardCore', {
    Text = 'Auto Hardcore',
    Default = Settings["Auto Hardcore"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Auto Hardcore",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleTradingPlaza', {
    Text = 'Auto Trading Plaza',
    Default = Settings["Auto Trading Plaza"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Auto Trading Plaza",value)
    end
})
spawn(function()
    while wait() do 
        if Toggles.MyToggleTradingPlaza.Value and game.PlaceId ~= 7722306047 then 
            pcall(function()
                Client.Network.Invoke("Travel to Trading Plaza","DEFAULT")
            end)
        end
    end
end)
spawn(function()
    while wait() do 
        if Toggles.MyToggleHardCore.Value and game.PlaceId ~= 10321372166 then 
            pcall(function()
                Client.Network.Invoke("Toggle Hardcore Mode")
            end)
        end
    end
end)
function TeleportIsland(texta)
    local v17 = require(game.ReplicatedStorage.Framework.Library).Directory.Areas[texta]
    if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() ~= v17.world then
        getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport(texta,true)
    end
end
LeftGroupFarm:AddButton("Teleport Island",function()
    TeleportIsland(Options.MyDropdownSelectAreas.Value)
end)
function DetectChestIsland() 
    local b = {}
    if Options.MyDropdownSelectAreas2.Value == "Sunny Skies" then 
        b = {"Summer Sandcastle Chest"}
    end
    for i,v in next,game:GetService("ReplicatedStorage")["__DIRECTORY"].Coins:GetDescendants() do 
        if v.Name == Options.MyDropdownSelectAreas2.Value then 
            for i1,v1 in next,v:GetChildren() do 
                if string.find(v1.Name, "Chest") then 
                    table.insert(b,v1.Name)
                end
            end
        end
    end
    return b
end

LeftGroupFarm:AddDropdown('MyDropdownSelectChest', {
    Values = DetectChestIsland(),
    Default =  0, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected
    Text = 'Select Chest',
    Callback = function(value)
        SaveSettings("Select Chest",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleYeetPet', {
    Text = 'Auto Yeet Pet',
    Default = Settings["Auto Yeet Pet"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Auto Yeet Pet",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleFarmChest', {
    Text = 'Farm Chest',
    Default = Settings["Farm Chest"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Farm Chest",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleFarmAllCoins', {
    Text = 'Farm All Coins',
    Default = Settings["Farm All Coins"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Farm All Coins",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleFarmLuckyBock', {
    Text = 'Farm Lucky Block',
    Default = Settings["Farm Lucky Block"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Farm Lucky Block",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleFarmUnlockMap', {
    Text = 'Unlock Map',
    Default = Settings["Unlock Map"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Unlock Map",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleCollect', {
    Text = 'Collect Orbs/Lootbags',
    Default = Settings["Collect Orbs/Lootbags"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Collect Orbs/Lootbags",value)
    end
})
LeftGroupFarm:AddToggle('MyToggleCollectFreegifts', {
    Text = 'Collect Free Gifts',
    Default = Settings["Collect Free Gifts"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Collect Free Gifts",value)
    end
})
spawn(function()
    while wait() do 
        if Toggles.MyToggleCollectFreegifts.Value then 
            pcall(function()
                for i,v in next,v11.FreeGifts do 
                    if not table.find(FrameworkLibrary.Save.Get().FreeGiftsRedeemed,i) and v.waitTime <= FrameworkLibrary.Save.Get().FreeGiftsTime then
                        local v3, v4 = Client.Network.Invoke("Redeem Free Gift",i)
                    end
                 end                 
            end)
        end
    end
end)
function GetChest()
    for i,v in next, Client.Network.Invoke('Get Coins') do 
        if v.a == Options.MyDropdownSelectAreas2.Value and workspace.__THINGS.Coins:FindFirstChild(i) and Options.MyDropdownSelectChest.Value[v.n]  then 
            return i 
        end 
    end 
end 
getgenv().GetEquippedPets = function()
    local a = {}
    for i,v in next,require(game.ReplicatedStorage.Library.Client).PetCmds.GetEquipped() do
        table.insert(a,v.uid)
    end
    return a 
end
local TeleportInChest = false
local StartConvert = false
local StartConvertRainbow = false
local StartBank = false

function StopFarm()
    if Toggles.MyToggleSentGems.Value and game.Players.LocalPlayer.leaderstats.Diamonds.Value >= 200000000000 then  return true end 
    if Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())) then return true end
    if StartBank and Toggles.MyToggleAutoBank.Value then return true end 
    if StartConvert and Toggles.MyToggleGolden.Value  then return true end
    if StartConvertRainbow and   Toggles.MyToggleRainbow.Value then return true end
end

function AutoChest()
    if Toggles.MyToggleFarmFruit.Value and getgenv().FarmFruitt then return end 
    if StopFarm() then  return end
    local v17 = require(game.ReplicatedStorage.Framework.Library).Directory.Areas[Options.MyDropdownSelectAreas2.Value]
    if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() ~= v17.world then
        TeleportIsland(Options.MyDropdownSelectAreas.Value)
        return 
    end
    local IDChest = tostring(GetChest())
    if workspace.__THINGS.Coins:FindFirstChild(IDChest)  then
        if not  workspace.__THINGS.Coins:FindFirstChild(IDChest).POS:FindFirstChild("HUD") and game.Players.LocalPlayer:DistanceFromCharacter(workspace.__THINGS.Coins:FindFirstChild(IDChest).POS.Position) > 50  then 
            TeleportInChest = true
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.__THINGS.Coins:FindFirstChild(IDChest).POS.CFrame
        else
            Client.Network.Invoke('Join Coin', IDChest, GetEquippedPets())
            for i,v in next,GetEquippedPets() do 
                Client.Network.Fire('Farm Coin', IDChest,v)
            end
            
            if workspace.__THINGS.Coins:FindFirstChild(IDChest).POS:FindFirstChild("HUD") then
                TeleportInChest = false
                repeat wait() until not workspace.__THINGS.Coins:FindFirstChild(IDChest) or not Toggles.MyToggleFarmChest.Value or StopFarm() or workspace.__THINGS.Coins:FindFirstChild(i).POS.HUD.ProgressText.Text == "0" or (Toggles.MyToggleFarmFruit.Value and getgenv().FarmFruitt) 
            end
        end
    end
end
-- FUNCTIONS
function GetIdFruit(Area)
    local Coins = {}
    for i,v in next, Client.Network.Invoke('Get Coins') do 
        if v.a == Area  and table.find(DetectFruit(),v.n) and workspace.__THINGS.Coins:FindFirstChild(i) and ((workspace.__THINGS.Coins[i].POS:FindFirstChild("HUD") and workspace.__THINGS.Coins:FindFirstChild(i).POS.HUD.ProgressText.Text ~= "0") or not workspace.__THINGS.Coins[i]:FindFirstChild("HUD")) and v.h > 0    then
            table.insert(Coins,i)
        end 
    end 
    return Coins
end
function GetCoinss(Area)
    local Coins = {}
    for i,v in next,game:GetService("Workspace").__THINGS.Coins:GetChildren() do 
        if v:IsA("Folder") and v:GetAttribute("Area") == Area and v:GetAttribute("Health") > 0  then 
            table.insert(Coins,v)
        end
    end 
    return Coins
end
function CheckHUD()
    for i,v in next,game:GetService("Workspace")["__THINGS"].Coins:GetDescendants() do 
        if v.Name == "HUD" then 
            return true 
        end
    end
end
function GetCoinsMulti(Area)
    local Coins = {}
    for i,v in next, Client.Network.Invoke('Get Coins') do 
        if v.a == Area and v.b  and workspace.__THINGS.Coins:FindFirstChild(i) and ((workspace.__THINGS.Coins[i].POS:FindFirstChild("HUD") and workspace.__THINGS.Coins:FindFirstChild(i).POS.HUD.ProgressText.Text ~= "0") or not workspace.__THINGS.Coins[i]:FindFirstChild("HUD")) and v.h > 0    then
            table.insert(Coins,i)
        end 
    end 
    return Coins
end 
spawn(function()
    function CreateTweenFloat()
        if not plr.Character.HumanoidRootPart:FindFirstChild("EffectsSY") then
            local BV = Instance.new("BodyVelocity")
            BV.Parent = plr.Character.HumanoidRootPart
            BV.Name = "EffectsSY"
            BV.MaxForce = Vector3.new(0, 100000, 0)
            BV.Velocity = Vector3.new(0, 0, 0)
        end
    end
    local LocalPlayer = game:GetService("Players").LocalPlayer   
    local function getTorso(LocalPlayer)
        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character:FindFirstChild('UpperTorso') then
                return LocalPlayer.Character.UpperTorso
            else
                return LocalPlayer.Character.Torso
            end
        end
    end    
    game:GetService("RunService").RenderStepped:Connect(function()
        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
            for i,v in next,LocalPlayer.Character:GetDescendants() do 
                if (v:IsA("Part") or v:IsA("MeshPart")) and  v.CanCollide then 
                    v.CanCollide = false 
                end
            end
        end
    end)
    game:GetService('RunService').Stepped:connect(function()
        pcall(function()
            if plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health ~= 0 then
                spawn(function()
                    CreateTweenFloat()
                end)
            end
        end)
    end)
end)
getgenv().PetTarget = {}
loadstring([[
    local env = getgenv()
    local old 
    old = hookfunction(getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Pets).ChangePetTargetCoin,function(a1,a2)
        if not table.find(env.PetTarget,a1) and table.find(env.GetEquippedPets(),a1) then
            table.insert(env.PetTarget,a1)
        end
        return old(a1,a2)
    end)
]])()
loadstring([[
    local env = getgenv()
    local old 
    old = hookfunction(getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Pets).ChangePetTargetPlayer,function(a1)
        if #env.PetTarget > 0 then
            for i,v in next,env.PetTarget do 
                if a1 == v then 
                    table.remove(env.PetTarget,i)
                end
            end
        end
        return old(a1)
    end)
]])()
loadstring([[
    local FPSboost 
    FPSboost = hookfunction(getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Coins).CoinDamageAnimation,function(p10,p11)
        return nil
    end)
]])()
function GetCoins(Area)
    local Coins = {}
    for i,v in next,game:GetService("Workspace").__THINGS.Coins:GetChildren() do 
        if v:IsA("Folder") and v:GetAttribute("Area") == Area and v:GetAttribute("Health") > 0  then 
            return v
        end
    end 
end

function DetectHUD(Area)
    local Coins = {}
    for i,v in next,game:GetService("Workspace").__THINGS.Coins:GetChildren() do 
        if v:IsA("Folder") and v:GetAttribute("Area") == Area and v:GetAttribute("Health") > 0 and v.POS:FindFirstChild("HUD") then 
            return v
        end
    end
end
local Original_HasPower = FrameworkLibrary.Shared.HasPower
FrameworkLibrary.Shared.HasPower = function(pet, powerName) 
    if powerName == "Agility" then 
        return true, 3
    end
    return Original_HasPower(pet, powerName)
end
local Original_GetPowerDir = FrameworkLibrary.Shared.GetPowerDir
FrameworkLibrary.Shared.GetPowerDir = function(powerName, tier) 
    if powerName == "Agility" then 
        return  {
            title = "Agility III", 
            desc = "Pet moves 50% faster", 
            value = 20
        }
    end
    return Original_GetPowerDir(powerName, tier)
end
FrameworkLibrary.Shared.GetPowerDir("Agility",3)

spawn(function()
    for i,v in next,game:GetService("ReplicatedStorage").Assets.Models.Lootbags:GetDescendants() do 
        if v:IsA("Attachment") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("PointLight")  then 
            pcall(function()
                v.Parent.Transparency = 1
            end)
            v:Destroy()
        end
    end
end)
function IsMineCollapsed()
    if workspace.__MAP.Interactive:FindFirstChild("Diamond Mine Collapsed Sign")
    and workspace.__MAP.Interactive["Diamond Mine Collapsed Sign"].Main.SurfaceGui.Enabled then
        return true
    end
end

local MineCollapsedSign = false
function AutoFarmAllCoins()
    if StartBank and Toggles.MyToggleAutoBank.Value then return true end 
    if StartConvert and Toggles.MyToggleGolden.Value  then return true end
    if StartConvertRainbow and   Toggles.MyToggleRainbow.Value then return true end
    if Toggles.MyToggleOpenEgg.Value and Toggles.MyToggleFarmFruit.Value  and not FarmFruitt then return end
    if Toggles.MyToggleSentGems.Value and game.Players.LocalPlayer.leaderstats.Diamonds.Value >= 200000000000 then  return true end 
    if Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())) then return  end
    local NameAreass  = Options.MyDropdownSelectAreas.Value
    if Toggles.MyToggleFarm2Map.Value and NameAreaFarm2Map then 
        NameAreass = NameAreaFarm2Map
    end
    local SpeedFarm = Options.MySliderSpeedFarm1.Value
    if Toggles.MyToggleFarm2Map.Value then 
        SpeedFarm  = SpeedFarmAreaFarm2Map
    end
    local SendAllPetttt = Toggles.MyToggleFarmSendAllPet1.Value 
    if Toggles.MyToggleFarm2Map.Value then 
        SendAllPetttt  = SendAllPetAreaFarm2Map
    end
    print("condimemasdkjahsdkj")
    if FrameworkLibrary.Signal.Invoke("Get Diamond Mine Collpase Time") then 
        NameAreass = "Pixel Vault"
    end
    local GetCoinallll = GetCoins(NameAreass) or DetectHUD(NameAreass)
    if NameAreass == "Pixel Vault" then
        GetCoinallll = GetCoinss(NameAreass)
    end
    if NameAreass == "Mystic Mine" and not GetCoinallll and require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Diamond Mine" then 
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(8727.1298828125, -13.025790214538574, 3027.85400390625)*CFrame.new(0,-150,0)
        GetCoinCyber = GetCoins("Cyber Cavern") or DetectHUD("Cyber Cavern")
        if #PetTarget < #GetEquippedPets() and GetCoinCyber then
            if GetCoinallll.POS:FindFirstChild("HUD") then 
                FrameworkLibrary.Save.Get().Settings.PetsControl = 2
                getsenv(plr.PlayerScripts.Scripts.GUIs.Settings).Update()
            else
                FrameworkLibrary.Save.Get().Settings.PetsControl = 1
                getsenv(plr.PlayerScripts.Scripts.GUIs.Settings).Update()
            end
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Select Coins"]).SelectCoin(GetCoinCyber)
            task.wait(0.1)
        end
        return 
    end
    if NameAreass == "Mystic Mine" and require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Diamond Mine" then 
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(9026.587890625, -14.660567283630371, 2465.745849609375)*CFrame.new(0,-150,0)
    elseif NameAreass == "Pixel Vault" and require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Pixel" then 
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(3587.955810546875, -16.700345993041992, 2457.21044921875)*CFrame.new(0,-150,0)
    else
        getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport(NameAreass,true)
    end
    if #PetTarget < #GetEquippedPets() then 
        if NameAreass == "Pixel Vault" then
            FrameworkLibrary.Save.Get().Settings.PetsControl = 1
            getsenv(plr.PlayerScripts.Scripts.GUIs.Settings).Update()
            for i,v in next,GetCoinallll do 
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Select Coins"]).SelectCoin(v)
                task.wait(SpeedFarm)
            end
        else
            if GetCoinallll.POS:FindFirstChild("HUD") then 
                FrameworkLibrary.Save.Get().Settings.PetsControl = 2
                getsenv(plr.PlayerScripts.Scripts.GUIs.Settings).Update()
            else
                FrameworkLibrary.Save.Get().Settings.PetsControl = 1
                getsenv(plr.PlayerScripts.Scripts.GUIs.Settings).Update()
            end
            task.wait()
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Select Coins"]).SelectCoin(GetCoinallll)
            task.wait(0.1)
        end
    end
end
spawn(function()
    while wait() do 
        if Toggles.MyToggleFarmAllCoins.Value then 
            pcall(function()
                AutoFarmAllCoins()
            end)
        end
    end
end)
spawn(function()
    while wait() do 
        if Toggles.MyToggleYeetPet.Value   then 
            pcall(function()
                if Toggles.MyToggleFarmFruit.Value and getgenv().FarmFruitt then return end  
                if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Yeet" then 
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(6719.4150390625, -16.14927864074707, -864.6656494140625)
                else
                    getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport("Yeet Hub",true)
                end
                Client.Network.Invoke("Yeet a Pet: Throw")
            end)
        end
    end
end)

spawn(function()
    while wait() do 
        if Toggles.MyToggleFarmLuckyBock.Value and getgenv().egodsucvat then 
            pcall(function()
                local timedelay = tick()
                repeat wait()
                until tick()-timedelay >= 2*60 or not Toggles.MyToggleFarmLuckyBock.Value or getgenv().FarmFruitt
                getgenv().egodsucvat = false
            end)
        end
    end
end)

spawn(function()
    while wait() do 
        if Toggles.MyToggleFarmChest.Value then 
            pcall(function()
                AutoChest()
            end)
        end
    end
end)

spawn(function()
    while wait() do 
        pcall(function()
            if Toggles.MyToggleCollect.Value then
                for i,v in next,game:GetService("Workspace").__THINGS.Orbs:GetChildren() do 
                    Orbs.Collect(v)
                end
            end
        end)
    end
end)
spawn(function()
    while wait() do 
        pcall(function()
            if Toggles.MyToggleCollect.Value then
                for i,v in next,game:GetService("Workspace").__THINGS.Lootbags:GetChildren() do 
                    Lootbags.Collect(v)
                end
            end
        end)
    end
end)
function vailonluondaucatmoi()
    local mapList = {}
    local getmaptp = game:GetService("Players").LocalPlayer.PlayerGui.Teleport.Frame.LeftContainer.Holder
    for i,v in pairs(getmaptp:GetChildren()) do
        if v:IsA("TextButton") and v.Name ~= "WorldTemplate" then
            table.insert(mapList, v.Name)
        end
    end
    local mapTable = {}
    for i, mapName in ipairs(mapList) do
        mapTable[i] = {name = mapName, data = {}}
    end
    local gateanother = {}
    for i, mapData in pairs(mapTable) do
        if mapData.name ~= "Hardcore" then
            local dbuoi = nil
            local dcac = nil
            local NameMapData = mapData.name
            if FrameworkLibrary.WorldCmds.HasArea("Pixel Vault") then
                NameMapData = "Summer Event"
            end
            local a,b = pcall(function() 
                dbuoi = require(game:GetService("ReplicatedStorage")["__DIRECTORY"].Areas["areas | " .. NameMapData .. " World"])
            end)
            if a == false then
                dbuoi = require(game:GetService("ReplicatedStorage")["__DIRECTORY"].Areas["areas | " .. NameMapData])
            end
            local a,b = pcall(function() 
                dcac = require(game:GetService("ReplicatedStorage")["__DIRECTORY"].Worlds["worlds | " .. NameMapData])
            end)
            if a == false then
                dcac = require(game:GetService("ReplicatedStorage")["__DIRECTORY"].Worlds[NameMapData])
            elseif v == "Hardcore" then
                dcac = require(game:GetService("ReplicatedStorage")["__DIRECTORY"].Worlds["worlds | " .. NameMapData])
            else
                dcac = require(game:GetService("ReplicatedStorage")["__DIRECTORY"].Worlds["worlds | " .. NameMapData])
            end
            for i2,v2 in pairs(dbuoi) do
                if v2.hidden == false and v2.isVIP == nil and (v2.mult ~= 0 or dcac[NameMapData].gravity ~= nil) then
                    if v2.gate == nil then
                        if i2 ~= "Shop" then
                            table.insert(mapData.data, {i2, 0,dcac[NameMapData].mainCurrency})
                        end
                    else
                        if v2.isShop == false then
                            if v2.gate.currency == dcac[NameMapData].mainCurrency then
                                table.insert(mapData.data, {i2, v2.gate.cost,v2.gate.currency})
                            else
                                table.insert(gateanother, {i2, v2.gate.cost, v2.gate.currency})
                            end
                            for i3,v3 in pairs(gateanother) do
                                if v3[3] == dcac[mapData.name].mainCurrency then
                                    table.insert(mapData.data, {v3[1], v3[2], v3[3]})
                                    table.remove(gateanother, i3)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    for i,v in pairs(mapTable) do
        table.sort(v.data, function(a,b) return a[2] < b[2] end)
    end
    return mapTable
end
function getmapautoup()
    for i,v in pairs(vailonluondaucatmoi()) do
        if (not FrameworkLibrary.WorldCmds.HasArea("Pixel Vault") and v.name ~= "Summer Event") or FrameworkLibrary.WorldCmds.HasArea("Pixel Vault") then 
            for i1,v2 in pairs(v.data) do 
                if FrameworkLibrary.WorldCmds.HasArea(v2[1]) == false then
                    if i1 - 1 == 0 then
                        return {v.data[i1][1],v.data[i1][1],v.data[i1][2],v.data[i1][3]}
                    else
                        return {v.data[i1 - 1][1],v.data[i1][1],v.data[i1][2],v.data[i1][3]}
                    end
                end
            end
        end
    end
end
local FarmFruitUnlockMap = true
spawn(function()
    while wait() do 
        pcall(function()
            if #DetectFruit(100) == 0  and FarmFruitUnlockMap then 
                FarmFruitUnlockMap = false
            end
        end)
    end
end)
function UnlockMapCustom()
    if game:GetService("Players").LocalPlayer.PlayerGui.Loading.Enabled then 
        local Time = tick()
        repeat wait()
        until tick()-Time >= 10 and not game:GetService("Players").LocalPlayer.PlayerGui.Loading.Enabled
    end
    if FrameworkLibrary.WorldCmds.HasArea("Pixel Vault") then 
        if FarmFruitUnlockMap then 
            local GetCoinallll = GetCoinss("Pixel Vault") 
            if  require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Pixel" then 
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(3587.955810546875, -16.700345993041992, 2457.21044921875)*CFrame.new(0,-150,0)
            else
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport("Pixel Vault",true)
            end
            if #PetTarget < #GetEquippedPets()  then
                for i,v in next,GetCoinallll do 
                    getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Select Coins"]).SelectCoin(v)
                    task.wait(0.1)
                end
            end
        else
            if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Summer Event" then
                local mapunlock1 =   getmapautoup() and getmapautoup()[1]
                local mapunlock2 = getmapautoup() and getmapautoup()[2]
                if getmapautoup() and  FrameworkLibrary.Save.Get()[getmapautoup()[4]] >= getmapautoup()[3] then 
                    Client.Network.Invoke("Buy Area", mapunlock2)
                    return 
                end
                local mmbb = mapunlock1 or "Pirate Cove"
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport(mmbb,true)
                if #PetTarget < #GetEquippedPets()  then 
                    local GetCoinallll = GetCoinss(mmbb) 
                    for i,v in next,GetCoinallll do 
                        getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Select Coins"]).SelectCoin(v)
                        task.wait(0.1)
                    end
                end
            else
                if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Spawn" then
                    if (Vector3.new(55.959014892578125, 94.92037200927734, 339.9134826660156)-plr.Character.HumanoidRootPart.Position).Magnitude > 8 then 
                        plr.Character.HumanoidRootPart.CFrame = CFrame.new(55.959014892578125, 94.92037200927734, 339.9134826660156)
                    else
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                        wait()
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
                        wait(3)
                    end
                else
                    getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport("Shop",true)
                end
            end
        end
        return 
    end
    local mapunlock1 = getmapautoup()[1]
    local mapunlock2 = getmapautoup()[2]
    if mapunlock1 == "Enchanted Forest" and mapunlock2 == "Enchanted Forest" and getmapautoup()[3] == 0 then 
        if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Spawn" then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2832.6357421875, 103.19497680664062, 224.16542053222656)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
            wait()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
            wait(3)
        end
        return
    elseif mapunlock1 == "Tech City" and mapunlock2 == "Tech City" and getmapautoup()[3] == 0 then 
        if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Fantasy" then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(3075.164306640625, 100.51551818847656, 101.57359313964844)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
            wait()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
            wait(3)
        else
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1817.0340576171875, 113.88807678222656, 634.1914672851562)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
            wait()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
            wait(3)
        end
        return
    elseif mapunlock1 == "The Void" and mapunlock2 == "The Void" and getmapautoup()[3] == 0 then
        wait(3)
        if FrameworkLibrary.Save.Get().HackerPortalProgress[2] ~= 2 then 
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport("Hacker Portal",true)
            v4 = Client.Network.Fire
            v4("Start Hacker Portal Quests")
            v4 = Client.Network.Invoke
            v4 = v4("Finish Hacker Portal Quest")
            local GetCoinallll = GetCoinss("Hacker Portal") 
            if #PetTarget < #GetEquippedPets()  then
                for i,v in next,GetCoinallll do 
                    getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Select Coins"]).SelectCoin(v)
                    task.wait(SpeedFarm)
                end
            end
        else
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2313.740478515625, 96.33271789550781, 3157.054931640625)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
            wait()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
        end
        return
    elseif mapunlock1 == "Axolotl Ocean" and mapunlock2 == "Axolotl Ocean" and getmapautoup()[3] == 0 then
        wait(3)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-156.53077697753906, 117.46312713623047, 5795.82763671875)
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
        wait()
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
        return
    elseif mapunlock1 == "Pixel Forest" and mapunlock2 == "Pixel Forest" and getmapautoup()[3] == 0 then
        if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() == "Axolotl Ocean" then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(4529.8681640625, 35.449466705322266, 3831.95947265625)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
            wait()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
            wait(3)
        else
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-436.1062927246094, 101.07411193847656, 5650.25244140625)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
            wait()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
            wait(3)
        end
        return
    end
    if FrameworkLibrary.Save.Get()[getmapautoup()[4]] >= getmapautoup()[3] then 
        Client.Network.Invoke("Buy Area", mapunlock2)
        print(true)
    else
        print(false)
        local mmbb = mapunlock1
        getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport(mmbb,true)
        if #PetTarget < #GetEquippedPets()  then
            local GetCoinallll = GetCoinss(mmbb) 
            for i,v in next,GetCoinallll do 
                getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Select Coins"]).SelectCoin(v)
                task.wait(0.1)
            end
        end
    end
end
spawn(function()
    while wait() do 
        pcall(function()
            if Toggles.MyToggleFarmUnlockMap.Value then
                UnlockMapCustom()
            end
        end)
    end
end)
local RightroupPet = Tabs.Main:AddRightGroupbox('Pets')
RightroupPet:AddInput('MyTextboxUrlWebhook', {
    Default = Settings["Url Webhook"] or '',
    Numeric = false, -- true / false, only allows numbers
    Finished = false, -- true / false, only calls callback when you press enter
    Text = 'Url Webhook',
    Callback = function(value)
        SaveSettings("Url Webhook",value)
    end
})
RightroupPet:AddToggle('MyToggleWebhookHuge', {
    Text = 'Webhook Huge',
    Default = Settings["Webhook Huge"] or false,
    Callback = function(value)
        SaveSettings("Webhook Huge",value)
    end
})
RightroupPet:AddToggle('MyToggleWebhookGems', {
    Text = 'Webhook Gems',
    Default = Settings["Webhook Gems"] or false,
    Callback = function(value)
        SaveSettings("Webhook Gems",value)
    end
})
function format(num, digits)
	return string.format("%0" .. digits .. "i", num)
end
function parseDateTime()
	local osDate = os.date("!*t")
	local year, mon, day = osDate["year"], osDate["month"], osDate["day"]
	local hour, min, sec = osDate["hour"], osDate["min"], osDate["sec"]
	return year .. "-" .. format(mon, 2) .. "-" .. format(day, 2) .. "T" .. format(hour, 2) .. ":" .. format(min, 2) .. ":" .. format(sec, 2) .. "Z"
end
local function v165(p24)
	local v166 = p24;
	while true do
		local v167, v168 = string.gsub(v166, "^(-?%d+)(%d%d%d)", "%1,%2");
		v166 = v167;
		if v168 == 0 then
			break;
		end;	
	end;
	return v166;
end;
function sendWebhook(url,x,xx)
    local dt = DateTime.now()
    local timestamp = dt:FormatUniversalTime("LL", "vi-vn")
    local now = DateTime.now()
    local timestamp2 = now:FormatLocalTime("LT", "vi-vn") 
    if not xx then 
        msg = {
            ["content"] = "@everyone",
            ["embeds"] = {
                {
                    ["color"] = tonumber(0x000000),
                    ["title"] = "Van Thang iu Loi nuoc ngot",
                    ["fields"] = {
                        {
                            ["name"] = game.Players.LocalPlayer.Name,
                            ["value"] = "**Name Pet: "..x.."**",
                            ["inline"] = false,
                        },
                    },
                    ["timestamp"] = parseDateTime(),
                }
            }
        } 
    else
        msg = {
            ["content"] = "",
            ["embeds"] = {
                {
                    ["color"] = tonumber(0x000000),
                    ["title"] = "Van Thang iu Loi nuoc ngot",
                    ["fields"] = {
                        {
                            ["name"] = game.Players.LocalPlayer.Name,
                            ["value"] = "**Gems: "..v165(game.Players.LocalPlayer.leaderstats.Diamonds.Value).."**",
                            ["inline"] = false,
                        },
                    },
                    ["timestamp"] = parseDateTime(),
                }
            }
        } 
    end
    local request = http_request
    if syn then
        request = syn.request 
    end
    local response = request(
        {
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode(msg)
        }
    )
end

spawn(function()
    local old 
    old = hookfunction(getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"]).OpenEgg,function(p1,p2)
        pcall(function()
            if Toggles.MyToggleWebhookHuge.Value then
                for i,v in next,p2 do 
                    if require(game.ReplicatedStorage.Framework.Library).Directory.Pets[v.id].huge then 
                        sendWebhook(tostring(Options.MyTextboxUrlWebhook.Value),require(game.ReplicatedStorage.Framework.Library).Directory.Pets[v.id].name)
                    end
                end
            end
        end)
        return old(p1,p2)
    end)
end)
spawn(function()
    while wait() do 
        if Toggles.MyToggleWebhookGems.Value then 
            pcall(function()
                local TimeWebhook = tick()
                repeat wait() until tick()-TimeWebhook >= 60*60
                sendWebhook(tostring(Options.MyTextboxUrlWebhook.Value),false,true)
            end)
        end
    end
end)
function DetectEggIsland()
    local a 
    for i,v in next,require(game.ReplicatedStorage.Library.Directory).Areas do 
        if v.name == Options.MyDropdownSelectAreas2.Value then 
            a = v.world
        end
    end
    function detectworld(b)
        for i,v in next,require(game.ReplicatedStorage.Library.Directory).Areas do 
            if v.name == b then 
                return v.world
            end
        end
    end
    local b = {}
    for i,v in next,game:GetService("ReplicatedStorage")["__DIRECTORY"].Eggs:GetDescendants() do
        if v:IsA("ModuleScript") and  detectworld(require(v).area) == a then 
            table.insert(b,require(v).displayName)
            if a == "Summer Event" and not table.find(b,"Butterfly Egg") then 
                table.insert(b,"Butterfly Egg")
            end
        end
    end
    return b
end
RightroupPet:AddDropdown('MyDropdownSelectEgg', {
    Values = DetectEggIsland() ,
    Default = Settings["Select Egg"] or 0, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected
    Text = 'Select Egg',
    Callback = function(value)
        SaveSettings("Select Egg",value)
    end
})
RightroupPet:AddDropdown('MyDropdownSelectOpenEgg', {
    Values = {"1","3","10"},
    Default = Settings["Select Amount Open Egg"] or 0, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected
    Text = 'Select Amount Open Egg',
    Callback = function(value)
        SaveSettings("Select Amount Open Egg",value)
    end
})
RightroupPet:AddToggle('MyToggleOpenEgg', {
    Text = 'Open Egg',
    Default = Settings["Open Egg"] or false,
    Callback = function(value)
        SaveSettings("Open Egg",value)
    end
})
RightroupPet:AddToggle('MyToggleOpenEggEvent', {
    Text = 'Open Egg Event',
    Default = Settings["Open Egg"] or false,
    Callback = function(value)
        SaveSettings("Open Egg",value)
    end
})
RightroupPet:AddToggle('MyToggleDisableEggAnimation', {
    Text = 'Disable Egg Animation',
    Default = Settings["Disable Egg Animation"] or false,
    Callback = function(value)
        SaveSettings("Disable Egg Animation",value)
    end
})
local DisEggAni = false
spawn(function()
    while wait() do 
        if Toggles.MyToggleDisableEggAnimation.Value then 
            pcall(function()
                if not DisEggAni then 
                    for i,v in pairs(getgc(true)) do
                        if (typeof(v) == 'table' and rawget(v, 'OpenEgg')) then
                            v.OpenEgg = function()
                                return
                            end
                        end
                    end
                    spawn(function()
                        old = hookfunction(getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Open Eggs"]).OpenEgg,function(p1,p2)
                            pcall(function()
                                if Toggles.MyToggleWebhookHuge.Value then
                                    for i,v in next,p2 do 
                                        if require(game.ReplicatedStorage.Framework.Library).Directory.Pets[v.id].huge then 
                                            sendWebhook(tostring(Options.MyTextboxUrlWebhook.Value),require(game.ReplicatedStorage.Framework.Library).Directory.Pets[v.id].name)
                                        end
                                    end
                                end
                            end)
                            return old(p1,p2)
                        end)
                    end)
                    DisEggAni = true 
                end
            end)
        end
    end
end)
function DetectPartEgg(b)
    local a 
    for i,v in next, game:GetService("ReplicatedStorage")["__DIRECTORY"].Eggs:GetDescendants() do 
        if v:IsA("Folder") and v.Name == b then 
            a = v.Egg.TextureID
        end
    end
    for i,v in next, game:GetService("Workspace")["__MAP"].Eggs:GetDescendants() do 
        if v:IsA("MeshPart") and v.TextureID == a then 
            return v
        end
    end
end
function finddescendantnamed(parent,name)
    for i,v in pairs(parent:GetDescendants()) do
        if v.Name == name then
            return v
        end
    end
end
function GetCoinsEvent(Area,b)
    local Coins = {}
    for i,v in next,game:GetService("Workspace").__THINGS.Coins:GetChildren() do 
        if v:IsA("Folder") and v:GetAttribute("Area") == Area and (b and string.find(v:GetAttribute("Name"),"Chest") or not b) and v:GetAttribute("Health") > 0  then 
            return v
        end
    end 
end

function OpenEggg()
    if Toggles.MyToggleFarmFruit.Value and getgenv().FarmFruitt then  return end
    if Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())) then return  end
    if StartConvert and Toggles.MyToggleGolden.Value  then  return end
    if StartConvertRainbow and   Toggles.MyToggleRainbow.Value then return true end
    if StartBank and Toggles.MyToggleAutoBank.Value then return true end 
    if Toggles.MyToggleFarmChest.Value and TeleportInChest  then   return end 
    local v17 = require(game.ReplicatedStorage.Framework.Library).Directory.Areas[Options.MyDropdownSelectAreas2.Value]
    
    if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() ~= v17.world then
        TeleportIsland(Options.MyDropdownSelectAreas2.Value)
    else
        local partEgg = DetectPartEgg(Options.MyDropdownSelectEgg.Value)
        if game.Players.LocalPlayer:DistanceFromCharacter(partEgg.Position) > 10 then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = partEgg.CFrame
        else
            if Options.MyDropdownSelectOpenEgg.Value == "1" then
                Client.Network.Invoke("Buy Egg", Options.MyDropdownSelectEgg.Value)
            elseif Options.MyDropdownSelectOpenEgg.Value == "3" then
                Client.Network.Invoke("Buy Egg", Options.MyDropdownSelectEgg.Value,true,false)
            elseif Options.MyDropdownSelectOpenEgg.Value == "10" then
                Client.Network.Invoke("Buy Egg", Options.MyDropdownSelectEgg.Value,false,true)
            end
        end
    end
end
spawn(function()
    while wait() do 
        if Toggles.MyToggleOpenEgg.Value then 
            pcall(function()
                OpenEggg()
            end)
        end
    end
end)
local fukkingshit = Settings["Select Chest"]
Options.MyDropdownSelectAreas2:OnChanged(function()
    Options.MyDropdownSelectChest.Values = DetectChestIsland()
    Options.MyDropdownSelectChest:SetValue({})
    Options.MyDropdownSelectEgg.Values = DetectEggIsland()
    Options.MyDropdownSelectEgg:SetValue({})
end)
Options.MyDropdownSelectChest:SetValue(fukkingshit or {})
RightroupPet:AddSlider('MySliderPets', {
    Text = 'Amount Pets',
    Default = Settings["Amount Pets"] or 400,
    Min = 0,
    Max = 2000,
    Rounding = 0,
    Compact = false, 
    Callback = function(value)
        SaveSettings("Amount Pets",value)
    end
})
RightroupPet:AddSlider('MySliderPetsMakeRainbow', {
    Text = 'Amount Pets Make Rainbow',
    Default = Settings["Amount Pets Make Rainbow"] or 20,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false, 
    Callback = function(value)
        SaveSettings("Amount Pets Make Rainbow",value)
    end
})
RightroupPet:AddToggle('MyToggleGolden', {
    Text = 'Golden Pet',
    Default = Settings["Golden Pet"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Golden Pet",value)
    end
})
RightroupPet:AddToggle('MyToggleRainbow', {
    Text = 'RainBow Pet',
    Default = Settings["RainBow Pet"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("RainBow Pet",value)
    end
})
RightroupPet:AddToggle('MyTogglehcpet', {
    Text = 'Ignore HC pet',
    Default = Settings["Ignore HC Pet"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Ignore HC Pet",value)
    end
})
RightroupPet:AddToggle('MyToggleIgnoreMythicals', {
    Text = 'Ignore Mythical',
    Default = Settings["Ignore Mythical"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Ignore Mythical",value)
    end
})
RightroupPet:AddToggle('MyToggleIgnoreShiny', {
    Text = 'Ignore Shiny',
    Default = Settings["Ignore Shiny"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Ignore Shiny",value)
    end
})

function CheckpetGolden(p1)
    local NameGolden = {}
    local MakeGolden = false
    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if ((Toggles.MyTogglehcpet.Value and not v.hc) or not Toggles.MyTogglehcpet.Value) and ((Toggles.MyToggleIgnoreShiny.Value and not v.sh) or not Toggles.MyToggleIgnoreShiny.Value) and ((Toggles.MyToggleIgnoreMythicals.Value and not v11.Pets[v.id].rarity == "Mythical") or not Toggles.MyToggleIgnoreMythicals.Value) and not v.dm and not v.l and not v.r and not v.g  and v11.Pets[v.id].name == p1 then
            u4 = require(game.ReplicatedStorage.Framework.Library).PetCmds.Get(v.uid).hc and false;
            if #NameGolden == 0 then 
                table.insert(NameGolden,v.uid)
            end
            v26 = u4 and require(game.ReplicatedStorage.Framework.Library).Shared.GoldMachineOdds.Hardcore or require(game.ReplicatedStorage.Framework.Library).Shared.GoldMachineOdds.Normal
            v27 = v26[math.min(#NameGolden, #v26)];
            if require(game.ReplicatedStorage.Framework.Library).Functions.FormatChance(v27.chance / 100) ~= "100%" and not table.find(NameGolden,v.uid) then 
                table.insert(NameGolden,v.uid)
            end
        end
    end
    if #NameGolden > 0 then 
        u4 = require(game.ReplicatedStorage.Framework.Library).PetCmds.Get(NameGolden[1]).hc and false;
        v26 = u4 and require(game.ReplicatedStorage.Framework.Library).Shared.GoldMachineOdds.Hardcore or require(game.ReplicatedStorage.Framework.Library).Shared.GoldMachineOdds.Normal
        v27 = v26[math.min(#NameGolden, #v26)];
        if  require(game.ReplicatedStorage.Framework.Library).Functions.FormatChance(v27.chance / 100) == "100%" then
            return NameGolden
        end
    end
    return 
end
function CheckpetGoldenShiny(p1)
    local NameGolden = {}
    local MakeGolden = false
    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if v.sh and not v.dm and not v.l and not v.r and not v.g  and v11.Pets[v.id].name == p1 then
            u4 = require(game.ReplicatedStorage.Framework.Library).PetCmds.Get(v.uid).hc and false;
            if #NameGolden == 0 then 
                table.insert(NameGolden,v.uid)
            end
            v26 = u4 and require(game.ReplicatedStorage.Framework.Library).Shared.GoldMachineOdds.Hardcore or require(game.ReplicatedStorage.Framework.Library).Shared.GoldMachineOdds.Normal
            v27 = v26[math.min(#NameGolden, #v26)];
            if require(game.ReplicatedStorage.Framework.Library).Functions.FormatChance(v27.chance / 100) ~= "100%" and not table.find(NameGolden,v.uid) then 
                table.insert(NameGolden,v.uid)
            end
        end
    end
    if #NameGolden > 0 then 
        u4 = require(game.ReplicatedStorage.Framework.Library).PetCmds.Get(NameGolden[1]).hc and false;
        v26 = u4 and require(game.ReplicatedStorage.Framework.Library).Shared.GoldMachineOdds.Hardcore or require(game.ReplicatedStorage.Framework.Library).Shared.GoldMachineOdds.Normal
        v27 = v26[math.min(#NameGolden, #v26)];
        if  require(game.ReplicatedStorage.Framework.Library).Functions.FormatChance(v27.chance / 100) == "100%" then
            return NameGolden
        end
    end
    return 
end
function CheckpetRainbow(p1)
    local NameRainbow = {}
    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if ((Toggles.MyTogglehcpet.Value and not v.hc) or not Toggles.MyTogglehcpet.Value) and ((Toggles.MyToggleIgnoreShiny.Value and not v.sh) or not Toggles.MyToggleIgnoreShiny.Value) and ((Toggles.MyToggleIgnoreMythicals.Value and not v11.Pets[v.id].rarity == "Mythical") or not Toggles.MyToggleIgnoreMythicals.Value) and not v.dm  and not v.l and  not v.r and v.g    and v11.Pets[v.id].name == p1 then
            u4 = require(game.ReplicatedStorage.Framework.Library).PetCmds.Get(v.uid).hc and false;
            if #NameRainbow == 0 then 
                table.insert(NameRainbow,v.uid)
            end
            v26 = u4 and require(game.ReplicatedStorage.Framework.Library).Shared.RainbowMachineOdds.Hardcore or require(game.ReplicatedStorage.Framework.Library).Shared.RainbowMachineOdds.Normal
            v27 = v26[math.min(#NameRainbow, #v26)];
            if require(game.ReplicatedStorage.Framework.Library).Functions.FormatChance(v27.chance / 100) ~= "100%" and not table.find(NameRainbow,v.uid) then 
                table.insert(NameRainbow,v.uid)
            end
        end
    end
    if #NameRainbow > 0 then
        u4 = require(game.ReplicatedStorage.Framework.Library).PetCmds.Get(NameRainbow[1]).hc and false;
        v26 = u4 and require(game.ReplicatedStorage.Framework.Library).Shared.RainbowMachineOdds.Hardcore or require(game.ReplicatedStorage.Framework.Library).Shared.RainbowMachineOdds.Normal
        v27 = v26[math.min(#NameRainbow, #v26)];
        if require(game.ReplicatedStorage.Framework.Library).Functions.FormatChance(v27.chance / 100) == "100%"  then 
            return NameRainbow
        end
    end
    return 
end
function CheckpetRainbowShiny(p1)
    local NameRainbow = {}
    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if  v.sh  and not v.dm  and not v.l and  not v.r and v.g and v11.Pets[v.id].name == p1 then
            u4 = require(game.ReplicatedStorage.Framework.Library).PetCmds.Get(v.uid).hc and false;
            if #NameRainbow == 0 then 
                table.insert(NameRainbow,v.uid)
            end
            v26 = u4 and require(game.ReplicatedStorage.Framework.Library).Shared.RainbowMachineOdds.Hardcore or require(game.ReplicatedStorage.Framework.Library).Shared.RainbowMachineOdds.Normal
            v27 = v26[math.min(#NameRainbow, #v26)];
            if require(game.ReplicatedStorage.Framework.Library).Functions.FormatChance(v27.chance / 100) ~= "100%" and not table.find(NameRainbow,v.uid) then 
                table.insert(NameRainbow,v.uid)
            end
        end
    end
    if #NameRainbow > 0 then
        u4 = require(game.ReplicatedStorage.Framework.Library).PetCmds.Get(NameRainbow[1]).hc and false;
        v26 = u4 and require(game.ReplicatedStorage.Framework.Library).Shared.RainbowMachineOdds.Hardcore or require(game.ReplicatedStorage.Framework.Library).Shared.RainbowMachineOdds.Normal
        v27 = v26[math.min(#NameRainbow, #v26)];
        if require(game.ReplicatedStorage.Framework.Library).Functions.FormatChance(v27.chance / 100) == "100%"  then 
            return NameRainbow
        end
    end
    return 
end
function DetectNamepetMakeGold()
    local a = {}
    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if ((Toggles.MyTogglehcpet.Value and not v.hc) or not Toggles.MyTogglehcpet.Value) and ((Toggles.MyToggleIgnoreShiny.Value and not v.sh) or not Toggles.MyToggleIgnoreShiny.Value) and ((Toggles.MyToggleIgnoreMythicals.Value and not v11.Pets[v.id].rarity == "Mythical") or not Toggles.MyToggleIgnoreMythicals.Value) and not v.dm  and not v.l and not v.r and not v.g and not string.find(v11.Pets[v.id].name,"Huge") and  not table.find(a,v11.Pets[v.id].name) and v11.Pets[v.id].name   then 
            table.insert(a,v11.Pets[v.id].name)
        end
    end
    return a 
end
function DetectNamepetMakeRainbow()
    local a = {}
    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if ((Toggles.MyTogglehcpet.Value and not v.hc) or not Toggles.MyTogglehcpet.Value) and ((Toggles.MyToggleIgnoreShiny.Value and not v.sh) or not Toggles.MyToggleIgnoreShiny.Value) and ((Toggles.MyToggleIgnoreMythicals.Value and not v11.Pets[v.id].rarity == "Mythical") or not Toggles.MyToggleIgnoreMythicals.Value) and not v.dm and not v.l and not v.r and v.g and not string.find(v11.Pets[v.id].name,"Huge") and not table.find(a,v11.Pets[v.id].name) and v11.Pets[v.id].name   then 
            table.insert(a,v11.Pets[v.id].name)
        end
    end
    return a 
end
function AmountPetGolden()
    local a = {}
    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if   not v.l and v.g   then 
            table.insert(a,v.uid)
        end
    end
    return a 
end


spawn(function()
    while wait() do 
        pcall(function()
            if Toggles.MyToggleGolden.Value then
                if Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())) then return true end
                if  StartConvert  then
                    local mmb  
                    for i,v in next,DetectNamepetMakeGold() do
                        if CheckpetGolden(v) then 
                            mmb = CheckpetGolden(v)
                        end
                    end
                    if not mmb then 
                        for i,v in next,DetectNamepetMakeGold() do
                            if  CheckpetGoldenShiny(v) then  
                                mmb = CheckpetGoldenShiny(v)
                            end
                        end
                    end
                    if mmb then
                        StartConvert = true
                        if game:GetService("Workspace")["__MAP"].Interactive:FindFirstChild("Gold Machine") then 
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")["__MAP"].Interactive["Gold Machine"].Pad.CFrame 
                        else
                            TeleportIsland("Spawn")
                            return 
                        end
                        if game.Players.LocalPlayer:DistanceFromCharacter(game:GetService("Workspace")["__MAP"].Interactive["Gold Machine"].Pad.Position) <= 8 then 
                            local v3, v4 = Client.Network.Invoke("Use Golden Machine", FrameworkLibrary.Functions.DeepCopyUnsafe(mmb))
                        end
                    else
                        StartConvert = false
                    end
                elseif #FrameworkLibrary.Save.Get().Pets >= Options.MySliderPets.Value and not StartConvert then 
                    if Toggles.MyToggleGolden.Value then
                        local mmb  
                        for i,v in next,DetectNamepetMakeGold() do
                            if CheckpetGolden(v) then 
                                mmb = CheckpetGolden(v)
                            end
                        end
                        if not mmb then 
                            for i,v in next,DetectNamepetMakeRainbow() do
                                if  CheckpetGoldenShiny(v) then  
                                    mmb = CheckpetGoldenShiny(v)
                                end
                            end
                        end
                        if mmb then
                            StartConvert = true
                        end
                    end
                end
            end
        end)
    end
end)
spawn(function()
    while wait() do 
        pcall(function()
            if Toggles.MyToggleRainbow.Value then
                if Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())) then return true end
                if StartConvert and Toggles.MyToggleGolden.Value then  return end 
                if StartConvertRainbow then
                    local mmbb 
                    for i,v in next,DetectNamepetMakeRainbow() do
                        if  CheckpetRainbow(v) then  
                            mmbb = CheckpetRainbow(v)
                        end
                    end
                    if not mmbb then 
                        for i,v in next,DetectNamepetMakeRainbow() do
                            if  CheckpetRainbowShiny(v) then  
                                mmbb = CheckpetRainbowShiny(v)
                            end
                        end
                    end
                    if mmbb  then
                        StartConvertRainbow = true 
                        if game:GetService("Workspace")["__MAP"].Interactive:FindFirstChild("Rainbow Machine") then 
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")["__MAP"].Interactive["Rainbow Machine"].Pad.CFrame 
                        else
                            TeleportIsland("Spawn")
                            return 
                        end
                        if game.Players.LocalPlayer:DistanceFromCharacter(game:GetService("Workspace")["__MAP"].Interactive["Rainbow Machine"].Pad.Position) <= 8 then  
                            local v3, v4 = Client.Network.Invoke("Use Rainbow Machine", FrameworkLibrary.Functions.DeepCopyUnsafe(mmbb))
                        end
                    else
                        StartConvertRainbow = false
                    end
                elseif #AmountPetGolden() >= Options.MySliderPetsMakeRainbow.Value and not StartConvertRainbow then 
                    local mmbb 
                    for i,v in next,DetectNamepetMakeRainbow() do
                        if  CheckpetRainbow(v) then  
                            mmbb = CheckpetRainbow(v)
                        end
                    end
                    if not mmbb then 
                        for i,v in next,DetectNamepetMakeRainbow() do
                            if  CheckpetRainbowShiny(v) then  
                                mmbb = CheckpetRainbowShiny(v)
                            end
                        end
                    end
                    if mmbb then 
                        StartConvertRainbow = true 
                    end
                end
            end
        end)
    end
end)
local LeftroupBank = Tabs.Main:AddLeftGroupbox('Bank')
local bank1,bank2 = Client.Network.Invoke("Get My Banks")
local tableownerbank  = {}
local tableownerbank2  = {}
if bank1 then
    for i,v in next, bank1 do
        table.insert(tableownerbank,FrameworkLibrary.Functions.UserIdToUsername(v.Owner))
        tableownerbank2[FrameworkLibrary.Functions.UserIdToUsername(v.Owner)] = v.BUID
    end
end

LeftroupBank:AddDropdown('MyDropdownSelectNameBank', {
    Values = tableownerbank,
    Default = Settings["Select Bank"] or 0, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected
    Text = 'Select Bank',
    Callback = function(value)
        SaveSettings("Select Bank",value)
    end
})
local NamePetBank = {}
for i,v in next,v11.Pets do 
    table.insert(NamePetBank,v.name)
end
function DetectNamepets()
    local a = {}
    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if not v.l and not table.find(a,v11.Pets[v.id].name) then
            table.insert(a,v11.Pets[v.id].name)
        end
    end
    return a 
end
LeftroupBank:AddDropdown('MyDropdownSelectNamePet', {
    Values = DetectNamepets(),
    Default = 0, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected
    Text = 'Select Pets',
    Callback = function(value)
        SaveSettings("Select Pets Bank",value)
    end
})
LeftroupBank:AddSlider('MySliderPetsBank', {
    Text = 'Amount Pets',
    Default = Settings["Amount Pets Bank"] or 400,
    Min = 0,
    Max = 2000,
    Rounding = 0,
    Compact = false, 
    Callback = function(value)
        SaveSettings("Amount Pets Bank",value)
    end
})
Options.MyDropdownSelectNamePet:SetValue(Settings["Select Pets Bank"] or {})
LeftroupBank:AddButton("Refresh List",function()
    Options.MyDropdownSelectNamePet.Values = DetectNamepets()
    Options.MyDropdownSelectNamePet:SetValue(DetectNamepets()[0])
end)
LeftroupBank:AddToggle('MyToggleAutoBank', {
    Text = 'Auto Deposit',
    Default = Settings["Auto Deposit"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Auto Deposit",value)
    end
})

LeftroupBank:AddToggle('MyToggleAutoBankGolden', {
    Text = 'Golden',
    Default = Settings["Golden Bank"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Golden Bank",value)
    end
})
LeftroupBank:AddToggle('MyToggleAutoBankRainbow', {
    Text = 'Rainbow',
    Default = Settings["Rainbow Bank"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Rainbow Bank",value)
    end
})

LeftroupBank:AddToggle('MyToggleAutoWithdraw', {
    Text = 'Auto Withdraw[Only Sell Pet]',
    Default = Settings["Auto Withdraw"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Auto Withdraw",value)
    end
})
LeftroupBank:AddToggle('MyToggleAutoBankShiny', {
    Text = 'Ignore Shiny[Only Withdraw]',
    Default = Settings["Rainbow Bank"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Rainbow Bank",value)
    end
})

function AutoDeposit()
    local a = {}
    local b = {}

    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if #a < 50 and not v.l and  not table.find(GetEquippedPets(),v.uid) and Options.MyDropdownSelectNamePet.Value[v11.Pets[v.id].name] and ((Toggles.MyToggleAutoBankGolden.Value and v.g) or (Toggles.MyToggleAutoBankRainbow.Value and v.r)) then
            table.insert(a,v.uid)
        end
    end
    return a 
end
spawn(function()
    while wait() do 
        if Toggles.MyToggleAutoBank.Value then 
            pcall(function()
                if Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())) then return true end
                if StartConvert and Toggles.MyToggleGolden.Value  then return true end
                if StartConvertRainbow and   Toggles.MyToggleRainbow.Value then return true end
                if  StartBank then
                    if #AutoDeposit() <= 50 and #AutoDeposit() > 0 then
                        if game:GetService("Workspace")["__MAP"].Interactive:FindFirstChild("Bank") then 
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")["__MAP"].Interactive.Bank.Pad.CFrame 
                        else
                            TeleportIsland("Spawn")
                            return 
                        end
                        local v12, v13 = Client.Network.Invoke("Bank Deposit", tableownerbank2[Options.MyDropdownSelectNameBank.Value], AutoDeposit(), 0)
                    else
                        StartBank = false 
                    end
                elseif  #FrameworkLibrary.Save.Get().Pets >= Options.MySliderPetsBank.Value and not StartBank and #AutoDeposit() <= 50 and #AutoDeposit() > 0 then 
                    StartBank = true
                end
            end)
        end
    end
end)
local RightGroupDayCare = Tabs.Main:AddRightGroupbox('DayCare')
RightGroupDayCare:AddDropdown('MyDropdownSelectNamePetDayCare', {
    Values = DetectNamepets(),
    Default = 0, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected
    Text = 'Select Pets',
    Callback = function(value)
        SaveSettings("Select Pets Daycare",value)
    end
})
Options.MyDropdownSelectNamePetDayCare:SetValue(Settings["Select Pets Daycare"] or {})
RightGroupDayCare:AddButton("Refresh List",function()
    Options.MyDropdownSelectNamePetDayCare.Values = DetectNamepets()
    Options.MyDropdownSelectNamePetDayCare:SetValue({})
end)
RightGroupDayCare:AddToggle('MyToggleAutoEnroll', {
    Text = 'Auto DayCare',
    Default = Settings["Auto DayCare"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Auto DayCare",value)
    end
})
RightGroupDayCare:AddToggle('MyToggleGoldenEnroll', {
    Text = 'Select Golden',
    Default = Settings["Select Golden Enroll"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Select Golden Enroll",value)
    end
})
RightGroupDayCare:AddToggle('MyToggleRainbowEnroll', {
    Text = 'Select Rainbow',
    Default = Settings["Select Rainbow Enroll"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Select Rainbow Enroll",value)
    end
})
RightGroupDayCare:AddToggle('MyToggleMatterEnroll', {
    Text = 'Select Matter',
    Default = Settings["Select Matter Enroll"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Select Matter Enroll",value)
    end
})
function DetectPetEnroll()
    local b = {}
    for i,v in next,FrameworkLibrary.Save.Get().Pets do
        if not table.find(GetEquippedPets(),v.uid)  and ((game.PlaceId == 10321372166 and v.hc) or game.PlaceId ~= 10321372166) and #b < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and not v.l  and Options.MyDropdownSelectNamePetDayCare.Value[v11.Pets[v.id].name]  then
            table.insert(b,v.uid)
        end
    end
    return b
end

function CheckTimeDayCare()
    local v65 = require(game.ReplicatedStorage.Library).Save.Get();
    assert(v65);
    local v67
	if require(game.ReplicatedStorage.Library).Shared.IsHardcore then
		v67 = v65.DaycareHardcoreQueue;
	else
		v67 = v65.DaycareQueue;
	end;
    for i,v in next,v67 do 
        local u13 = require(game.ReplicatedStorage.Library).Shared.DaycareComputeRemainingTime(v65, v)
        if u13 == 0 then 
            return  true 
        end
    end
end
function AutoDayCare()
    if Toggles.MyToggleSentGems.Value and game.Players.LocalPlayer.leaderstats.Diamonds.Value >= 200000000000 then  return true end  
    if CheckTimeDayCare() then 
        if game:GetService("Workspace")["__MAP"].Interactive:FindFirstChild("Daycare") then 
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")["__MAP"].Interactive.Daycare.Pad.CFrame 
        else
            TeleportIsland("Spawn")
            return 
        end
        local v154, v155, v156, v157, v158 = Client.Network.Invoke("Daycare: Claim", nil)
        wait(5)
    elseif getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and #DetectPetEnroll() > 0 then 
        print(true)
        if game:GetService("Workspace")["__MAP"].Interactive:FindFirstChild("Daycare") then 
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")["__MAP"].Interactive.Daycare.Pad.CFrame 
        else
            TeleportIsland("Spawn")
            return 
        end
        local v150, v151, v152 = Client.Network.Invoke("Daycare: Enroll", DetectPetEnroll())
    end
end

spawn(function()
    while wait() do 
        if Toggles.MyToggleAutoEnroll.Value then
            pcall(function()
				if Toggles.MyToggleSentGems.Value and game.Players.LocalPlayer.leaderstats.Diamonds.Value >= 200000000000 then  return true end  
                AutoDayCare()
            end)
        end
    end
end)
--print(getsenv(game:GetService("Players").VyPigs.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots())
if game.PlaceId == 7722306047 then
    local LeftGroupSellPet = Tabs.MainSellpet:AddLeftGroupbox('Main')
    LeftGroupSellPet:AddDropdown('MyDropdownSelectNamePetSell', {
        Values = DetectNamepets(),
        Default = Settings["Select Pet Sell"] or 0, -- number index of the value / string
        Multi = false, -- true / false, allows multiple choices to be selected
        Text = 'Select Pet',
        Callback = function(value)
            SaveSettings("Select Pet Sell",value)
        end
    })
    LeftGroupSellPet:AddButton("Refresh List",function()
        Options.MyDropdownSelectNamePetSell.Values = DetectNamepets()
        Options.MyDropdownSelectNamePetSell:SetValue(DetectNamepets()[0])
    end)
    LeftGroupSellPet:AddSlider('MySliderPetsSell', {
        Text = 'Amount Sell Pet',
        Default = Settings["Amount Sell Pet"] or 10,
        Min = 0,
        Max = 1000,
        Rounding = 0,
        Compact = false,
        Callback = function(value)
            SaveSettings("Amount Sell Pet",value)
        end 
    })
    LeftGroupSellPet:AddInput('MyTextbox', {
        Default = Settings["Input amount Gems Sell"] or '',
        Numeric = true, -- true / false, only allows numbers
        Finished = false, -- true / false, only calls callback when you press enter
        Text = 'Input amount Gems Sell',
        Callback = function(value)
            SaveSettings("Input amount Gems Sell",value)
        end
    })
    LeftGroupSellPet:AddToggle('MyToggleAutoSellPet', {
        Text = 'Auto Sell',
        Default = Settings["Auto Sell"] or false, -- Default value (true / false)
        Callback = function(value)
            SaveSettings("Auto Sell",value)
        end
    })
    
    --local v7, v8 = v1.Network.Invoke("Add Trading Booth Pet", v3);
    local idBooth = 0
    function GetPathBooth()
        for i,v in next,game:GetService("Workspace")["__MAP"].Interactive.Booths:GetChildren() do 
            if v:IsA("Model") then 
                if v.Booth:FindFirstChild("YourBoothAttachment") then 
                    return v 
                end
            end
        end
    end
    function ClaimBooth()
        local v82 = Client.Network.Invoke("Get All Booths");
        local a = false
        for i = 1,100 do 
            if not v82[i] and not a then
                print(i)
                idBooth = i
                a = true
                local v49, v50 = Client.Network.Invoke("Claim Trading Booth", i)
            end
        end
    end
    function DetectInventoryPetSell()
        local v6, v7 = Client.Network.Invoke("Get Booth By Id", idBooth)
        local abc = {}
        for i,v in next,v7.Listings do 
            table.insert(abc,i)
        end
        return abc
    end
    function DetectPetSell()
        for i,v in next,FrameworkLibrary.Save.Get().Pets do
            if   not v.l and  v11.Pets[v.id].name ==  Options.MyDropdownSelectNamePetSell.Value and not table.find(DetectInventoryPetSell(),v.uid) then 
                return v.uid 
            end
        end
    end
    function GetInventoryPetBank()
        local a = {}
        local v288, v289 = Client.Network.Invoke("Get Bank", tableownerbank2[Options.MyDropdownSelectNameBank.Value])
        for i,v in next,v288.Storage.Pets do 
            if Options.MyDropdownSelectNamePetSell.Value == v11.Pets[v.id].name and ((Toggles.MyToggleAutoBankShiny.Value and not v.sh) or not Toggles.MyToggleAutoBankShiny.Value) and  ((Toggles.MyToggleAutoBankGolden.Value and v.g) or (Toggles.MyToggleAutoBankRainbow.Value and v.r)) then 
                local Amount = FrameworkLibrary.Save.Get().MaxSlots - #FrameworkLibrary.Save.Get().Pets
                if Amount >= 50 then 
                    Amount = 50 
                end 
                if  #a < Amount then 
                    table.insert(a,v.uid)
                end
            end
        end
        return a 
    end
    function AutoWithdraw()
        for i,v in next,FrameworkLibrary.Save.Get().Pets do
            if   not v.l and not table.find(GetEquippedPets(),v.uid) and not table.find(DetectInventoryPetSell(),v.uid) and Options.MyDropdownSelectNamePetSell.Value == v11.Pets[v.id].name  then
                return true
            end
        end
    end
    local WithdrawStop = false
    function SellPet()
        if GetPathBooth() then
            if Toggles.MyToggleAutoWithdraw.Value then 
                if WithdrawStop then 
                    if #FrameworkLibrary.Save.Get().Pets < Options.MySliderPetsBank.Value then
                        if FrameworkLibrary.Save.Get().MaxSlots == #FrameworkLibrary.Save.Get().Pets then 
                            WithdrawStop = false
                            return
                        end
                        if game:GetService("Workspace")["__MAP"].Interactive:FindFirstChild("Bank") then 
                            if #GetInventoryPetBank() > 0 then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")["__MAP"].Interactive.Bank.Pad.CFrame
                                if game.Players.LocalPlayer:DistanceFromCharacter(game:GetService("Workspace")["__MAP"].Interactive.Bank.Pad.Position) < 10 then
                                    local v12, v13 = Client.Network.Invoke("Bank Withdraw", tableownerbank2[Options.MyDropdownSelectNameBank.Value], GetInventoryPetBank(), 0)
                                    wait(2)
                                end
                            end
                            return
                        end
                    else
                        WithdrawStop = false
                    end
                elseif not WithdrawStop and not AutoWithdraw() then 
                    WithdrawStop = true
                end
            end
            if #DetectInventoryPetSell() < Options.MySliderPetsSell.Value then 
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = GetPathBooth().Booth.CFrame 
                Client.Network.Invoke("Add Trading Booth Pet", {{DetectPetSell(),tonumber(Options.MyTextbox.Value)}})
            end
        else
            ClaimBooth()
            repeat wait()
            until GetPathBooth() 
        end
    end
    spawn(function()
        while wait() do 
            if Toggles.MyToggleAutoSellPet.Value then 
                pcall(function()
                    SellPet()
                end)
            end
        end
    end)
    local RightGroupSellPetOther = Tabs.MainSellpet:AddRightGroupbox('Other')
    RightGroupSellPetOther:AddToggle('MyToggleAutoChat', {
        Text = 'Auto Chat',
        Default = Settings["Auto Chat"] or false, -- Default value (true / false)
        Callback = function(value)
            SaveSettings("Auto Chat",value)
        end
    })
    RightGroupSellPetOther:AddInput('MyTextboxChat', {
        Default = Settings["Input Chat"] or '',
        Numeric = false, -- true / false, only allows numbers
        Finished = false, -- true / false, only calls callback when you press enter
        Text = 'Input Chat',
        Callback = function(value)
            SaveSettings("Input Chat",value)
        end
    })
    spawn(function()
        while wait() do 
            pcall(function()
                if Toggles.MyToggleAutoChat.Value then 
                    local CB = finddescendantnamed(game.Players.LocalPlayer.PlayerGui,'ChatBar')
                    CB:CaptureFocus()
                    CB.Text = tostring(Options.MyTextboxChat.Value);
                    CB:ReleaseFocus(true)
                    wait(20)
                end
            end)
        end
    end)
end

local LeftGroupBoost = Tabs.MainBoost:AddLeftGroupbox('Main')
local NameBoost = {}
for i,v in next,FrameworkLibrary.GUI.ExclusiveShop.Container.Boosts:GetChildren() do
    if v.Name == "Boost" then 
       table.insert(NameBoost,v:GetAttribute("Boost")) 
    end
end
LeftGroupBoost:AddDropdown('MyDropdownSelectBoost', {
    Values = NameBoost,
    Default = 0, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected
    Text = 'Select Boost',
    Callback = function(value)
        SaveSettings("Select Boost",value)
    end
})
Options.MyDropdownSelectBoost:SetValue(Settings["Select Boost"] or {})
LeftGroupBoost:AddToggle('MyToggleAutoBoost', {
    Text = 'Auto Boost',
    Default = Settings["Auto Boost"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Auto Boost",value)
    end
})
LeftGroupBoost:AddToggle('MyToggleAutoBoostServer', {
    Text = 'Auto Boost Server',
    Default = Settings["Auto Boost Server"] or false, -- Default value (true / false)
    Callback = function(value)
        SaveSettings("Auto Boost Server",value)
    end
})
function DetectBoost()
    for i,v in next,Options.MyDropdownSelectBoost.Value do 
        if not FrameworkLibrary.Save.Get().Boosts[i] then 
            return i 
        end
    end
end
function DetectBoostServer()
    for i,v in next,Options.MyDropdownSelectBoost.Value do 
        if not FrameworkLibrary.ServerBoosts.GetActiveBoosts()[i] then 
            return i 
        end
    end
end
spawn(function()
    while wait() do 
        if Toggles.MyToggleAutoBoost.Value then 
            pcall(function()
                if DetectBoost()  then
                    local ggs = DetectBoost()
                    Client.Network.Fire("Activate Boost", ggs)
                    repeat wait()
                    until FrameworkLibrary.Save.Get().Boosts[ggs] or not Toggles.MyToggleAutoBoost.Value
                end
            end)
        end
    end
end)
spawn(function()
    while wait() do 
        if Toggles.MyToggleAutoBoostServer.Value then 
            pcall(function()
                if DetectBoostServer()  then
                    local ggs = DetectBoostServer()
                    Client.Network.Fire("Activate Server Boost", ggs)
                    repeat wait()
                    until FrameworkLibrary.ServerBoosts.GetActiveBoosts()[ggs] or not Toggles.MyToggleAutoBoostServer.Value
                end
            end)
        end
    end
end)
local RightGroupBoost = Tabs.MainBoost:AddRightGroupbox('Send Gems')
RightGroupBoost:AddInput('MyTextboxUserName', {
    Default = Settings["Input UserName"] or '',
    Numeric = false, -- true / false, only allows numbers
    Finished = false, -- true / false, only calls callback when you press enter
    Text = 'Input UserName',
    Callback = function(value)
        SaveSettings("Input UserName",value)
    end
})
RightGroupBoost:AddToggle('MyToggleSentGems', {
    Text = 'Send Gems',
    Default = Settings["Send Gems"] or false,
    Callback = function(value)
        SaveSettings("Send Gems",value)
    end
})
function ComposeMail(name,Diamond)	
	return {
		Recipient = tostring(name), 
		Message = "", 
		Pets = {}, 
		Diamonds = Diamond,
	};
end;
spawn(function()
    while wait() do 
        if Toggles.MyToggleSentGems.Value then 
            pcall(function()
                if game.Players.LocalPlayer.leaderstats.Diamonds.Value >= 10000000000 then
                    if (game.workspace.__MAP.Interactive.Mailbox.Pad.Position-game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 8 then 
                        
                       local v1,v2 = Client.Network.Invoke("Send Mail",ComposeMail(Options.MyTextboxUserName.Value,game.Players.LocalPlayer.leaderstats.Diamonds.Value-100000))
                       print(v1,v2)
                    else
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.workspace.__MAP.Interactive.Mailbox.Pad.CFrame
                    end
                end
            end)
        end
    end
end)

--v68,v69  = Client.Network.Invoke("Send Mail",ComposeMail(name,Diamond))

local SkipPlayer = Instance.new("TextButton")
SkipPlayer.Name = "SkipPlayer"
SkipPlayer.Parent = game:GetService("Players").LocalPlayer.PlayerGui.Main
SkipPlayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SkipPlayer.Position = UDim2.new(0.45, 0, -0, 10);
SkipPlayer.Size = UDim2.new(0, 200, 0, 50)
SkipPlayer.Font = Enum.Font.SourceSans
SkipPlayer.Text = "On/Off"
SkipPlayer.TextColor3 = Color3.fromRGB(0, 0, 0)
SkipPlayer.TextScaled = true
SkipPlayer.TextSize = 14.000
SkipPlayer.TextWrapped = true
SkipPlayer.MouseButton1Click:Connect(function()
	task.spawn(Library.Toggle)
end)


if getgenv().HideUI then 
    task.spawn(Library.Toggle)
end 

--[[local Client = require(game.ReplicatedStorage.Library.Client)
local FrameworkLibrary = require(game.ReplicatedStorage.Framework.Library)
FrameworkLibrary.Signal.Invoke("Get Diamond Mine Collpase Time")
local v11 = require(game.ReplicatedStorage.Library.Directory);
getrenv().require = getgenv().require -- method tvk hihi (iu tvk vcl)
debug.setupvalue(Client.Network.Invoke, 1, function() return true end)
debug.setupvalue(Client.Network.Fire, 1, function() return true end)
for i,v in next,FrameworkLibrary.WorldCmds.GetMap():WaitForChild("EasterEggs"):GetChildren() do
    if v.Egg.Transparency ~= 1 then 
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Egg.CFrame
        Client.Network.Invoke("Easter Egg Hunt: Claim", v.Name, (v:GetAttribute("TextureIDX")));
    end
end
]]
