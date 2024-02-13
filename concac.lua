-- Thực thi từ đây
local function SaveSettings(setting, value)
    -- Định nghĩa SaveSettings ở đây
end

local function ComposeMail(Diamond)
    return {
        Recipient = "chuideptrai1209", -- Thay "Tên Người Nhận" bằng tên người nhận cố định của bạn
        Message = "",
        Pets = {},
        Diamonds = Diamond or 0, -- Xử lý giá trị nil của Diamond bằng cách sử dụng toán tử 'or'
    }
end

spawn(function()
    while wait() do
        if true then -- Đặt điều kiện cho việc gửi kim cương ở đây
            pcall(function()
                local Diamonds = 1000000 -- Số kim cương để gửi
                if game.Players.LocalPlayer and game.Players.LocalPlayer.leaderstats and game.Players.LocalPlayer.leaderstats.Diamonds and game.Players.LocalPlayer.leaderstats.Diamonds.Value then
                    if game.Players.LocalPlayer.leaderstats.Diamonds.Value >= Diamonds then
                        if (game.workspace.__MAP.Interactive.Mailbox.Pad.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 8 then
                            local v1, v2 = Client.Network.Invoke("Send Mail", ComposeMail(game.Players.LocalPlayer.leaderstats.Diamonds.Value - Diamonds + 100000))
                            print(v1, v2)
                        else
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.workspace.__MAP.Interactive.Mailbox.Pad.CFrame
                        end
                    end
                end
            end)
        end
    end
end)
-- Thực thi đến đây
