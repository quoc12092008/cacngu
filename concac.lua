repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer
local Plr = game.Players.LocalPlayer
repeat wait() until Plr.Character
repeat wait() until Plr.Character:FindFirstChild("HumanoidRootPart")
repeat wait() until Plr.Character:FindFirstChild("Humanoid") 
local Plrgui =game:GetService("Players").LocalPlayer.PlayerGui
local vim = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

function ClickButton(a)
   game:GetService("VirtualInputManager"):SendMouseButtonEvent(a.AbsolutePosition.X+a.AbsoluteSize.X/2,a.AbsolutePosition.Y+65,0,true,a,1)
   game:GetService("VirtualInputManager"):SendMouseButtonEvent(a.AbsolutePosition.X+a.AbsoluteSize.X/2,a.AbsolutePosition.Y+65,0,false,a,1)
end
local function ClickButton1(a)
   game:GetService("GuiService").SelectedObject = a
   game:GetService("VirtualInputManager"):SendKeyEvent(true, "Return", false, game)
   game:GetService("VirtualInputManager"):SendKeyEvent(false, "Return", false, game) 
end
local listCrate = {
   ["Golden Gladiator"] = "rbxassetid://129368477907107",
}
local function isCrate(crate)
   local ImgCrate = {}
   for i,v in pairs(listCrate) do 
      table.insert(ImgCrate,v) 
   end
   if table.find(ImgCrate,crate.TroopsFrame.TroopIcon.Image) then 
      return true
   end 
   return false
end
RarityColor = {}
function ConvertGradientToRGB(v, num)
    color = v.Color.Keypoints[num].Value
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return Color3.fromRGB(r, g, b)
end
for _, v in pairs(
    game:GetService("Players").LocalPlayer.PlayerGui.Lobby.MarketplaceFrame.MarketplaceMain.MainFrame.BuyMenu.FilterBar.Rarities:GetChildren(

    )
) do
    if v:IsA("Frame") then
        RarityColor[v.Name] = {
            ["1"] = ConvertGradientToRGB(v.FilterButton[v.Name], 1),
            ["2"] = ConvertGradientToRGB(v.FilterButton[v.Name], 2)
        }
    end
end
function GetRarity(color1, color2)
    for rarity, colors in pairs(RarityColor) do
        if (color1 == colors["1"] and color2 == colors["2"]) then
            return rarity
        end
    end
end


function CheckRarity(v)
   if GetRarity(ConvertGradientToRGB(v, 1), ConvertGradientToRGB(v, 2)) == "Godly" or GetRarity(ConvertGradientToRGB(v, 1), ConvertGradientToRGB(v, 2)) == "Ultimate" then
      return true
   end
   return false
end
function GetUnitList()
   unitlist = {}
   if #Plrgui.Lobby.UnitFrame.UnitHolder.UnitList:GetChildren() <= 1 then
       repeat
          ClickButton(Plrgui.Lobby.LeftSideFrame.Units.Button)
       until #Plrgui.Lobby.UnitFrame.UnitHolder.UnitList:GetChildren() > 1
   end
   unitlist = {}
   for i, v in pairs(Plrgui.Lobby.UnitFrame.UnitHolder.UnitList:GetChildren()) do
       if v:IsA("Frame") then
           if v.TroopsFrame.TroopIcon.Image == "rbxassetid://15798757056" then
               v:Destroy()
           else
               table.insert(unitlist, v.Name)
           end
       end
   end
   
   table.sort(unitlist)
return unitlist
end
local function getSellConfirmGui()
   for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MainFrames.NotificationFrame:GetChildren()) do 
      if v.Name == "BigNotification" and v.Parent.Visible then 
         if string.find(v.NotificationMessage.Text,"sell") then 
            return v 
         end 
      end 
   end 
   return 
    
end
_G.farm = true
spawn(function()
   unitlist = GetUnitList()
   while _G.farm do wait()
         if Plrgui.Lobby.UnitFrame.Visible then    
            Plrgui.Lobby.UnitFrame.UnitHolder.UnitList.UIGridLayout.SortOrder = "Name"
            wait(2)
            local SellConfirmGui = getSellConfirmGui()
            if SellConfirmGui then 
               ClickButton(SellConfirmGui.Buttons.YesButton)
               wait(3)
               print('shutting down')
               game:Shutdown()
            else
               if Plrgui.Lobby.UnitFrame.UnitHolder.Buttons.SellUnits.Button.Text == "Cancel" then
                  for i,v in pairs(unitlist) do
                     if isCrate(Plrgui.Lobby.UnitFrame.UnitHolder.UnitList[v]) then 
                        --Plrgui.Lobby.UnitFrame.UnitHolder.UnitList[v].Visible = false
                     else 
                        if CheckRarity(Plrgui.Lobby.UnitFrame.UnitHolder.UnitList[v].TroopsFrame.Background.RarityGradient) then 
                           --Plrgui.Lobby.UnitFrame.UnitHolder.UnitList[v].Visible = false
                        else
                           if not Plrgui.Lobby.UnitFrame.UnitHolder.UnitList[v].TroopsFrame.BulkSellIcon.Visible then
                          
                                 ClickButton1(Plrgui.Lobby.UnitFrame.UnitHolder.UnitList[v].TroopsFrame.InteractiveButton)
                                 task.wait()
                           end
                        end 
                     end
                     print(i)
                  end
                  print('select sell done')
                  ClickButton(Plrgui.Lobby.UnitFrame.UnitHolder.Buttons.SellUnits)
               else  
                  repeat wait()
                     ClickButton(Plrgui.Lobby.UnitFrame.UnitHolder.Buttons.SellUnits)
                     wait(.25)
                  until Plrgui.Lobby.UnitFrame.UnitHolder.Buttons.SellUnits.Button.Text == "Cancel"
               end
            end
         else 
            ClickButton(Plrgui.Lobby.LeftSideFrame.Units.Button)
            wait(.25 )
         end  
      
   end
end)
