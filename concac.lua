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
}
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
wait(1)
vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)
local LeftGroupFarm = Tabs.Main:AddLeftGroupbox('Main')
local Client = require(game.ReplicatedStorage.Library.Client)
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
            if val['hidden'] then break end;
            if not table.find(areas, val['name']) then
                table.insert(areas, val['name'])
            end
        end
    end
end
LeftGroupFarm:AddDropdown('MyDropdownSelectAreas', {
    Values = areas,
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected
    Text = 'Select Areas',

})
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
    Default = 0, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected
    Text = 'Select Chest',
})
LeftGroupFarm:AddToggle('MyToggleFarmChest', {
    Text = 'Farm Chest',
    Default = false, -- Default value (true / false)
})
LeftGroupFarm:AddToggle('MyToggleCollect', {
    Text = 'Collect Orbs/Lootbags',
    Default = false, -- Default value (true / false)
})
function GetChest()
    for i,v in next, Client.Network.Invoke('Get Coins') do 
        if v.a == Options.MyDropdownSelectAreas.Value and Options.MyDropdownSelectChest.Value[v.n]  then 
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
function StopFarm()
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
            repeat wait() until not workspace.__THINGS.Coins:FindFirstChild(IDChest) or not Toggles.MyToggleFarmChest.Value or StopFarm()
        end
    end
end
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
local FrameworkLibrary = require(game.ReplicatedStorage.Framework.Library)
local v11 = require(game.ReplicatedStorage.Library.Directory);
function DetectEggIsland()
    local a 
    for i,v in next,require(game.ReplicatedStorage.Library.Directory).Areas do 
        if v.name == Options.MyDropdownSelectAreas.Value then 
            a = v.world
        end
    end
    local b = {}
    for i,v in next,game:GetService("ReplicatedStorage")["__DIRECTORY"].Eggs:GetChildren() do
        if string.find(v.Name,a) then 
            for i1,v1 in next,v:GetChildren() do 
                table.insert(b,v1.Name)
            end
        end
    end
    return b
end
RightroupPet:AddDropdown('MyDropdownSelectEgg', {
    Values = DetectEggIsland() ,
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected
    Text = 'Select Egg',

})
RightroupPet:AddDropdown('MyDropdownSelectOpenEgg', {
    Values = {"1","3","10"},
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected
    Text = 'Select Amount Open Egg',
})
RightroupPet:AddToggle('MyToggleOpenEgg', {
    Text = 'Open Egg',
    Default = false, 
})
RightroupPet:AddButton("Disable Egg Animation",function()
    for i,v in pairs(getgc(true)) do
        if (typeof(v) == 'table' and rawget(v, 'OpenEgg')) then
            v.OpenEgg = function()
                return
            end
        end
    end
end)
function OpenEggg()
    if StartConvert and Toggles.MyToggleGolden.Value  then  return end
    if StartConvertRainbow and   Toggles.MyToggleRainbow.Value then return true end
    if Toggles.MyToggleFarmChest.Value and TeleportInChest  then   return end 
    local v17 = require(game.ReplicatedStorage.Framework.Library).Directory.Areas[Options.MyDropdownSelectAreas.Value]
    if require(game.ReplicatedStorage.Framework.Library).WorldCmds.Get() ~= v17.world then
        TeleportIsland(Options.MyDropdownSelectAreas.Value)
    else
        local partEgg = game:GetService("Workspace")["__MAP"].Eggs[require(game.ReplicatedStorage.Library.Directory).Eggs[Options.MyDropdownSelectEgg.Value].area.." Eggs"].PLATFORM.Pad
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
Options.MyDropdownSelectAreas:OnChanged(function()
    Options.MyDropdownSelectChest.Values = DetectChestIsland()
    Options.MyDropdownSelectChest:SetValue({})
    Options.MyDropdownSelectEgg.Values = DetectEggIsland()
    Options.MyDropdownSelectEgg:SetValue({})
end)
RightroupPet:AddSlider('MySliderPets', {
    Text = 'Amount Pets',
    Default = 400,
    Min = 0,
    Max = 2000,
    Rounding = 0,
    Compact = false, 
})
RightroupPet:AddToggle('MyToggleGolden', {
    Text = 'Golden Pet',
    Default = false, -- Default value (true / false)
})
RightroupPet:AddToggle('MyToggleRainbow', {
    Text = 'RainBow Pet',
    Default = false, -- Default value (true / false)
})
RightroupPet:AddToggle('MyTogglehcpet', {
    Text = 'Ignore HC pet',
    Default = false, -- Default value (true / false)
})
RightroupPet:AddToggle('MyToggleIgnoreMythicals', {
    Text = 'Ignore Mythical',
    Default = false, -- Default value (true / false)
})
RightroupPet:AddToggle('MyToggleIgnoreShiny', {
    Text = 'Ignore Shiny',
    Default = false, -- Default value (true / false)
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



spawn(function()
    while wait() do 
        pcall(function()
            if Toggles.MyToggleGolden.Value then
                if  StartConvert  then
                    local mmb  
                    for i,v in next,DetectNamepetMakeGold() do
                        if CheckpetGolden(v) then 
                            mmb = CheckpetGolden(v)
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
                if StartConvert and Toggles.MyToggleGolden.Value then  return end 
                local mmbb 
                for i,v in next,DetectNamepetMakeRainbow() do
                    if  CheckpetRainbow(v) then  
                        mmbb = CheckpetRainbow(v)
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
            end
        end)
    end
end)
