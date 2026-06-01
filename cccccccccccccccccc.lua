getgenv().Configs = {
    ['Auto Thunder Spears'] = true,
    ['Auto Prestige'] = {
        ['Enabled'] = true,
        ['Prestige Stop At'] = 3,
        ['Gold Requirement'] = {
            ['Prestige 1'] = 80000000,
            ['Prestige 2'] = 180000000,
            ['Prestige 3'] = 600000000,
            ['Prestige 4'] = 800000000,
            ['Prestige 5'] = 1000000000,
        }
    },
    ['Farm Slot'] = 'A',
    ['Colossal Raid'] = false,
    ['Codes'] = {
	'LIKES1M250K',
		'FREECODE6',
        'FREECODE5',
		'FREECODE4',
		'LIKES1M200K',
        'VISITS800M',
        'TERRA70K',
        'PLAYERS100K',
        'VISITS600M',
        'VISITS700M',
        'FAVORITES1M',
        'MEMBERS900K',
        'MEMBERS1M',
        'UPDATE4',
        'LIKES1M150K',
        'FREECODE3',
        'LIKES1M100K',
        'THANKSFORSTAYINGWITHUS',
        'CHRISTMAS2025',
        'LIKES1M',
    },
	['Potions'] = {
		['Auto Buy'] = true,
		['Potions'] = {
			'2x XP Boost [1h]', --// 2x XP Boost [30m], 2x XP Boost [2h]
			'2x Gold Boost [1h]', --// 2x Gold Boost [30m], 2x Gold Boost [2h]
		},
	},
    ['Missions'] = {
        ['Shiganshina'] = true,
        ['Trost'] = true,
        ['Outskirts'] = true,
        ['Giant Forest'] = false,
        ['Utgard'] = true,
        ['Docks'] = false,
        ['Stohess'] = true,
        ['Chapel'] = true,
    },

    ['Modifiers'] = {
        'No Perks',
        'No Skills',
        'No Memories',
        'Nightmare',
        'Oddball',
        'Injury Prone',
        'Chronic Injuries',
        'Fog',
        'Time Trial',
    },

    ['Families'] = {
        ['Auto Roll'] = {
            ['Enabled'] = false,
            ['Lock Spins'] = 0,
            ['Families'] = {
                'Fritz',
                'Helos',
                'Ackerman',
            },
        },
        ['Auto Storage'] = {
            ['Enabled'] = false,
            ['Families'] = {
            },
        },

    },
    ['Sell Cosmetics'] = {
        ['Enabled'] = true,
        ['Cosmetics'] = {
			-- 55 Gems
		    'Mushroom Cloud',
		    'Marleyan Patch',
		    'Hardened Blade',
		    'Superheated',
			-- 100 Gems
		    'Blazing Veil',
		    'Wizard Hat',
		    'Midnight Mask',
		    'Recon Visor',
		    'Altar Chains',
		    'Bowler Hat (Black)',
			-- 165 Gems
		    'Herbal Magic',
		    "Young Annie's Rain Poncho",
		    "Young Annie's Attire",
		    'Blue Lightning',
		    'Abyssion',
		    'Celestial',
		    "Aspiring Warrior's Attire",
			-- 300 Gems
		    'Kitsune Ribbon',
		    'Regiment Cloak (Green)',
		    'Blood Vial',
		    'Bowler Hat (White)',
		    'Mushroom Hat',
			-- 440 Gems
		    'Digital Fracture',
		    'Balance',
		    "Young Reiner's Attire",
		    'Duality',
		    'Fractured Surge',
		    'Atomic Bomb',
			-- 800 Gems
		    'Regiment Cloak (Black)',
		    "Grimmjow's Mask",
		    'Kitsune Mask',
		    'Hardened Shield',
		    "Warrior's Medallion",
		    "Shogun's Helm",
        },
    },

    ['Craft Perks'] = {
        ['Enabled'] = true,
        ['Chance'] = {
            ['Rare'] = 100,
            ['Epic'] = 100,
            ['Legendary'] = 100,
            ['Mythic'] = 100,
        },
        ['Craft Epic'] = false,
        ['Craft Legendary'] = true,
        ['Craft Mythic'] = false,
    },

	['Remove Perks'] = {
   	 	['Enabled'] = true,
		['Perks'] = {
			['Common'] = true,
			['Rare'] = true,
			['Epic'] = false,
			['Legendary'] = false,
		},
	},

    ['Equip Perks'] = { 
        ['Auto Equip Perks'] = true,
        ['Body Slot'] = {
            'Heavenly Restriction', -- // Mythic
            'Maximum Firepower', -- // Mythic
            'Perfect Soul', -- // Legendary
            'Perfect Form', -- // Legendary
        },
        ['Offense Slot'] = {
            'Kengo', -- // Mythic
            'Unparalleled Strength', -- // Legendary
            'Peerless Focus', -- // Legendary
        },
        ['Defense Slot'] = {
            'Immortal', -- // Mythic
            'Font of Vitality', -- // Legendary
        },
        ['Support Slot'] = {
            'Tatsujin', -- // Mythic
            'Soulfeed', -- // Mythic
            'Gear Master', -- // Legendary
        },
    },
    ['Skill Trees'] = {
        ['Enabled'] = true,
        ['Left'] = {
            ['Enabled'] = true,
            ['Skill'] = 'Regen VI',
        },
        ['Middle'] = {
            ['Enabled'] = true,
            ['Skill'] = 'Damage V',
        },
        ['Right'] = {
            ['Enabled'] = true,
            ['Skill'] = 'Health XI',
        },
        ['Upgrade Priority'] = {
            ['Left'] = 9,
            ['Middle'] = 10,
            ['Right'] = 8,
        },
    },
    ['Join Private Server'] = {
         ['Enabled'] = false,
         ['Server Code'] = '',
    },
    
    ['Performance'] = {
        ['FPS Boost'] = true,
        ['FPS Lock'] = {
            ['Enabled'] = true,
            ['FPS'] = 15,
        },
    },

    ['Webhook'] = {
        ['Enabled'] = false,
        ['Url'] = 'https://discord.com/api/webhooks/1463577403455439137/EdkcC3-DP0L9WygLNSo1Ig-Oc14g4VkmxawGxa6SDcsGgMb0FEG0ZRtNBsqMSCeHeC8q',
    },
}
_G.Authorize = "BJcZrLHSNgHFsyh0Qpz2uyO5KW50TkOp"
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/0fbaa2aa75e1ef5d4da3dd2e849494c8.lua")){'Exclusive'}
