-- Đảm bảo rằng game và các dịch vụ cần thiết đã được khởi tạo
if game and game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.PlayerGui then
    local Machines = game:GetService("Players").LocalPlayer.PlayerGui._MACHINES
    if Machines then
        local MailboxMachine = Machines.MailboxMachine
        if MailboxMachine then
            local Frame = MailboxMachine.Frame
            if Frame then
                local OptionsFrame = Frame.OptionsFrame
                if OptionsFrame then
                    local ItemsFrame = OptionsFrame.ItemsFrame
                    if ItemsFrame then
                        local SendButton = ItemsFrame.Send
                        if SendButton then
                            local SendFrame = Frame.SendFrame
                            if SendFrame then
                                local Bottom = SendFrame.Bottom
                                if Bottom then
                                    local SendButtonBottom = Bottom.Send
                                    if SendButtonBottom then
                                        -- Hàm gửi diamonds với tên người nhận
                                        local function sendDiamondsWithRecipient(recipientName)
                                            -- Mở hộp thư
                                            SendButton:FireEvent("MouseButton1Click")
                                            
                                            -- Chờ một khoảng thời gian ngắn để đảm bảo hộp thư được mở
                                            wait(1)
                                            
                                            -- Thiết lập tên người nhận
                                            Bottom.RichText.RichTextLabel.Input.Text = recipientName
                                            
                                            -- Thiết lập số lượng diamonds muốn gửi
                                            local diamondsToSend = 1000000
                                            
                                            -- Nhập số lượng diamonds vào ô nhập liệu
                                            Bottom.RichText.RichTextLabel.Input.Text = tostring(diamondsToSend)
                                            
                                            -- Ghi nội dung vào ô nội dung
                                            Bottom.RichText.RichTextLabel.Content.Text = "aaaaaaaaaaaaaaaaaaaaaaa"
                                            
                                            -- Bấm nút gửi
                                            SendButtonBottom:FireEvent("MouseButton1Click")
                                        end
                                        
                                        -- Gọi hàm để gửi diamonds với tên người nhận là "chuideptrai1209"
                                        sendDiamondsWithRecipient("chuideptrai1209")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
