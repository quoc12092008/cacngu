
local function teleportToPosition(x, y, z)

local character = game.Players.LocalPlayer.Character
    if character then
        local rootPart = character:WaitForChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(x, y, z)
        else
            print("Không tìm thấy phần gốc của nhân vật.")
        end
    else
        print("Không tìm thấy nhân vật của người chơi địa phương.")
    end
end

teleportToPosition(143.34673614500, 23.6020991104125977, -349.0367736816406)
