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

-- Hàm gửi diamonds với tên người nhận
local function sendDiamondsWithRecipient(recipientName)
    -- Kiểm tra xem tất cả các local có tồn tại không
    if Machines and MailboxMachine and Frame and OptionsFrame and ItemsFrame and SendButton and SendFrame and Bottom and SendButtonBottom then
        -- Mở hộp thư
        SendButton:FireEvent("MouseButton1Click")

        -- Chờ một khoảng thời gian ngắn để đảm bảo hộp thư được mở
        wait(1)

        -- Kiểm tra xem RichTextLabel.Input có tồn tại không
        if Bottom.RichText.RichTextLabel.Input then
            -- Thiết lập tên người nhận
            Bottom.RichText.RichTextLabel.Input.Text = recipientName
        else
            warn("Không thể tìm thấy ô nhập liệu tên người nhận.")
            return
        end

        -- Thiết lập số lượng diamonds muốn gửi
        local diamondsToSend = 1000000

        -- Nhập số lượng diamonds vào ô nhập liệu
        Bottom.RichText.RichTextLabel.Input.Text = tostring(diamondsToSend)

        -- Ghi nội dung vào ô nội dung
        Bottom.RichText.RichTextLabel.Content.Text = "aaaaaaaaaaaaaaaaaaaaaaa"

        -- Bấm nút gửi
        SendButtonBottom:FireEvent("MouseButton1Click")
    else
        warn("Các local không tồn tại. Không thể gửi diamonds.")
    end
end

-- Gọi hàm để gửi diamonds với tên người nhận là "chuideptrai1209"
sendDiamondsWithRecipient("chuideptrai1209")
