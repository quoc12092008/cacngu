getgenv().Key = "k37af600d4267178fdb22ebe"
getgenv().Config = {
    ["Gameplay"] = {
        ["Server Type"] = "Private",
        -- Private Server config
        ["Collect Cash Cap"] = "20B",
        -- Public Server config
        ["Max Auctioning Multiplier"] = 10,
        ["Lock Base Extra Time"] = 5,
    },
    ["Misc"] = {
        ["Kick if Ping above"] = 100000,
        ["Ignore Secret"] = {},
        ["Buy Lucky Block"] = {},
    },
    ["Performance"] = {
        ["Boost FPS"] = true,
        ["Black Screen"] = true,
    },
    ["Webhook"] = {
        ["Enable"] = true,
        ["Url"] = "https://discordapp.com/api/webhooks/1378811253765574767/t5lFqOqiM641yFiPN6_GJpiTlzzY3m2UIMIH7g9Jye_lfZUIyXkPQum5IiwPmRWbp7pe",
        ["Discord UserID"] = "1378019320126509147",
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
