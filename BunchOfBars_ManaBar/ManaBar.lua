

local moduleName = "ManaBar"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Mana Bar",

	["Texture"] = true,
	["The texture used for the mana bar."] = true,

	["Height"] = true,
	["Height of the bar."] = true,

	["Rage"] = true,
	["Show rage bars."] = true,

	["Energy"] = true,
	["Show energy bars."] = true,

	["Mana"] = true,
	["Show mana bars."] = true
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "마나 바",

	["Texture"] = "텍스처",
	["The texture used for the mana bar."] = "마나 바의 텍스처를 변경합니다.",

	["Height"] = "높이",
	["Height of the bar."] = "바의 높이를 설정합니다.",

	["Rage"] = "분노",
	["Show rage bars."] = "마나 바에 분노를 표시합니다.",

	["Energy"] = "기력",
	["Show energy bars."] = "마나 바에 기력을 표시합니다.",

	["Mana"] = "마나",
	["Show mana bars."] = "마나 바에 마나를 표시합니다."
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local SharedMedia     = LibStub("LibSharedMedia-3.0")
local SharedMediaType = SharedMedia.MediaType and SharedMedia.MediaType.STATUSBAR or "statusbar"

local texture


local UnitManaMax = UnitManaMax
local UnitMana = UnitMana
local UnitPowerType = UnitPowerType



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 102 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		texture = {
			type     = "text",
			name     = L["Texture"],
			desc     = L["The texture used for the mana bar."],
			get      = "GetSetTexture",
			set      = "GetSetTexture",
			validate = SharedMedia:List(SharedMediaType)
		},
		height = {
			type  = "range",
			name  = L["Height"],
			desc  = L["Height of the bar."],
			min   = 1,
            max   = 9,
            step  = 1,
            get   = "GetSetHeight",
            set   = "GetSetHeight"
		},

		mana = {
			type  = "toggle",
			name  = L["Mana"],
			desc  = L["Show mana bars."],
            get   = "GetSetMana",
            set   = "GetSetMana",
			order = 1
		},
		rage = {
			type  = "toggle",
			name  = L["Rage"],
			desc  = L["Show rage bars."],
            get   = "GetSetRage",
            set   = "GetSetRage",
			order = 2
		},
		energy = {
			type  = "toggle",
			name  = L["Energy"],
			desc  = L["Show energy bars."],
            get   = "GetSetEnergy",
            set   = "GetSetEnergy",
			order = 3
		}
	}
}

plugin.defaultDB = {
	texture   = "Charcoal",
	height    = 2,

	rage   = false,
	energy = false,
	mana   = true
}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	texture = SharedMedia:Fetch(SharedMediaType, self.db.profile.texture)

	self:RegisterEvents()
end


function plugin:OnCreate(frame)
	local bar = CreateFrame("StatusBar", nil, frame.parts["HealthBar"])
	bar:SetStatusBarTexture(texture)
	bar:SetFrameLevel(6)
	bar:SetHeight(self.db.profile.height)
	bar:ClearAllPoints()
	bar:SetPoint("BOTTOMLEFT", frame.parts["HealthBar"], "BOTTOMLEFT", 0, 0)
	bar:SetPoint("BOTTOMRIGHT", frame.parts["HealthBar"], "BOTTOMRIGHT", 0, 0)
	bar:Hide()

	return bar
end


function plugin:OnUpdate(frame, bar)
	local t = UnitPowerType(frame.unit)

	if t == 0 and self.db.profile.mana then
		bar:SetStatusBarColor(48/255, 113/255, 191/255)
	elseif t == 1 and self.db.profile.rage then
		bar:SetStatusBarColor(226/255, 45/255, 75/255)
	elseif t == 3 and self.db.profile.energy then
		bar:SetStatusBarColor(1, 220/255, 25/255)
	else
		bar:Hide()
		return
	end

	bar:SetMinMaxValues(0, UnitManaMax(frame.unit))
	bar:SetValue(UnitMana(frame.unit))

	bar:Show()
end


function plugin:RegisterEvents()
	self:UnregisterAllEvents()

	local e = { }

	if self.db.profile.mana then
		table.insert(e, "UNIT_MANA")
		table.insert(e, "UNIT_MAXMANA")
	end

	if self.db.profile.rage then
		table.insert(e, "UNIT_RAGE")
		table.insert(e, "UNIT_MAXRAGE")
	end

	if self.db.profile.energy then
		table.insert(e, "UNIT_ENERGY")
		table.insert(e, "UNIT_MAXENERGY")
	end

	if table.getn(e) > 0 then
		table.insert(e, "UNIT_DISPLAYPOWER")

		self:RegisterBucketEvent(e, 0.5, "UpdateUnits")
	end
end



----------------------------------
--      Option Handlers         --
----------------------------------

function plugin:GetSetTexture(v)
	if type(v) == "nil" then return self.db.profile.texture end

	if self.db.profile.texture ~= v then
		self.db.profile.texture = v

		texture = SharedMedia:Fetch(SharedMediaType, self.db.profile.texture)

		self:UpdateAllWith(function(frame, bar)
			bar:SetStatusBarTexture(texture)
		end)
	end
end


function plugin:GetSetHeight(v)
	if type(v) == "nil" then return self.db.profile.height end

	if self.db.profile.height ~= v then
		self.db.profile.height = v

		self:UpdateAllWith(function(frame, bar)
			bar:SetHeight(self.db.profile.height)
		end)
	end
end


function plugin:GetSetRage(v)
	if type(v) == "nil" then return self.db.profile.rage end

	if self.db.profile.rage ~= v then
		self.db.profile.rage = v

		self:UpdateAll()
		self:RegisterEvents()
	end
end

function plugin:GetSetEnergy(v)
	if type(v) == "nil" then return self.db.profile.energy end

	if self.db.profile.energy ~= v then
		self.db.profile.energy = v

		self:UpdateAll()
		self:RegisterEvents()
	end
end

function plugin:GetSetMana(v)
	if type(v) == "nil" then return self.db.profile.mana end

	if self.db.profile.mana ~= v then
		self.db.profile.mana = v

		self:UpdateAll()
		self:RegisterEvents()
	end
end
