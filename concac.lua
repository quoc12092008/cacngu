repeat wait()
until game:IsLoaded() and game.Players.LocalPlayer
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
    Max = 60,
    Rounding = 0,
    Compact = false, 
    Callback = function(value)
        SaveSettings("Time Rejoin",value)
    end
})
spawn(function()
    while wait() do 
        pcall(function()
            if Options.MySliderTimeRejoin.Value then
                local TimeDelay = tick()
                repeat wait() until tick()-TimeDelay >= Options.MySliderTimeRejoin.Value*60 
                game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
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
function DetectFruit(x)
    local xxx = {}
    for v5,v6 in next, require(game.ReplicatedStorage.Framework.Library).FruitCmds.Directory do
        if v5 ~= "Rainbow" and require(game.ReplicatedStorage.Framework.Library).FruitCmds.Get(require(game.ReplicatedStorage.Framework.Library).LocalPlayer, v6) < x then
            table.insert(xxx,v5)
        end
    end
    return xxx
end

local FarmFruit = false
spawn(function()
    while wait() do 
        pcall(function()
            if Toggles.MyToggleFarm2Map.Value then 
                if map1 then
                    SendAllPetAreaFarm2Map = Toggles.MyToggleFarmSendAllPet1.Value 
                    NameAreaFarm2Map  = Options.MyDropdownSelectAreas.Value 
                    SpeedFarmAreaFarm2Map = Options.MySliderSpeedFarm1.Value
                    local timeDelay = tick()
                    repeat wait() until (not Toggles.MyToggleFarmFruit.Value and tick()-timeDelay >= Options.MySliderTimeMap1.Value*60) 
                    or not Toggles.MyToggleFarm2Map.Value 
                    or (Toggles.MyToggleFarmFruit.Value and not FarmFruit)
                    print("map1")
                    map1 = false
                elseif map2 then 
                    SendAllPetAreaFarm2Map = Toggles.MyToggleFarmSendAllPet2.Value 
                    NameAreaFarm2Map  = Options.MyDropdownSelectAreas2.Value
                    SpeedFarmAreaFarm2Map = Options.MySliderSpeedFarm2.Value
                    local timeDelay = tick()
                    repeat wait() until (tick()-timeDelay >= Options.MySliderTimeMap2.Value*60 and not Toggles.MyToggleFarmFruit.Value) 
                    or not Toggles.MyToggleFarm2Map.Value
                    or (Toggles.MyToggleFarmFruit.Value and FarmFruit)
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
                if #DetectFruit(200) == 0  and FarmFruit then 
                    FarmFruit = false
                elseif #DetectFruit(Options.MySliderTimeMap1.Value) == 5 then 
                    FarmFruit = true  
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
    for i,v in next,game:GetService("ReplicatedStorage")["__DIRECTORY"].Coins:GetDescendants() do 
        if v.Name == Options.MyDropdownSelectAreas.Value then 
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
        if v.a == Options.MyDropdownSelectAreas.Value and workspace.__THINGS.Coins:FindFirstChild(i) and Options.MyDropdownSelectChest.Value[v.n]  then 
            return i 
        end 
    end 
end 
function GetEquippedPets()
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
    if Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())) then return true end
    if StartBank and Toggles.MyToggleAutoBank.Value then return true end 
    if StartConvert and Toggles.MyToggleGolden.Value  then return true end
    if StartConvertRainbow and   Toggles.MyToggleRainbow.Value then return true end
end

function AutoChest()
    if StopFarm() then  return end
    local v17 = require(game.ReplicatedStorage.Framework.Library).Directory.Areas[Options.MyDropdownSelectAreas.Value]
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
            TeleportInChest = false
            repeat wait() until not workspace.__THINGS.Coins:FindFirstChild(IDChest) or not Toggles.MyToggleFarmChest.Value or StopFarm() or workspace.__THINGS.Coins:FindFirstChild(i).POS.HUD.ProgressText.Text == "0"
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
function GetCoins(Area)
    local Coins = {}
    for i,v in next, Client.Network.Invoke('Get Coins') do 
        if v.a == Area  and ((Area == "Mystic Mine" and v.n ~= "Mystic Mine Diamond Mine Giant Chest") or Area ~= "Mystic Mine") and workspace.__THINGS.Coins:FindFirstChild(i) and ((workspace.__THINGS.Coins[i].POS:FindFirstChild("HUD") and workspace.__THINGS.Coins:FindFirstChild(i).POS.HUD.ProgressText.Text ~= "0") or not workspace.__THINGS.Coins[i]:FindFirstChild("HUD")) and v.h > 0    then
            table.insert(Coins,i)
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
        if v.a == Area and v.b and ((Area == "Mystic Mine" and v.n ~= "Mystic Mine Diamond Mine Giant Chest") or Area ~= "Mystic Mine") and workspace.__THINGS.Coins:FindFirstChild(i) and ((workspace.__THINGS.Coins[i].POS:FindFirstChild("HUD") and workspace.__THINGS.Coins:FindFirstChild(i).POS.HUD.ProgressText.Text ~= "0") or not workspace.__THINGS.Coins[i]:FindFirstChild("HUD")) and v.h > 0    then
            table.insert(Coins,i)
        end 
    end 
    return Coins
end  
function AutoFarmAllCoins()
    if Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())) then return true end
    local NameAreass  = Options.MyDropdownSelectAreas.Value
    if Toggles.MyToggleFarm2Map.Value and NameAreaFarm2Map then 
        NameAreass = NameAreaFarm2Map
    end
    local SpeedFarm = Options.MySliderSpeedFarm1.Value
    if Toggles.MyToggleFarm2Map.Value then 
        SpeedFarm  = SpeedFarmAreaFarm2Map
    end
    getgenv().mmmmmmb = NameAreass
    local v17 = require(game.ReplicatedStorage.Framework.Library).Directory.Areas[NameAreass]
    if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() ~= v17.world then
        TeleportIsland(NameAreass)
        return 
    end
    local SendAllPetttt = Toggles.MyToggleFarmSendAllPet1.Value 
    if Toggles.MyToggleFarm2Map.Value then 
        SendAllPetttt  = SendAllPetAreaFarm2Map
    end 
    if SendAllPetttt then
        local GetCoinallll = (GetIdFruit(NameAreass) and FarmFruit)  or (#GetCoinsMulti(NameAreass) > 0 and GetCoinsMulti(NameAreass)) or GetCoins(NameAreass)
        if #GetCoinallll > 0 then
            getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport(NameAreass,true)
            for i,v in next,GetCoinallll do
                if plr:DistanceFromCharacter(workspace.__THINGS.Coins:FindFirstChild(v).POS.Position) > 500 then
                    plr.Character.HumanoidRootPart.CFrame = workspace.__THINGS.Coins:FindFirstChild(v).POS.CFrame 
                end
                Client.Network.Invoke('Join Coin', v, GetEquippedPets())
                for i1,v1 in next,GetEquippedPets() do
                    Client.Network.Fire('Farm Coin', v,v1)
                end
                repeat wait() until  not Toggles.MyToggleFarmAllCoins.Value  or not workspace.__THINGS.Coins:FindFirstChild(v) or workspace.__THINGS.Coins:FindFirstChild(v).POS.HUD.ProgressText.Text == "0" or (Toggles.MyToggleFarm2Map.Value and NameAreass ~= NameAreaFarm2Map) or (Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll()))) 
            end
        end
    else
        getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Teleport).Teleport(NameAreass,true)
        spawn(function()
            local Pets = GetEquippedPets()
            local countCoins = 0
            local countPet = 1
            local Coins = GetCoins(NameAreass)
            for i,v in next, Coins do
                countCoins = countCoins + 1
                countPet = countPet + 1
                if #Pets <= countPet then
                    countPet = 1 
                end
                local uidpet = Pets[countPet]
                Client.Network.Invoke('Join Coin', v, {uidpet})
                Client.Network.Fire('Farm Coin', v, uidpet)
                task.wait(SpeedFarm)
            end
        end)
            repeat wait() until countCoins >= #Coins or not CheckHUD() or not Toggles.MyToggleFarmAllCoins.Value  or (Toggles.MyToggleFarm2Map.Value and NameAreass ~= NameAreaFarm2Map) or (Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())))
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
        if Toggles.MyToggleFarmChest.Value then 
            pcall(function()
                AutoChest()
            end)
        end
    end
end)

workspace.__THINGS.Orbs.ChildAdded:Connect(function(v)
    if Toggles.MyToggleCollect.Value then
        Orbs.Collect(v)
    end
end)

workspace.__THINGS.Lootbags.ChildAdded:Connect(function(v)
    if Toggles.MyToggleCollect.Value then
        Lootbags.Collect(v)
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
function format(num, digits)
	return string.format("%0" .. digits .. "i", num)
end
function parseDateTime()
	local osDate = os.date("!*t")
	local year, mon, day = osDate["year"], osDate["month"], osDate["day"]
	local hour, min, sec = osDate["hour"], osDate["min"], osDate["sec"]
	return year .. "-" .. format(mon, 2) .. "-" .. format(day, 2) .. "T" .. format(hour, 2) .. ":" .. format(min, 2) .. ":" .. format(sec, 2) .. "Z"
end
function sendWebhook(url,x)
    local dt = DateTime.now()
    local timestamp = dt:FormatUniversalTime("LL", "vi-vn")
    local now = DateTime.now()
    local timestamp2 = now:FormatLocalTime("LT", "vi-vn") 
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
function DetectEggIsland()
    local a 
    for i,v in next,require(game.ReplicatedStorage.Library.Directory).Areas do 
        if v.name == Options.MyDropdownSelectAreas.Value then 
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
            table.insert(b,v.Name)
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
function DetectPartEgg()
    local a 
    for i,v in next, game:GetService("ReplicatedStorage")["__DIRECTORY"].Eggs:GetDescendants() do 
        if v:IsA("Folder") and v.Name == Options.MyDropdownSelectEgg.Value then 
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
function OpenEggg()
    if Toggles.MyToggleAutoEnroll.Value and (CheckTimeDayCare() or (getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetUsedSlots() < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and DetectPetEnroll())) then return true end
    if StartConvert and Toggles.MyToggleGolden.Value  then  return end
    if StartConvertRainbow and   Toggles.MyToggleRainbow.Value then return true end
    if StartBank and Toggles.MyToggleAutoBank.Value then return true end 
    if Toggles.MyToggleFarmChest.Value and TeleportInChest  then   return end 
    local v17 = require(game.ReplicatedStorage.Framework.Library).Directory.Areas[Options.MyDropdownSelectAreas.Value]
    if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() ~= v17.world then
        TeleportIsland(Options.MyDropdownSelectAreas.Value)
    else
        if Options.MyDropdownSelectEgg.Value == "Diamond Error Egg" then 
            if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position-game:GetService("Workspace")["__MAP"].Eggs["April Fools Secret Eggs"].PLATFORM.Pad.Position).Magnitude > 100 then 
                local CB = finddescendantnamed(game.Players.LocalPlayer.PlayerGui,'ChatBar')
                CB:CaptureFocus()
                CB.Text = "pls";
                CB:ReleaseFocus(true)
                wait(5)
                return
            end
        end
        local partEgg = DetectPartEgg().Parent.Parent.Parent.PLATFORM.Pad
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
Options.MyDropdownSelectAreas:OnChanged(function()
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
        if ((Toggles.MyToggleGoldenEnroll.Value and v.g) or (Toggles.MyToggleRainbowEnroll.Value and v.r) or (Toggles.MyToggleMatterEnroll.Value and v.dm) or (not Toggles.MyToggleGoldenEnroll.Value and not Toggles.MyToggleRainbowEnroll.Value and not Toggles.MyToggleMatterEnroll.Value)) and ((game.PlaceId == 10321372166 and v.hc) or game.PlaceId ~= 10321372166) and #b < getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Daycare).GetMaxSlots() and not v.l and  not table.find(GetEquippedPets(),v.uid) and Options.MyDropdownSelectNamePetDayCare.Value[v11.Pets[v.id].name]  then
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
                if DetectBoost() then
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
                if DetectBoostServer() then
                    local ggs = DetectBoostServer()
                    Client.Network.Fire("Activate Server Boost", ggs)
                    repeat wait()
                    until FrameworkLibrary.ServerBoosts.GetActiveBoosts()[ggs] or not Toggles.MyToggleAutoBoostServer.Value
                end
            end)
        end
    end
end)
spawn(function()
    while wait() do 
        pcall(function()
            local timedelayHideui = tick()
            repeat wait()
            until tick()-timedelayHideui >= 60
            task.spawn(Library.Toggle)
        end)
    end
end)

--[[local Client = require(game.ReplicatedStorage.Library.Client)
local FrameworkLibrary = require(game.ReplicatedStorage.Framework.Library)
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
