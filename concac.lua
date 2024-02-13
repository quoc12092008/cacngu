-- Định nghĩa các local bạn đã cung cấp
local Machines = game:GetService("Players").LocalPlayer.PlayerGui._MACHINES
local MailboxMachine = Machines.MailboxMachine
local Frame = MailboxMachine.Frame
local OptionsFrame = Frame.OptionsFrame
local ItemsFrame = OptionsFrame.ItemsFrame
local SendButton = ItemsFrame.Send
local SendFrame = Frame.SendFrame
local Bottom = SendFrame.Bottom
local SendButtonBottom = Bottom.Send

-- Hàm gửi 1 triệu diamonds
local function sendMillionDiamonds()
    -- Mở hộp thư
    SendButton:FireEvent("MouseButton1Click")

    -- Chờ một khoảng thời gian ngắn để đảm bảo hộp thư được mở
    wait(1)

    -- Thiết lập số lượng diamonds muốn gửi
    local diamondsToSend = 1000000

    -- Nhập số lượng diamonds vào ô nhập liệu
    Bottom.RichText.RichTextLabel.Input.Text = tostring(diamondsToSend)

    -- Bấm nút gửi
    SendButtonBottom:FireEvent("MouseButton1Click")
end

-- Gọi hàm để gửi 1 triệu diamonds
sendMillionDiamonds()
