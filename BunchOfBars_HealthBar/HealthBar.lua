

local moduleName = "HealthBar"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Health Bar",

	["Agro Color"] = true,
	["Color the healthbar of the person with agro red."] = true,

	["Texture"] = true,
	["The texture used for the health bar."] = true,

	["Deficit"] = true,
	["Show how much health a person is missing instead of how much he has."] = true,

	["Class Color"] = true,
	["Color the healthbars according class."] = true,

	["Width"] = true,
	["Width of the bar."] = true
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "생명력 바",

	["Agro Color"] = "어그로 색상",
	["Color the healthbar of the person with agro red."] = "어그로를 획득한 캐릭터의 생명력 바 색상을 붉은색으로 표시합니다.",

	["Texture"] = "텍스처",
	["The texture used for the health bar."] = "생명력바에 텍스처를 사용합니다.",

	["Deficit"] = "결손치",
	["Show how much health a person is missing instead of how much he has."] = "생명력을 잃어버린 결손치로 표시합니다."
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local SharedMedia     = LibStub("LibSharedMedia-3.0")
local SharedMediaType = SharedMedia.MediaType and SharedMedia.MediaType.STATUSBAR or "statusbar"

local texture

local agro = { }


local UnitHealthMax = UnitHealthMax
local UnitHealth = UnitHealth
local UnitClass = UnitClass



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 103 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		agrocolor = {
			type     = "toggle",
			name     = L["Agro Color"],
			desc     = L["Color the healthbar of the person with agro red."],
			disabled = function() return not plugin.core:HasModule("Agro") end,
            get      = "GetSetAgroColor",
            set      = "GetSetAgroColor"
		},
		texture = {
			type = "text",
			name = L["Texture"],
			desc = L["The texture used for the health bar."],
			get  = "GetSetTexture",
			set  = "GetSetTexture",
			validate = SharedMedia:List(SharedMediaType),
		},
		deficit = {
			type     = "toggle",
			name     = L["Deficit"],
			desc     = L["Show how much health a person is missing instead of how much he has."],
            get      = "GetSetDeficit",
            set      = "GetSetDeficit"
		},
		classcolor = {
			type     = "toggle",
			name     = L["Class Color"],
			desc     = L["Color the healthbars according class."],
            get      = "GetSetClassColor",
            set      = "GetSetClassColor"
		},
		width = {
			type  = "range",
			name  = L["Width"],
			desc  = L["Width of the bar."],
			min   = 80,
            max   = 200,
            step  = 10,
            get   = "GetSetWidth",
            set   = "GetSetWidth",
			disabled = function() return InCombatLockdown() end
		},
	}
}

plugin.defaultDB = {
	position = 2,

	agrocolor  = true,
	texture    = "Charcoal",
	deficit    = false,
	classcolor = false,
	width	   = 100
}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	if self.db.profile.agrocolor then
		if self.core:HasModule("Agro") then
			agro = self.core:GetModule("Agro").agro
		else
			self.db.profile.agrocolor = false
		end
	end

	texture = SharedMedia:Fetch(SharedMediaType, self.db.profile.texture)

	self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
	self:RegisterEvent("BunchOfBars_Agro", "UpdateUnit")
end


function plugin:OnCreate(frame)
	local bar = CreateFrame("StatusBar", nil, frame)
	bar:SetStatusBarTexture(texture)
	bar:SetFrameLevel(3)
	bar:SetWidth(self.db.profile.width)
	bar:SetHeight(18)
	bar:Show()

	local back = frame:CreateTexture(nil, "OVERLAY")
	back:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
	back:SetVertexColor(0, 0, 0, 1)
	back:ClearAllPoints()
	back:SetAllPoints(bar)
	back:Show()

	bar.back = back

	return bar
end


function plugin:OnUpdate(frame, bar)
	local m = UnitHealthMax(frame.unit)
	local c = UnitHealth(frame.unit)

	bar:SetMinMaxValues(0, m)

	if self.db.profile.deficit then
		bar:SetValue(m - c)
	else
		bar:SetValue(c)
	end

	if agro[frame.unit] and (agro[frame.unit] > 0) then
		--[[if agro[frame.unit] < 1.5 then
			bar:SetStatusBarColor(1, 0.5, 0)
			bar.back:SetVertexColor(0.25, 0.125, 0, 1)
		else
			bar:SetStatusBarColor(1, 0, 0)
			bar.back:SetVertexColor(0.25, 0, 0, 1)
		end]]--

		bar:SetStatusBarColor(GetThreatStatusColor(agro[frame.unit]))

		if agro[frame.unit] > 1 then
			bar.back:SetVertexColor(0.25, 0, 0, 1)
		else
			bar.back:SetVertexColor(0.25, 0.125, 0, 1)
		end
	else
		bar.back:SetVertexColor(0, 0, 0, 1)

		if self.db.profile.classcolor then
			local _, c = UnitClass(frame.unit)

			c = RAID_CLASS_COLORS[c]

			bar:SetStatusBarColor(c.r, c.g, c.b)
		else
			local p = c / m
			local r, g

			if p >= 0.5 then
				r, g = (1 - p) * 2, 1
			else
				r, g = 1, p * 2
			end

			bar:SetStatusBarColor(r, g, 0)
		end
	end
end



----------------------------------
--      Option Handlers         --
----------------------------------

function plugin:GetSetAgroColor(v)
	if type(v) == "nil" then return self.db.profile.agrocolor end

	if self.db.profile.agrocolor ~= v then
		self.db.profile.agrocolor = v

		if self.db.profile.agrocolor then
			agro = self.core:GetModule("Agro").agro
		else
			agro = { }
		end
	end
end


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


function plugin:GetSetDeficit(v)
	if type(v) == "nil" then return self.db.profile.deficit end

	if self.db.profile.deficit ~= v then
		self.db.profile.deficit = v

		self:UpdateAll()
	end
end


function plugin:GetSetClassColor(v)
	if type(v) == "nil" then return self.db.profile.classcolor end

	if self.db.profile.classcolor ~= v then
		self.db.profile.classcolor = v

		self:UpdateAll()
	end
end


function plugin:GetSetWidth(v)
	if type(v) == "nil" then return self.db.profile.width end

	if self.db.profile.width ~= v then
		self.db.profile.width = v

		self:UpdateAllWith(function(frame, bar)
			bar:SetWidth(self.db.profile.width)
		end)

		self.core:UpdateLayouts()
	end
end
