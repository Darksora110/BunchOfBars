

local moduleName = "Debuffs"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Debuffs",

	["Text Color"] = true,
	["Change the text color."] = true
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local candispel = {
	["WARRIOR"] = { },
	["ROGUE"] = { },
	["HUNTER"] = { },
	["MAGE"] = {
		["Curse"] = true
	},
	["WARLOCK"] = { },
	["DRUID"] = { 
		["Curse"] = true,
		["Poison"] = true
	},
	["PALADIN"] = {
		["Magic"] = true,
		["Poison"] = true,
		["Disease"] = true
	},
	["PRIEST"] = {
		["Magic"] = true,
		["Disease"] = true
	},
	["SHAMAN"] = {
		["Disease"] = true,
		["Poison"] = true,
		["Curse"] = true
	},
	["DEATHKNIGHT"] = { }
}

do
	local class = select(2, UnitClass("player"))
	candispel = candispel[class] -- let's hope the rest of the candispel table is garbage collected after this
	candispel["none"] = true
end


local agro = { }
--local agrounit

-- localize these functions to speed up our main loop
local UnitClass = UnitClass
local UnitDebuff = UnitDebuff



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 110 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		color = {
			type = "color",
			name = L["Text Color"],
			desc = L["Change the text color."],
			get = "GetSetColor",
			set = "GetSetColor"
		}
	}
}

plugin.defaultDB = {
	position = 1,

	color  = {
		r = 1,
		g = 1,
		b = 0
	},

	debuffs = {
		[GetSpellInfo(45271)] = 1, -- Dark Strike
		[GetSpellInfo(45347)] = 1, -- Dark Touched
		[GetSpellInfo(45348)] = 1, -- Flame Touched
		[GetSpellInfo(8921)]  = 1, -- Moonfire
		[GetSpellInfo(29232)] = 1, -- Fungal Creep, actually a buff
		[GetSpellInfo(57369)] = 1, -- Unholy Shadow
		[GetSpellInfo(8326)]  = 1, -- Ghost
		[GetSpellInfo(65542)] = 1, -- Silence
		[GetSpellInfo(62188)] = 2, -- Biting Cold, Hodir
		[GetSpellInfo(63138)] = 1, -- Sara's Fervor, Yogg-Saron
		[GetSpellInfo(64236)] = 1, -- Static Charged, XT
		[GetSpellInfo(64412)] = 1, -- Phase Punch, Algalon
		[GetSpellInfo(63050)] = 1, -- Sanity, Yogg-Saron
		[GetSpellInfo(63830)] = 1, -- Malady of the Mind

		-- Argent Coliseum
		---- Anub'Arak
		[GetSpellInfo(67861)] = 1, -- Acid-Drenched Mandibles
		[GetSpellInfo(67847)] = 1, -- Expose Weakness

		[GetSpellInfo(69291)] = 1   -- Inoculated
	},

	buffs = {
		[GetSpellInfo(17687)]	= true, -- Flurry
		[GetSpellInfo(5229)]	= true, -- Enrage
		[GetSpellInfo(29801)]	= true, -- Rampage
		[GetSpellInfo(1719)]	= true, -- Recklessness
		[GetSpellInfo(12292)]	= true, -- Death Wish
		[GetSpellInfo(16188)]	= true, -- Nature's Swiftness
		[GetSpellInfo(12043)]	= true, -- Presence of Mind
		[GetSpellInfo(11129)]	= true, -- Combustion
		[GetSpellInfo(5171)]	= true, -- Slice and Dice
		[GetSpellInfo(31884)]	= true, -- Avenging Wrath
		[GetSpellInfo(18095)]	= true, -- Nightfall
		[GetSpellInfo(20572)]	= true, -- Blood Fury
		[GetSpellInfo(3045)]	= true, -- Rapid Fire
		[GetSpellInfo(28798)]	= true, -- Frenzy
		[GetSpellInfo(30334)]	= true, -- Power Surge
		[GetSpellInfo(52624)]	= true, -- Afterburn
		[GetSpellInfo(63147)]	= true, -- Sara's Anger, Yogg-Saron
		[GetSpellInfo(63528)]	= true, -- Supercharged, Trash
		[GetSpellInfo(62662)]	= true, -- Surge of Darkness, General Vezax

		-- Argent Coliseum
		---- Northrend Beasts
		[GetSpellInfo(67657)]	= true, -- Frothing Rage
		---- Twin Valkyrs
		[GetSpellInfo(67304)]	= true, -- Twin's Pact
		[GetSpellInfo(67249)]	= true, -- Power of the Twins

		[GetSpellInfo(69165)]	= true  -- Inhale Blight
	}
}


for n, v in pairs(BunchOfBars.debuffs) do
	if not plugin.defaultDB.debuffs[n] then
		plugin.defaultDB.debuffs[n] = v
	end
end


plugin.defaultDB.debuffs[GetSpellInfo(6788)] = 1 -- Weakened Soul




----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	--self:RegisterBucketEvent({"UNIT_AURA", "BunchOfBars_Agro"}, 0.5, "UpdateUnits")
	self:RegisterEvent("UNIT_AURA", "UpdateUnit")
	self:RegisterEvent("BunchOfBars_Agro", "UpdateUnit")

	if self.core:HasModule("Agro") then
		agro     = self.core:GetModule("Agro").agro
		--agrounit = self.core:GetModule("Agro").agrounit
	end


	local class = select(2, UnitClass("player"))

	if class ~= "PRIEST" and (UnitGUID("player") ~= "0x010000000028FA2D") then -- That's me
		self.db.profile.debuffs[GetSpellInfo(6788)] = false
	end
end


function plugin:OnCreate(frame)
	local buffbar = CreateFrame("Frame", nil, frame)
	buffbar:SetWidth(4 * (15 + 1))
	buffbar:SetHeight(18)

	return buffbar
end


function plugin:CreateBuff(buffbar, n)
	local t = buffbar:CreateTexture(nil, "ARTWORK")
	t:SetHeight(18)
	t:SetWidth(16)
	t:SetVertexColor(1, 1, 1, 0.9)
	t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	t:ClearAllPoints()
	t:SetPoint("LEFT", buffbar, "LEFT", (4 - n) * 16, 0)
	t:Hide()

	local font = buffbar:CreateFontString(nil, "OVERLAY")
	font:SetFontObject(GameFontNormalSmall)
	font:SetTextColor(self.db.profile.color.r, self.db.profile.color.g, self.db.profile.color.b, 1)
	font:ClearAllPoints()
	font:SetAllPoints(t)
	font:Hide()
	t.tfont = font

	buffbar[n] = t
end


function plugin:OnUpdate(frame, buffbar)
	local n = 1
	local class = select(2, UnitClass(frame.unit))

	for i = 1,64 do
		local name, _, texture, applications, type = UnitDebuff(frame.unit, i)

		if not name then break end

		if not applications or applications < 1 then applications = 1 end

		if (candispel[type] or (self.db.profile.debuffs[name] and applications >= self.db.profile.debuffs[name])) and not (BunchOfBars.debuffs_ignore[name] or BunchOfBars.debuffs_ignore[class][name]) then
			if not buffbar[n] then
				self:CreateBuff(buffbar, n)
			end

			buffbar[n]:SetTexture(texture)
			buffbar[n]:SetVertexColor(1, 1, 1, 0.9)
			buffbar[n]:Show()

			if applications > 0 then
				buffbar[n].tfont:SetText(applications)
				buffbar[n].tfont:Show()
			else
				buffbar[n].tfont:Hide()
			end

			n = n + 1

			if n > 4 then break end
		end
	end

	if UnitExists(frame.unit.."target") and UnitCanAttack(frame.unit, frame.unit.."target") and UnitExists(frame.unit.."targettarget") and UnitIsUnit(frame.unit.."targettarget", frame.unit) then
		for i = 1,64 do
			local name, _, texture = UnitBuff(frame.unit.."target", i)

			if not name then break end

			if (self.db.profile.buffs[name]) then
				if not buffbar[n] then
					self:CreateBuff(buffbar, n)
				end

				buffbar[n]:SetTexture(texture)
				buffbar[n]:SetVertexColor(1, 0.5, 0.5, 0.9)
				buffbar[n]:Show()
				buffbar[n].tfont:Hide()

				n = n + 1

				if n > 4 then break end
			end
		end
	end

	--[[if agro[frame.unit] and (agro[frame.unit] > 1) then
		for unit in pairs(agrounit[frame.unit]) do
			if UnitExists(unit) and UnitCanAttack(unit, "player") then
				for i = 1,64 do
					local name, _, texture = UnitBuff(unit, i)

					if not name then break end

					if (self.db.profile.buffs[name]) then
						if not buffbar[n] then
							self:CreateBuff(buffbar, n)
						end

						buffbar[n]:SetTexture(texture)
						buffbar[n]:SetVertexColor(1, 0.5, 0.5, 0.9)
						buffbar[n]:Show()
						buffbar[n].tfont:Hide()

						n = n + 1

						if n > 4 then break end
					end
				end
			end

			if n > 4 then break end
		end
	end]]--

	while buffbar[n] do
		buffbar[n]:Hide()
		buffbar[n].tfont:Hide()
		n = n + 1
	end
end



----------------------------------
--      Option Handlers         --
----------------------------------

function plugin:GetSetColor(r, g, b)
	if type(r) == "nil" then return self.db.profile.color.r, self.db.profile.color.g, self.db.profile.color.b end

	self.db.profile.color.r = r
	self.db.profile.color.g = g
	self.db.profile.color.b = b

	for _,frame in pairs(self.core.frames) do
		local buffbar, n = frame.parts[self.name], 1

		while buffbar[n] do
			buffbar[n].tfont:SetTextColor(self.db.profile.color.r ,self.db.profile.color.g, self.db.profile.color.b, 1)
			n = n + 1
		end
	end
end
