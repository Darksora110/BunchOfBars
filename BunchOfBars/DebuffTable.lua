
----------------------------------
--      Module Declaration      --
----------------------------------

-- TODO: optimize this table by only loading what's needed in the instance you are in
BunchOfBars.debuffs = {
	[GetSpellInfo(38235)]	= 1,  -- Water Tomb, Hydros
	[GetSpellInfo(37850)]	= 1,  -- Watery Grave, Morogrim
	[GetSpellInfo(60814)]	= 1,  -- Frost Blast, Kel'thuzad
	[GetSpellInfo(703)]		= 1,  -- Garrote, Moroes
	[GetSpellInfo(12294)]	= 1,  -- Mortal Strike
	[GetSpellInfo(1680)]	= 1,  -- Whirlwind, Leotheras the Blind
	[GetSpellInfo(37676)]	= 1,  -- Insidious Whisper, Leotheras the Blind
	[GetSpellInfo(38280)]	= 1,  -- Static Charge, Lady Vashj
	[GetSpellInfo(38258)]	= 1,  -- Panic, Lady Vashj Striders
	[GetSpellInfo(42783)]	= 1,  -- Wrath of the Astromancer, High Astromancer Solarian
	[GetSpellInfo(37018)]	= 1,  -- Conflagration, Kael'thas Sunstrider
	[GetSpellInfo(37027)]	= 1,  -- Remote Toy, Kael'thas Sunstrider
	[GetSpellInfo(40239)]	= 1,  -- Incinerate, Teron Gorefiend
	[GetSpellInfo(40251)]	= 1,  -- Shadow of Death, Teron Gorefiend
	[GetSpellInfo(46469)]	= 1,  -- Melt Armor, Al'ar
	[GetSpellInfo(41472)]	= 1,  -- Divine Wrath, Illidari Council
	[GetSpellInfo(36872)]	= 1,  -- Deadly Poison, Illidari Council
	[GetSpellInfo(41001)]	= 1,  -- Fatal Attraction, Mother Shahraz
	[GetSpellInfo(40860)]	= 1,  -- Vile Beam, Mother Shahraz
	[GetSpellInfo(39837)]	= 1,  -- Impaling Spine, High Warlord Naj'entus
	[GetSpellInfo(31943)]	= 1,  -- Doomfire, Archimonde
	[GetSpellInfo(41917)]	= 1,  -- Parasitic Shadowfiend, Illidan Stormrage
	[GetSpellInfo(40932)]	= 1,  -- Agonizing Flames, Illidan Stormrage
	[GetSpellInfo(41032)]	= 1,  -- Shear, Illidan Stormrage
	[GetSpellInfo(40585)]	= 1,  -- Dark Barrage, Illidan Stormrage
	[GetSpellInfo(43095)]	= 1,  -- Creeping Paralysis, Zul'jin
	[GetSpellInfo(43093)]	= 1,  -- Grievous Throw, Zul'jin
	[GetSpellInfo(42005)]	= 2,  -- Bloodboil, Gurtogg Bloodboil (having one of these debuffs is pretty normal here, 2 or more isn't)
	[GetSpellInfo(33527)]	= 10, -- Arcane Buffet
	[GetSpellInfo(45029)]	= 1,  -- Corrupting Strike
	[GetSpellInfo(45185)]	= 1,  -- Stomp
	[GetSpellInfo(45141)]	= 1,  -- Burn
	[GetSpellInfo(45661)]	= 1,  -- Encapsulate
	[GetSpellInfo(45866)]	= 1,  -- Corrosion
	[GetSpellInfo(45855)]	= 1,  -- Gas Nova
	[GetSpellInfo(46771)]	= 1,  -- Flame Sear
	[GetSpellInfo(45641)]	= 1,  -- Fire Bloom
	[GetSpellInfo(44461)]	= 1,  -- Living Bomb
	[GetSpellInfo(48210)]	= 1,  -- Haunt
	[GetSpellInfo(50844)]	= 1,  -- Blood Mirror
	[GetSpellInfo(54022)]	= 5,  -- Locust Swarm
	[GetSpellInfo(54127)]	= 1,  -- Web Wrap
	[GetSpellInfo(5740)]	= 1,  -- Rain of Fire
	[GetSpellInfo(28169)]	= 1,  -- Mutating Injection
	[GetSpellInfo(31464)]	= 5,  -- Mortal Wound
	[GetSpellInfo(28832)]	= 5,  -- Mark of Kor'Thazz
	[GetSpellInfo(28834)]	= 5,  -- Mark of Rivendare
	[GetSpellInfo(28833)]	= 5,  -- Mark of Blaumeux
	[GetSpellInfo(28835)]	= 5,  -- Mark of Zeliek
	[GetSpellInfo(57491)]	= 1,  -- Flame Tsunami
	[GetSpellInfo(55550)]	= 1,  -- Jagged Knife
	[GetSpellInfo(605)]		= 1,  -- Mind Control
	[GetSpellInfo(62930)]	= 1,  -- Iron Roots
	[GetSpellInfo(62589)]	= 1,  -- Nature's Fury
	[GetSpellInfo(63024)]	= 1,  -- Gravity Bomb
	[GetSpellInfo(63018)]	= 1,  -- Light Bomb
	[GetSpellInfo(64706)]	= 1,  -- Unquenchable Flames
	[GetSpellInfo(63477)]	= 1,  -- Slag Pot
	[GetSpellInfo(63493)]	= 1,  -- Fusion Punch
	[GetSpellInfo(64637)]	= 1,  -- Overwhelming Power, Council
	[GetSpellInfo(64320)]	= 1,  -- Rune of Power
	[GetSpellInfo(64851)]	= 1,  -- Flaming Rune
	[GetSpellInfo(64290)]	= 1,  -- Stone Grip
	[GetSpellInfo(55929)]	= 1,  -- Impale
	[GetSpellInfo(64125)]	= 1,  -- Squeeze
	[GetSpellInfo(10)]		= 1,  -- Blizzard, Thorim
	[GetSpellInfo(62526)]	= 1,  -- Rune Detonation
	[GetSpellInfo(48483)]	= 1,  -- Infected Wounds
	[GetSpellInfo(63494)]	= 1,  -- Static Disruption
	[GetSpellInfo(63666)]	= 1,  -- Napalm Shell, Mimiron
	[GetSpellInfo(63134)]	= 1,  -- Sara's Blessing, Yogg-Saron
	[GetSpellInfo(63120)]	= 1,  -- Insane, Yogg-Saron
	[GetSpellInfo(61968)]	= 1,  -- Flash Freeze, Hodir
	[GetSpellInfo(65102)]	= 1,  -- Sawblades, XT trash
	[GetSpellInfo(63118)]	= 1,  -- Frost Bite, Trash
	[GetSpellInfo(65080)]	= 1,  -- Cut Scrap Metal, Trash
	[GetSpellInfo(63276)]	= 1,  -- Mark of the Faceless, General Vezax
	[GetSpellInfo(62922)]	= 2,  -- Unstable Energy, Freya
	[GetSpellInfo(64698)]	= 1,  -- Pyroblast
	[GetSpellInfo(64747)]	= 1,  -- Energy Sap, Mimiron trash
	[GetSpellInfo(64529)]	= 1,  -- Plasma Blast, Mimiron
	[GetSpellInfo(64668)]	= 1,  -- Magnetic Field, Mimiron
	[GetSpellInfo(16914)]	= 1,  -- Hurricane

	-- Argent Coliseum
	---- Northrend Beasts
	[GetSpellInfo(66823)]	= 1,  -- Paralytic Toxin
	[GetSpellInfo(66869)]	= 1,  -- Burning Bile
	[GetSpellInfo(66406)]	= 1,  -- Snobolled!
	---- Lord Jaraxxus
	[GetSpellInfo(66963)]	= 1,  -- Fel Fireball
	[GetSpellInfo(67049)]	= 1,  -- Incinerate Flesh
	[GetSpellInfo(68126)]	= 1,  -- Legion Flame
	[GetSpellInfo(66209)]	= 1,  -- Touch of Jaraxxus
	[GetSpellInfo(66334)]	= 1,  -- Mistress' Kiss
	---- Twin Valkyrs
	[GetSpellInfo(67297)]	= 1,  -- Touch of Light
	[GetSpellInfo(67283)]	= 1,  -- Touch of Darkness
	[GetSpellInfo(66069)]	= 1,  -- Twin Spike
	---- Anub'arak
	[GetSpellInfo(67574)]	= 1,  -- Pursued by Anub'arak
	[GetSpellInfo(68510)]	= 1,  -- Penetrating Cold
	[GetSpellInfo(66012)]	= 1,  -- 	Freezing Slash

	-- Icecrown
	[GetSpellInfo(69065)]	= 1,  -- Impaled
	[GetSpellInfo(71111)]	= 1,  -- Aura of Darkness
	[GetSpellInfo(69483)]	= 1,  -- Dark Reckoning
	[GetSpellInfo(71090)]	= 1,  -- Bubbling Pus
	---- Lord Marrowgar
	[GetSpellInfo(70824)]	= 1,  -- Coldflame
	---- Lady Deathwhisper
	[GetSpellInfo(71289)]	= 1,  -- Dominate Mind
	---- Deathbringer Saurfang
	[GetSpellInfo(72448)]	= 1,  -- Rune of Blood
	[GetSpellInfo(70309)]	= 1,  -- Rending Throw
	[GetSpellInfo(72293)]	= 1,  -- Mark of the Fallen Champion
	[GetSpellInfo(72442)]	= 1,  -- Boiling Blood
	---- Festergut
	[GetSpellInfo(69279)]	= 1,  -- Gas Spore
	[GetSpellInfo(71218)]	= 1,  -- Vile Gas
	---- Rotface
	[GetSpellInfo(71224)]	= 1,  -- Mutated Infection
	[GetSpellInfo(71215)]	= 1,  -- Ooze Flood
	---- Professor Putricide
	[GetSpellInfo(72455)]	= 1   -- Gaseous Bloat
}


BunchOfBars.debuffs_ignore = {
	-- debuffs here should never be dispelled
	[GetSpellInfo(15822)] = true, -- Dreamless Sleep
	[GetSpellInfo(24360)] = true, -- Greater Dreamless Sleep
	[GetSpellInfo(28504)] = true, -- Major Dreamless Sleep

	[GetSpellInfo(24306)] = true, -- Delusions of Jin'do

	[GetSpellInfo(30108)] = true, -- Unstable Affliction

	[GetSpellInfo(42966)] = true,  -- Upset Tummy, because it's very annoying

	-- debuffs here can be ignored
	["WARRIOR"] = {
		[GetSpellInfo(19372)] = true, -- Ancient Hysteria, Spirit reduced by 50%, Intellect reduced by 50%.
		[GetSpellInfo(19659)] = true, -- Ignite Mana, 400 mana burned every 3 sec.
		[GetSpellInfo(16567)] = true, -- Tainted Mind, Intellect reduced by 20%.
		[GetSpellInfo(1714)]  = true  -- Curse of Tongues, Casting speed reduced by 75%.
	},
	["ROGUE"] = {
		[GetSpellInfo(19372)] = true, -- Ancient Hysteria, Spirit reduced by 50%, Intellect reduced by 50%.
		[GetSpellInfo(19659)] = true, -- Ignite Mana, 400 mana burned every 3 sec.
		[GetSpellInfo(16567)] = true, -- Tainted Mind, Intellect reduced by 20%.
		[GetSpellInfo(1714)]  = true, -- Curse of Tongues, Casting speed reduced by 75%.
		[GetSpellInfo(15487)] = true, -- Silence, Cannot cast spells.
		[GetSpellInfo(8281)]  = true  -- Sonic Burst, Cannot cast spells.
	},
	["HUNTER"] = {
	},
	["MAGE"] = {
	},
	["WARLOCK"] = {
	},
	["DRUID"] = {
	},
	["PALADIN"] = {
	},
	["PRIEST"] = {
	},
	["SHAMAN"] = {
	},
	["DEATHKNIGHT"] = {
		[GetSpellInfo(29310)] = true -- Spell Disruption
	}
}
