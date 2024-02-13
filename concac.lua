local function ComposeMail(Diamond)
    return {
        Recipient = "chuideptrai1209", 
        Message = "abcdaaaaa",
        Pets = {},
        Diamonds = Diamond,
    }
end

spawn(function()
    while wait() do
        if true then -- Đặt điều kiện cho việc gửi kim cương ở đây
            pcall(function()
                local Diamonds = 1000000 -- Số kim cương để gửi
                if (game.Players.LocalPlayer.leaderstats.Diamonds.Value >= Diamonds) then
                    if (game.workspace.__MAP.Interactive.Mailbox.Pad.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 8 then
                        local v1, v2 = Client.Network.Invoke("Send Mail", ComposeMail(game.Players.LocalPlayer.leaderstats.Diamonds.Value - Diamonds + 100000))
                        print(v1, v2)
                    else
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.workspace.__MAP.Interactive.Mailbox.Pad.CFrame
                    end
                end
            end)
        end
    end
end)

