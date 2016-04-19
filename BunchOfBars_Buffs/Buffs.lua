

local moduleName = "Buffs"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Buffs",

	["Always"] = true,
	["Enable/Disable buffs which are always shown."] = true,

	["Out Of Combat"] = true,
	["Enable/Disable Out of combat buffs."] = true,

	["Text Color"] = true,
	["Change the text color."] = true,

	["Enable/Disable showing of "] = true
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "Buffs",

	["Always"] = "항상",
	["Enable/Disable buffs which are always shown."] = "버프를 항상 표시할 것인지 선택합니다.",

	["Out Of Combat"] = "전투종료",
	["Enable/Disable Out of combat buffs."] = "전투종료를 표시할 것인지 선택합니다.",

	["Text Color"] = "글자 색상",
	["Change the text color."] = "글자의 색상을 변경합니다.",

	["Enable/Disable showing of "] = "보기설정 : "
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local buffs = {
	{"DRUID", true , GetSpellInfo(774)},   -- Rejuvenation
	{"DRUID", true , GetSpellInfo(8936)},  -- Regrowth
	{"DRUID", true , GetSpellInfo(33763)}, -- Lifebloom
	{"DRUID", true , GetSpellInfo(48438)}, -- Wild Growth
	{"DRUID", false, GetSpellInfo(1126)},  -- Mark of the Wild
	{"DRUID", false, GetSpellInfo(21849)}, -- Gift of the Wild
	{"DRUID", false, GetSpellInfo(467)},   -- Thorns
	{"DRUID", true , GetSpellInfo(29166)}, -- Innervate
	{"DRUID", false, GetSpellInfo(65139)}, -- Tree of Life
	{"DRUID", true , GetSpellInfo(22842)}, -- Frenzied Regeneration
	{"DRUID", true , GetSpellInfo(2893)},  -- Abolish Poison
	{"DRUID", false, GetSpellInfo(22812)}, -- Barkskin
	{"DRUID", true , GetSpellInfo(48496)}, -- Living Seed

	{"PRIEST", false, GetSpellInfo(1243)},  -- Power Word: Fortitude
	{"PRIEST", false, GetSpellInfo(21562)}, -- Prayer of Fortitude
	{"PRIEST", true , GetSpellInfo(17)},    -- Power Word: Shield
	{"PRIEST", true , GetSpellInfo(139)},   -- Renew
	{"PRIEST", false, GetSpellInfo(976)},   -- Shadow Protection
	{"PRIEST", false, GetSpellInfo(27683)}, -- Prayer of Shadow Protection
	{"PRIEST", false, GetSpellInfo(14752)}, -- Divine Spirit
	{"PRIEST", false, GetSpellInfo(27681)}, -- Prayer of Spirit
	{"PRIEST", true , GetSpellInfo(6346)},  -- Fear Ward
	{"PRIEST", true , GetSpellInfo(33076)}, -- Prayer of Mending
	{"PRIEST", true , GetSpellInfo(552)},   -- Abolish Disease
	{"PRIEST", true , GetSpellInfo(28880)}, -- Gift of the Naaru
	{"PRIEST", true , GetSpellInfo(47585)}, -- Dispersion
	{"PRIEST", true , GetSpellInfo(47788)}, -- Guardian Spirit
	{"PRIEST", true , GetSpellInfo(7001)},  -- Lightwell Renew
	{"PRIEST", true , GetSpellInfo(33206)}, -- Pain Suppression

	{"PALADIN", false, GetSpellInfo(20217)}, -- Blessing of Kings
	{"PALADIN", false, GetSpellInfo(32770)}, -- Blessing of Light
	{"PALADIN", false, GetSpellInfo(19740)}, -- Blessing of Might
	{"PALADIN", false, GetSpellInfo(20911)}, -- Blessing of Sanctuary
	{"PALADIN", false, GetSpellInfo(19742)}, -- Blessing of Wisdom
	{"PALADIN", true , GetSpellInfo(1022)},  -- Hand of Protection
	{"PALADIN", false, GetSpellInfo(1038)},  -- Hand of Salvation
	{"PALADIN", false, GetSpellInfo(25898)}, -- Greater Blessing of Kings
	{"PALADIN", false, GetSpellInfo(25782)}, -- Greater Blessing of Might
	{"PALADIN", false, GetSpellInfo(25899)}, -- Greater Blessing of Sanctuary
	{"PALADIN", false, GetSpellInfo(25894)}, -- Greater Blessing of Wisdom
	{"PALADIN", true , GetSpellInfo(633)},   -- Lay on Hands
	{"PALADIN", true , GetSpellInfo(53563)}, -- Beacon of Light
	{"PALADIN", true , GetSpellInfo(498)},   -- Divine Protection
	{"PALADIN", true , GetSpellInfo(54428)}, -- Divine Plea

	{"MAGE", false, GetSpellInfo(1459)},  -- Arcane Intellect
	{"MAGE", false, GetSpellInfo(23028)}, -- Arcane Brilliance
	{"MAGE", false, GetSpellInfo(61024)}, -- Dalaran Intellect
	{"MAGE", false, GetSpellInfo(61316)}, -- Dalaran Brilliance
	{"MAGE", true , GetSpellInfo(45438)}, -- Ice Block
	{"MAGE", true , GetSpellInfo(11426)}, -- Ice Barrier
	{"MAGE", true , GetSpellInfo(1463)},  -- Mana Shield
	{"MAGE", true , GetSpellInfo(66)},    -- Invisibility

	{"WARLOCK", false, GetSpellInfo(20707)}, -- Soulstone Resurrection
	{"WARLOCK", false, GetSpellInfo(6307)},  -- Blood Pact

	{"WARRIOR", true, GetSpellInfo(871)},  -- Shield Wall
	{"WARRIOR", true, GetSpellInfo(12975)}, -- Last Stand

	{"HUNTER", true, GetSpellInfo(34477)}, -- Misdirection
	{"HUNTER", true, GetSpellInfo(5384)},  -- Feign Death
	{"HUNTER", true, GetSpellInfo(781)},   -- Disengage

	{"SHAMAN", true , GetSpellInfo(974)},  -- Earth Shield
	{"SHAMAN", false, GetSpellInfo(32182)}, -- Heroism
	{"SHAMAN", false, GetSpellInfo(61295)}, -- Riptide

	{"ROGUE", true, GetSpellInfo(5277)}, -- Evasion

	{"DEATHKNIGHT", true, GetSpellInfo(48792)},  -- Icebound Fortitude
	{"DEATHKNIGHT", false, GetSpellInfo(49039)}, -- Lichborne
	{"DEATHKNIGHT", false, GetSpellInfo(51271)}, -- Unbreakable Armor


	{false, true,  GetSpellInfo(63711)}, -- Storm Power, Hodir
	{false, true,  GetSpellInfo(65123)}, -- Storm Cloud, Hodir
	{false, true,  GetSpellInfo(62320)}, -- Aura of Celerity, Thorim
	{false, false, GetSpellInfo(16870)}  -- Clearcasting
}

local incombat = false

-- localize these functions to speed up our main loop
local UnitBuff = UnitBuff
local UnitAffectingCombat = UnitAffectingCombat



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 103 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		always = {
			type = "group",
			name = L["Always"],
			desc = L["Enable/Disable buffs which are always shown."],
			args = { }
		},
		ooc = {
			type = "group",
			name = L["Out Of Combat"],
			desc = L["Enable/Disable Out of combat buffs."],
			args = { }
		},
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
	position = 3,

	always = {}, -- these are automatically filled
	ooc    = {},
	color  = {
		r = 1,
		g = 1,
		b = 0
	}
}


do -- let's not pollute our name space
	local _,class = UnitClass("player")

	for i,a in ipairs(buffs) do
		local cname = a[3]

		if a[1] then
			cname = "|cff"..string.format("%02x%02x%02x", RAID_CLASS_COLORS[a[1]].r * 255, RAID_CLASS_COLORS[a[1]].g * 255, RAID_CLASS_COLORS[a[1]].b * 255)..cname.."|r"
		end

		plugin.options.args.always.args[a[3]] = {
			type  = "toggle",
			name  = cname,
			desc  = L["Enable/Disable showing of "]..a[3],
			get   = function() return plugin.db.profile.always[a[3]] end,
			set   = function(v)
						plugin.db.profile.always[a[3]] = v

						if v then
							plugin.db.profile.ooc[a[3]] = false
						end
					end,
			order = i
		}

		plugin.options.args.ooc.args[a[3]] = {
			type  = "toggle",
			name  = cname,
			desc  = L["Enable/Disable showing of "]..a[3],
			get   = function() return plugin.db.profile.ooc[a[3]] end,
			set   = function(v)
						plugin.db.profile.ooc[a[3]] = v

						if v then
							plugin.db.profile.always[a[3]] = false
						end
					end,
			order = i
		}

		if a[2] then
			plugin.defaultDB.always[a[3]] = true
			plugin.defaultDB.ooc[a[3]]    = false
		elseif a[1] == class then
		    plugin.defaultDB.always[a[3]] = false
			plugin.defaultDB.ooc[a[3]]    = true
		else
			plugin.defaultDB.always[a[3]] = false
			plugin.defaultDB.ooc[a[3]]    = false
		end
	end
end



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	self:ScheduleRepeatingEvent(self.Update, 0.5, self) -- can't use UNIT_AURA cause we need to update timers
end


function plugin:OnCreate(frame)
	local buffbar = CreateFrame("Frame", nil, frame)
	buffbar:SetWidth(4 * (16 + 1))
	buffbar:SetHeight(18)

	return buffbar
end


function plugin:CreateBuff(buffbar, n)
	local t = buffbar:CreateTexture(nil, "ARTWORK")
	t:SetHeight(18)
	t:SetWidth(15)
	t:SetVertexColor(1, 1, 1, 0.6)
	t:SetTexCoord(0.2, 0.8, 0.1, 0.9)
	t:ClearAllPoints()
	t:SetPoint("LEFT", buffbar, "LEFT", (n - 1) * 16, 0)
	t:Hide()

	local font = buffbar:CreateFontString(nil, "OVERLAY")
	font:SetFontObject(GameFontNormalSmall)
	font:SetTextColor(self.db.profile.color.r, self.db.profile.color.g, self.db.profile.color.b, 1)
	font:ClearAllPoints()
	font:SetAllPoints(t)
	font:Hide()
	t.tfont = font

	font = buffbar:CreateFontString(nil, "OVERLAY")
	font:SetFontObject(GameFontNormalSmall)
	font:SetTextHeight(10)
	font:SetTextColor(1, 0, 0, 0.6)
	font:ClearAllPoints()
	font:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 0, 0)
	font:Hide()
	t.afont = font

	buffbar[n] = t
end


function plugin:OnUpdate(frame, buffbar)
	local n = 1

	for i = 1,64 do
		local name, _, texture, applications, _, duration, timeleft, mine = UnitBuff(frame.unit, i)

		if not name then break end

		if self.db.profile.always[name] or (not incombat and self.db.profile.ooc[name]) then
			if not buffbar[n] then
				self:CreateBuff(buffbar, n)
			end

			if mine and UnitIsUnit("player", mine) then
				buffbar[n]:SetAlpha(0.7)
			else
				buffbar[n]:SetAlpha(0.3)
			end

			buffbar[n]:SetTexture(texture)
			buffbar[n]:Show()

			if timeleft and timeleft > 0 then
				timeleft = timeleft - GetTime()

				if timeleft > 60 then timeleft = timeleft / 60 end
				timeleft = math.floor(timeleft)

				if mine then
					buffbar[n].tfont:SetAlpha(1)
				else
					buffbar[n].tfont:SetAlpha(0.4)
				end

				buffbar[n].tfont:SetText(timeleft)
				buffbar[n].tfont:Show()
			else
				buffbar[n].tfont:Hide()
			end

			if applications > 0 then
				if mine then
					buffbar[n].afont:SetAlpha(1)
				else
					buffbar[n].afont:SetAlpha(0.4)
				end

				buffbar[n].afont:SetText(applications)
				buffbar[n].afont:Show()
			else
				buffbar[n].afont:Hide()
			end

			n = n + 1
		end
	end

	while buffbar[n] do
		buffbar[n]:Hide()
		buffbar[n].tfont:Hide()
		buffbar[n].afont:Hide()
		n = n + 1
	end
end


function plugin:Update()
	incombat = UnitAffectingCombat("player") or UnitAffectingCombat("target")

	self:UpdateAll()
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
