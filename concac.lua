getgenv().Key = "k37af600d4267178fdb22ebe"
getgenv().Config = {
    ["Gameplay"] = {
        ["Server Type"] = "Private",
        -- Private Server config
        ["Collect Cash Cap"] = "10B",
        -- Public Server config
        ["Max Auctioning Multiplier"] = 10,
        ["Lock Base Extra Time"] = 5,
    },
    ["Misc"] = {
        ["Kick if Ping above"] = 100000,
        ["Ignore Secret"] = {},
        ["Buy Lucky Block"] = {},
            "Secret Lucky Block",
    },
    ["Performance"] = {
        ["Boost FPS"] = true,
        ["Black Screen"] = true,
    },
    ["Webhook"] = {
        ["Enable"] = true,
        ["Url"] = "https://discord.com/api/webhooks/1408759682654539807/0SFAahtT91e9UUX7gs8VVtJqledkBwmITcdWDicayUufLuuzzBTvLmgs7LM7MaMHcho8",
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
spawn(function() task.wait(300) if not getgenv().scriptLoaded then game.Players.LocalPlayer:Kick("Script load timeout\nKick to prevent animal gets stolen") end end) repeat wait()spawn(function()loadstring(game:HttpGet("https://nousigi.com/loader.lua"))()end)wait(20)until getgenv().Joebiden
