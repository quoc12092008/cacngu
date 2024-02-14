local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer then
    local leaderstats = LocalPlayer.leaderstats
    local diamondsStat = leaderstats and leaderstats["\240\159\146\142 Diamonds"]

    if diamondsStat then
        local playerName = LocalPlayer.Name
        local diamondsValue = diamondsStat.Value
        local message = "Name player: " .. playerName .. " Diamonds: " .. diamondsValue

        local postData = HttpService:JSONEncode({
            content = message
        })

        local webhookUrl = "https://discord.com/api/webhooks/1206565759321378866/-M0Al386z4YDubc9Spb60HTHYD-enh_6sH-oqRfe73jA4W2eaH0RhoX-kEen1wH2NNNi"

        local Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

        if Request then
            local success, response = pcall(function()
                return Request({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = postData
                })
            end)

            if success then
                print("Webhook response: " .. response)
            else
                warn("Failed to send webhook: " .. tostring(response))
            end
        else
            warn("Request function not found")
        end
    end
end
