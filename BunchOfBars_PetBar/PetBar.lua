

local moduleName = "PetBar"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Pet Bar",

	["Texture"] = true,
	["The texture used for the pet bar."] = true,

	["Height"] = true,
	["Height of the bar."] = true,

	["Width"] = true,
	["Width of the bar."] = true,

	["Vertical"] = true,
	["Use a vertical bar that grows from down to up."] = true
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local SharedMedia     = LibStub("LibSharedMedia-3.0")
local SharedMediaType = SharedMedia.MediaType and SharedMedia.MediaType.STATUSBAR or "statusbar"

local texture

local UnitHealthMax = UnitHealthMax
local UnitHealth = UnitHealth



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 106 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		texture = {
			type     = "text",
			name     = L["Texture"],
			desc     = L["The texture used for the pet bar."],
			get      = "GetSetTexture",
			set      = "GetSetTexture",
			validate = SharedMedia:List(SharedMediaType)
		},
		height = {
			type  = "range",
			name  = L["Height"],
			desc  = L["Height of the bar."],
			min   = 1,
            max   = 18,
            step  = 1,
            get   = "GetSetHeight",
            set   = "GetSetHeight",
			disabled = function() return InCombatLockdown() end
		},
		width = {
			type  = "range",
			name  = L["Width"],
			desc  = L["Width of the bar."],
			min   = 5,
            max   = 60,
            step  = 1,
            get   = "GetSetWidth",
            set   = "GetSetWidth",
			disabled = function() return InCombatLockdown() end
		},
		vertical = {
			type     = "toggle",
			name     = L["Vertical"],
			desc     = L["Use a vertical bar that grows from down to up."],
            get      = "GetSetVertical",
            set      = "GetSetVertical"
		},
	}
}

plugin.defaultDB = {
	texture   = "Charcoal",
	height    = 14,
	width	  = 10,
	vertical  = true
}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	texture = SharedMedia:Fetch(SharedMediaType, self.db.profile.texture)

	self:RegisterBucketEvent({"UNIT_HEALTH", "UNIT_MAXHEALTH"}, 0.5, "UpdatePets")
	--self:RegisterEvent("UNIT_HEALTH", "UpdatePet")
	--self:RegisterEvent("UNIT_MAXHEALTH", "UpdatePet")
	self:RegisterEvent("UNIT_PET", "UpdateUnit")
end


function plugin:OnCreate(frame)
	if InCombatLockdown() then
		return nil
	end

	local pet = CreateFrame("Button", nil, frame, "SecureUnitButtonTemplate")
	pet:SetAttribute("type1", "target")
	pet:SetAttribute("*type1", "target")
	pet:SetFrameLevel(7)
	pet:SetHeight(self.db.profile.height)
	pet:SetWidth(self.db.profile.width)
	pet:ClearAllPoints()
	pet:SetPoint("BOTTOMLEFT", frame.parts["HealthBar"], "BOTTOMLEFT", 0, 0)
	frame.pet = pet

	local bar = CreateFrame("StatusBar", nil, pet)
	bar:SetStatusBarTexture(texture)
	bar:SetOrientation(self.db.profile.vertical and "VERTICAL" or "HORIZONTAL")
	bar:SetAllPoints(pet)
	bar:Show()
	pet.bar = bar

	local back = pet:CreateTexture(nil, "OVERLAY")
	back:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
	back:SetVertexColor(0, 0, 0, 0.6)
	back:ClearAllPoints()
	back:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
	back:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 1, 1)
	--back:SetAllPoints(bar)
	back:Show()
	bar.back = back
	
	pet:Hide()

	return pet
end


function plugin:OnUpdate(frame, pet)
	if not InCombatLockdown() then
		if not pet then
			pet = self:OnCreate(frame)
			frame.parts[moduleName] = pet
		end

		if UnitExists(frame.unit.."pet") then
			pet:SetAttribute("unit", frame.unit.."pet")
			ClickCastFrames[pet] = true
			pet:Show()
		else
			pet:Hide()
			ClickCastFrames[pet] = nil
		end

		self:OnUpdatePet(frame, pet)
	end
end


function plugin:OnUpdatePet(frame, pet)
	if not pet then return end

	local m = UnitHealthMax(frame.unit.."pet")
	local c = UnitHealth(frame.unit.."pet")

	pet.bar:SetMinMaxValues(0, m)
	pet.bar:SetValue(c)

	local p = c / m
	local r, g

	if p >= 0.5 then
		r, g = (1 - p) * 2, 1
	else
		r, g = 1, p * 2
	end

	pet.color = {r, g, 0}

	if not pet.dispel then
		pet.bar:SetStatusBarColor(r, g, 0)
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

		self:UpdateAllWith(function(frame, pet)
			pet.bar:SetStatusBarTexture(texture)
		end)
	end
end


function plugin:GetSetHeight(v)
	if type(v) == "nil" then return self.db.profile.height end

	if self.db.profile.height ~= v then
		self.db.profile.height = v

		self:UpdateAllWith(function(frame, pet)
			pet:SetHeight(self.db.profile.height)
		end)
	end
end


function plugin:GetSetWidth(v)
	if type(v) == "nil" then return self.db.profile.width end

	if self.db.profile.width ~= v then
		self.db.profile.width = v

		self:UpdateAllWith(function(frame, pet)
			pet:SetWidth(self.db.profile.width)
		end)
	end
end


function plugin:GetSetVertical(v)
	if type(v) == "nil" then return self.db.profile.vertical end

	if self.db.profile.vertical ~= v then
		self.db.profile.vertical = v

		self:UpdateAllWith(function(frame, pet)
			pet.bar:SetOrientation(self.db.profile.vertical and "VERTICAL" or "HORIZONTAL")
		end)
	end
end
