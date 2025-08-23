getgenv().Key = "k37af600d4267178fdb22ebe"
getgenv().Config = {
    ["Gameplay"] = {
        ["Server Type"] = "Private",
        -- Private Server config
        ["Collect Cash Cap"] = "2B",
        -- Public Server config
        ["Max Auctioning Multiplier"] = 10,
        ["Lock Base Extra Time"] = 5,
    },
    ["Misc"] = {
        ["Kick if Ping above"] = 100000,
        ["Kick if FPS below"] = 5,
        ["Buy Lucky Block"] = {
            "Secret Lucky Block",
},
    ["Performance"] = {
        ["Boost FPS"] = true,
        ["Black Screen"] = true,
    },
    ["Webhook"] = {
        ["Enable"] = true,
        ["Url"] = "",
        ["Discord UserID"] = "",
        ["Ignore Notify"] = {
            ["La Vacca Saturno Saturnita"] = {
                "Normal",
                "Lava",
                "Gold",
                "Diamond",
                "Candy",
                "Rainbow",
                "Bloodrot",
            },
            ["Job Job Job Sahur"] = {
                "Normal",
                "Lava",
                "Gold",
                "Diamond",
                "Bloodrot",
                "Rainbow",
            },
            ["Chimpanzini Spiderini"] = {
                "Normal",
                "Lava",
                "Gold",
                "Diamond",
                "Bloodrot",
                "Rainbow",
            },
            ["Los Tralaleritos"] = {
                "Normal",
                "Lava",
                "Gold",
                "Diamond",
                "Candy",
                "Rainbow",
                "Bloodrot",
            },
            ["Las Tralaleritas"] = {
                "Normal",
                "Lava",
                "Gold",
                "Diamond",
                "Candy",
                "Rainbow",
                "Bloodrot",
            },
            ["Graipuss Medussi"] = {
                "Normal",
                "Lava",
                "Gold",
                "Diamond",
                "Candy",
                "Rainbow",
                "Bloodrot",
            },
        },
    }
}
spawn(function() task.wait(300) if not getgenv().scriptLoaded then game.Players.LocalPlayer:Kick("Script load timeout") end end) loadstring(game:HttpGet("https://api.nousigi.com/scripts/StealABrainrot.lua"))()
