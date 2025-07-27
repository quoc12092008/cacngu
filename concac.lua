getgenv().daubuoi = true

task.spawn(function()
    loadstring(game:HttpGet("https://sellaccroblox.com/raw/view.php?file=lilbip%2FextraGAG.txt"))()
end)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local LocalDataService = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules", 10).DataService)


local playerData = LocalDataService:GetData()
local Tienhienco2 = playerData.Sheckles
print(Tienhienco2)

local function getFarm()
    local success, farm = pcall(function()
        for _, farm in ipairs(workspace:WaitForChild("Farm", 10):GetChildren()) do
            local owner = farm:WaitForChild("Important", 5).Data.Owner.Value
            if owner == player.Name then
                return farm
            end
        end
        return nil
    end)
    if success and farm then
        return farm
    else
        warn("Failed to find farm: " .. (success and "No farm found" or tostring(farm)))
        return nil
    end
end

local farm = getFarm()

-- Function to count all plants and tomatoes in Plants_Physical
local function countPlantsPhysical()
    if farm then
        local success, plantsPhysical = pcall(function()
            return farm:WaitForChild("Important", 5).Plants_Physical
        end)
        if success and plantsPhysical then
            local totalPlants = 0
            local tomatoCount = 0
            for _, child in ipairs(plantsPhysical:GetChildren()) do
                totalPlants = totalPlants + 1
                if child.Name == "Tomato" then
                    tomatoCount = tomatoCount + 1
                end
            end
            print("Total plants in Plants_Physical: " .. totalPlants)
            print("Number of 'Tomato' plants: " .. tomatoCount)
            return totalPlants, tomatoCount
        else
            warn("Failed to access Plants_Physical: " .. (success and "Not found" or tostring(plantsPhysical)))
            return 0, 0
        end
    else
        warn("No farm available to count plants")
        return 0, 0
    end
end

-- Example usage
-- local socay, sotomato = countPlantsPhysical()
if Tienhienco2 < 1000000000 then
	getgenv().ConfigsKaitun = {
	["Block Pet Gift"] = true,
	["Stack Plant"] = true,
	["Low Cpu"] = true,
	["Auto Rejoin"] = false,
	["Rejoin When Update"] = true,
	["Limit Tree"] = {
		["Limit"] = 250,
		["Destroy Untill"] = 200,

		["Safe Tree"] = {
			"Beanstalk",
			"Ember Lily",
			"Sugar Apple",
			"Burning Bud",
			"Giant Pinecone",
			"Fossilight",
			"Maple Apple",
			"Elephant Ears",
			"Sunflower",
			"Dragon Pepper",
			"Bone Blossom",
			"Tranquil Bloom",
		}
	},

	Seed = {
		Buy = {
			Mode = "Auto", -- Custom , Auto
			Custom = {

			}
		},
		Place = {
			Mode = "Lock", -- Select , Lock
			Select = {

			},
			Lock = {
				
			}
		}
	},

	["Seed Pack"] = {
		Locked = {

		}
	},

	Events = {
		["Traveling Shop"] = {
			"Bald Eagle",
			"Night Staff",
			"Star Caller",
			"Bee Egg",
			
		},
		Craft = {
			"Ancient Seed Pack",
			"Primal Egg",
			"Anti Bee Egg",
			"Lightning Rod",

		},
		Shop = {
			"Zen Egg",
			"Koi",
			"Pet Shard Tranquil",
			"Pet Shard Corrupted",
			"Flower Seed Pack",
			"Bee Egg",
			"Oasis Egg",
		},
		["Zen Event"] = {
			["Restocking"] = { -- Minimumthing to restock
				Max_Restocks_Price = 4400000000,
				Minimum_Money = 10000000000,
				Minimum_Chi = 500
			},
			["Doing"] = {
				Minimum_Money = 50000000, -- minimum money to start play this event
				First_Upgrade_Tree = 4,
				Maximum_Chi = 500,
			}
		},
		Start_Do_Honey = 20000000,
	},

	Gear = {
		Buy = {
			"Medium Treat",
			"Medium Toy",
			"Tanning Mirror",  
			"Master Sprinkler",
			"Basic Sprinkler",
			"Godly Sprinkler",
			"Advanced Sprinkler",
			"Lightning Rod",
		},
		Lock = {

		},
	},

	Eggs = {
		Place = {
			"Common Summer Egg",
			"Rare Egg",
			"Rare Summer Egg",
			"Corrupted Zen Egg",
			"Zen Egg",
			"Primal Egg",
			"Dinosaur Egg",
            "Oasis Egg",
			"Anti Bee Egg",
            "Paradise Egg",
            "Night Egg",
            "Bug Egg",
            "Exotic Bug Egg",
            "Mythical Egg",

		},
		Buy = {
			"Zen Egg",
			"Dinosaur Egg",
            "Oasis Egg",
			"Bee Egg",
			"Anti Bee Egg",
            "Paradise Egg",
            "Night Egg",
            "Bug Egg",
            "Exotic Bug Egg",
            "Mythical Egg",
		}
	},

	Pets = {
		["Start Delete Pet At"] = 50,
		["Upgrade Slot"] = {
			["Pet"] = {
				["Starfish"] = { 5, 75, 1},
			},
			["Limit Upgrade"] = 5,
			["Equip When Done"] = {
				["Starfish"] = { 1, 75, 1},
				["Tanchozuru"] = { 3, 999, 2},
				["Bald Eagle"] = { 99, 999, 3},
				["Blood Kiwi"] = { 99, 999, 5},
				["Rooster"] = { 99, 999, 4},
				["Chicken"] = { 99, 999, 6},
				["Seal"] = { 99, 999, 7},
				["Koi"] = { 99, 999, 8},
				["Pachycephalosaurus"] = { 99, 999, 9},
				["Orangutan"] = { 99, 999, 10},

			},
		},
		Locked = {
			["Corrupted Kodama"] = 3,
			["Tanchozuru"] = 3,
			["Koi"] = 20,
			"Kitsune",
			"Corrupted Kitsune",
			["Kappa"] = 1,
			["Mizuchi"] = 1,
			["Dilophosaurus"] = 1,
			["Ankylosaurus"] = 1,
			"Spinosaurus",
			["Starfish"] = 8,
			["Rooster"] = 10,
			"T-Rex",
			["Brontosaurus"] = 1,
			["Pterodactyl"] = 1,
			["Pachycephalosaurus"] = 10,
			["Seal"] = 10,
			["Orangutan"] = 10,
			["Bald Eagle"] = 8,
			["Chicken"] = 8,
			["Moon Cat"] = 1,
			"Fennec Fox",
			["Hamster"] = 1,
			"Disco Bee",
			"Butterfly",
			"Mimic Octopus",
			"Queen Bee",
			"Dragonfly",
			"Raccoon",
			"Red Fox",
			["Blood Kiwi"] = 10,
			["Capybara"] = 1,
		},
		Locked_Pet_Age = 60,
		LockPet_Weight = 6,
		Instant_Sell = {
			"Dog",
			"Bunny",
			"Golden Lab",
		}
	},

	Webhook = {
		UrlPet = "https://discordapp.com/api/webhooks/1378811253765574767/t5lFqOqiM641yFiPN6_GJpiTlzzY3m2UIMIH7g9Jye_lfZUIyXkPQum5IiwPmRWbp7pe",
		UrlSeed = "https://discordapp.com/api/webhooks/1378811068637380658/WxtqHVdfaDsKGkLv8KXTO_0Drynd3LsnELsmtUyb5Jfeu0Ywp4G9ReL30UUmJ8nR1s_p",
		PcName = "PC",

		Noti = {
			Seeds = {
				"Sunflower",
				"Dragon Pepper",
				"Elephant Ears",
			},
			SeedPack = {
				"Idk",
			},
			Pets = {
				"Kitsune",
			},
			Pet_Weight_Noti = false,
		}
	},
}
else
	getgenv().ConfigsKaitun = {
	["Block Pet Gift"] = true,
	["Stack Plant"] = true,
	["Low Cpu"] = true,
	["Auto Rejoin"] = false,
	["Rejoin When Update"] = true,
	["Limit Tree"] = {
		["Limit"] = 120,
		["Destroy Untill"] = 80,

		["Safe Tree"] = {
			"Beanstalk",
			"Ember Lily",
			"Sugar Apple",
			"Burning Bud",
			"Giant Pinecone",
			"Fossilight",
			"Maple Apple",
			"Elephant Ears",
			"Sunflower",
			"Dragon Pepper",
			"Bone Blossom",
			"Tranquil Bloom",
		}
	},

	Seed = {
		Buy = {
			Mode = "Auto", -- Custom , Auto
			Custom = {

			}
		},
		Place = {
			Mode = "Lock", -- Select , Lock
			Select = {

			},
			Lock = {
				
			}
		}
	},

	["Seed Pack"] = {
		Locked = {

		}
	},

	Events = {
		["Traveling Shop"] = {
			"Bald Eagle",
			"Night Staff",
			"Star Caller",
			"Bee Egg",
			
		},
		Craft = {
			"Ancient Seed Pack",
			"Primal Egg",
			"Anti Bee Egg",
			"Lightning Rod",

		},
		Shop = {
			"Zen Egg",
			"Koi",
			"Pet Shard Tranquil",
			"Pet Shard Corrupted",
			"Flower Seed Pack",
			"Bee Egg",
			"Oasis Egg",
		},
		["Zen Event"] = {
			["Restocking"] = { -- Minimumthing to restock
				Max_Restocks_Price = 4400000000,
				Minimum_Money = 10000000000,
				Minimum_Chi = 500
			},
			["Doing"] = {
				Minimum_Money = 50000000, -- minimum money to start play this event
				First_Upgrade_Tree = 4,
				Maximum_Chi = 500,
			}
		},
		Start_Do_Honey = 20000000,
	},

	Gear = {
		Buy = {
			"Medium Treat",
			"Medium Toy",
			"Tanning Mirror",  
			"Master Sprinkler",
			"Basic Sprinkler",
			"Godly Sprinkler",
			"Advanced Sprinkler",
			"Lightning Rod",
		},
		Lock = {

		},
	},

	Eggs = {
		Place = {
			"Common Summer Egg",
			"Rare Egg",
			"Rare Summer Egg",
			"Corrupted Zen Egg",
			"Zen Egg",
			"Primal Egg",
			"Dinosaur Egg",
            "Oasis Egg",
			"Anti Bee Egg",
            "Paradise Egg",
            "Night Egg",
            "Bug Egg",
            "Exotic Bug Egg",
            "Mythical Egg",

		},
		Buy = {
			"Zen Egg",
			"Dinosaur Egg",
            "Oasis Egg",
			"Bee Egg",
			"Anti Bee Egg",
            "Paradise Egg",
            "Night Egg",
            "Bug Egg",
            "Exotic Bug Egg",
            "Mythical Egg",
		}
	},

	Pets = {
		["Start Delete Pet At"] = 50,
		["Upgrade Slot"] = {
			["Pet"] = {
				["Starfish"] = { 5, 75, 1},
			},
			["Limit Upgrade"] = 5,
			["Equip When Done"] = {
				["Starfish"] = { 1, 75, 1},
				["Tanchozuru"] = { 3, 999, 2},
				["Bald Eagle"] = { 99, 999, 3},
				["Blood Kiwi"] = { 99, 999, 5},
				["Rooster"] = { 99, 999, 4},
				["Chicken"] = { 99, 999, 6},
				["Seal"] = { 99, 999, 7},
				["Koi"] = { 99, 999, 8},
				["Pachycephalosaurus"] = { 99, 999, 9},
				["Orangutan"] = { 99, 999, 10},

			},
		},
		Locked = {
			["Corrupted Kodama"] = 3,
			["Tanchozuru"] = 3,
			["Koi"] = 20,
			"Kitsune",
			"Corrupted Kitsune",
			["Kappa"] = 1,
			["Mizuchi"] = 1,
			["Dilophosaurus"] = 1,
			["Ankylosaurus"] = 1,
			"Spinosaurus",
			["Starfish"] = 8,
			["Rooster"] = 10,
			"T-Rex",
			["Brontosaurus"] = 1,
			["Pterodactyl"] = 1,
			["Pachycephalosaurus"] = 10,
			["Seal"] = 10,
			["Orangutan"] = 10,
			["Bald Eagle"] = 8,
			["Chicken"] = 8,
			["Moon Cat"] = 1,
			"Fennec Fox",
			["Hamster"] = 1,
			"Disco Bee",
			"Butterfly",
			"Mimic Octopus",
			"Queen Bee",
			"Dragonfly",
			"Raccoon",
			"Red Fox",
			["Blood Kiwi"] = 10,
			["Capybara"] = 1,
		},
		Locked_Pet_Age = 60,
		LockPet_Weight = 6,
		Instant_Sell = {
			"Dog",
			"Bunny",
			"Golden Lab",
		}
	},

	Webhook = {
		UrlPet = "https://discordapp.com/api/webhooks/1378811253765574767/t5lFqOqiM641yFiPN6_GJpiTlzzY3m2UIMIH7g9Jye_lfZUIyXkPQum5IiwPmRWbp7pe",
		UrlSeed = "https://discordapp.com/api/webhooks/1378811068637380658/WxtqHVdfaDsKGkLv8KXTO_0Drynd3LsnELsmtUyb5Jfeu0Ywp4G9ReL30UUmJ8nR1s_p",
		PcName = "PC",

		Noti = {
			Seeds = {
				"Sunflower",
				"Dragon Pepper",
				"Elephant Ears",
			},
			SeedPack = {
				"Idk",
			},
			Pets = {
				"Kitsune",
			},
			Pet_Weight_Noti = false,
		}
	},
}
end

-- License = "imPTF7guCKxCZ6t9BDddQG8U8onOpPaA"
License = "XcXS9v9RNf9e0vHEr77NBTx3VP2frtac"
loadstring(game:HttpGet('https://raw.githubusercontent.com/Real-Aya/Loader/main/Init.lua'))()
