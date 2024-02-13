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

