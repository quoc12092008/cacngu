getgenv().ConfigsKaitun = {
	["Block Pet Gift"] = true,

	["Low Cpu"] = true,
	["Auto Rejoin"] = true,

	["Rejoin When Update"] = false,
	["Limit Tree"] = {
		["Limit"] = 300,
		["Destroy Untill"] = 280,

		["Safe Tree"] = {
			"Moon Blossom",
			"Fossilight",
		}
	},

	Seed = {
		Buy = {
			Mode = "Auto", -- Custom , Auto
			Custom = {
				"Carrot",
				"Bamboo",
				"Pumpkin",
				"Daffodil",
				"Orange Tulip",
				"Watermelon",
				"Mushroom",
				"Avocado",
				"Feijoa",
				"Cauliflower",
				"Loquat",
				"Green Apple",
				"Nightshade",
				"Firefly Fern",
				"Soft Sunshine",
				"Zen Rocks",
				"Hinomai",
				"Beanstalk",
				"Ember Lily",
				"Sunflower",
				"Sugar Apple",
				"Burning Bud",
				"Giant Pinecone",
				"Spiked Mango",
			}
		},
		Place = {
			Mode = "Lock", -- Select , Lock
			Select = {
				"Carrot"
			},
			Lock = {
				"Maple Apple",
				"Sunflower",
				"Dragon Pepper",
				"Elephant Ears",
				"Moon Melon",
				"Easter Egg",
				"Moon Mango",
				"Bone Blossom",
				"Fossilight",
			}
		}
	},

	["Seed Pack"] = {
		Locked = {

		}
	},

	Events = {
		["Zen Event"] = {
			["Restocking"] = { -- Minimumthing to restock
				Max_Restocks_Price = 50_000_000,
				Minimum_Money = 10_000_000,
				Minimum_Chi = 200
			},
			["Doing"] = {
				Minimum_Money = 30_000_000, -- minimum money to start play this event
				First_Upgrade_Tree = 4,
				Maximum_Chi = 250,
			}
		},
		["Traveling Shop"] = {
			"Bee Egg",
		},
		Craft = {
			"Ancient Seed Pack",
			"Anti Bee Egg",
			"Primal Egg",
		},
		Shop = {
			"Zen Egg",
		},
		Start_Do_Honey = 2_000_000 -- start trade fruit for honey at money
	},

	Gear = {
		Buy = { 
			"Master Sprinkler",
			"Godly Sprinkler",
			"Advanced Sprinkler",
			"Basic Sprinkler",
			"Lightning Rod",
			"Level Up Lollipop",
			"Medium Treat",
			"Medium Toy",
		},
		Lock = {
			"Master Sprinkler",
			"Godly Sprinkler",
			"Advanced Sprinkler",
			"Basic Sprinkler",
			"Lightning Rod",
		},
	},

	Eggs = {
		Place = {
			"Common Summer Egg", 
                        "Zen Egg",
		},
		Buy = {
			"Common Summer Egg",
                        "Bee Egg",
			"Oasis Egg",
			"Paradise Egg",
			"Anti Bee Egg",
			"Night Egg",
			"Bug Egg",

		}
	},

	Pets = {
		["Start Delete Pet At"] = 40,
		["Upgrade Slot"] = {
			["Pet"] = {
				["Starfish"] = { 5, 100, 1 },
			},
			["Limit Upgrade"] = 5,
			["Equip When Done"] = {
				["Tanchozuru"] = { 1, 100, 1 },
				["Starfish"] = { 7, 100, 1 },
			},
		},
		Locked_Pet_Age = 60, -- pet that age > 60 will lock
		Locked = {
			"T-Rex",
   "Dragonfly",
   "Spinosaurus",
   "Raccoon",
   "Fennec Fox",
   "Corrupted Kitsune",
   "Disco Bee",
   "Butterfly",
   "Mimic Octopus",
   "Kitsune",
   ["Starfish"] = 20,
   ["Tanchozuru"] = 2,
		},
		LockPet_Weight = 7, -- if Weight >= 10 they will locked,
		Instant_Sell = {		
			"Shiba Inu",
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
				"Corrupted Kitsune",
			},
			Pet_Weight_Noti = false,
		}
	},
}
License = "XcXS9v9RNf9e0vHEr77NBTx3VP2frtac"
loadstring(game:HttpGet('https://raw.githubusercontent.com/Real-Aya/Loader/main/Init.lua'))()
