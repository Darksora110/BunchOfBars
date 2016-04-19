

local moduleName = "RangeCheck"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Range Check",

	["Check frequency"] = true,
	["Frequency in seconds."] = true
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "거리 체크",

	["Check frequency"] = "빈도 체크",
	["Frequency in seconds."] = "초당 빈도수"
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local IsSpellInRange = IsSpellInRange
local CheckInteractDistance = CheckInteractDistance

local InRangeSpell = false

local InRange = function(unit)
	--if UnitInVehicle(unit) and UnitControllingVehicle(unit) then
	--	unit = unit.."pet"
	--end

	if InRangeSpell == false then --or UnitInVehicle("player") then
		return CheckInteractDistance(unit, 1) -- ~28 yards
	else
		return IsSpellInRange(InRangeSpell, unit) == 1
	end
end




----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 103 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		frequency = {
			type = "range",
			name = L["Check frequency"],
			desc = L["Frequency in seconds."],
			min  = 0.1,
            max  = 5.0,
            step = 0.1,
            get  = "GetSetFrequency",
            set  = "GetSetFrequency",
		}
	}
}

plugin.defaultDB = {
	frequency = 0.5
}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnInitialize()
	local class = select(2, UnitClass("player"))

	-- 40 yard range check
	if class == "PRIEST" then
		InRangeSpell = GetSpellInfo(2050) -- Lesser Heal
	elseif class == "DRUID" then
		InRangeSpell = GetSpellInfo(5185) -- Healing Touch
	elseif class == "PALADIN" then
		InRangeSpell = GetSpellInfo(635) -- Holy Light
	elseif class == "SHAMAN" then
		InRangeSpell = GetSpellInfo(331) -- Healing Wave
	elseif class == "HUNTER" and UnitLevel("player") == 70 then
		InRangeSpell = GetSpellInfo(34477) -- Misdirection, 100 yards
	end
end


function plugin:OnEnable()
	self:ScheduleRepeatingEvent("BunchOfBars_RangeUpdate", self.UpdateAll, self.db.profile.frequency, self)

	if self.core:IsModuleActive("PetBar") then
		self:ScheduleRepeatingEvent("BunchOfBars_PetRangeUpdate", self.UpdateAllPets, self.db.profile.frequency, self)
	end
end


function plugin:OnUpdate(frame)
	if InRange(frame.unit) then -- this will also hide dead and offline players
		frame:SetAlpha(1.0)
	elseif frame:GetAlpha() == 1.0 then
		frame:SetAlpha(0.3)
	end
end


function plugin:OnUpdatePet(frame, bar)
	if not frame.pet then return end

	if InRange(frame.unit.."pet") then
		frame.pet:SetAlpha(1.0)
	elseif frame:GetAlpha() == 1.0 then
		frame.pet:SetAlpha(0.5)
	end
end



----------------------------------
--      Option Handlers         --
----------------------------------

function plugin:GetSetFrequency(value)
	if type(value) == "nil" then return self.db.profile.frequency end

	-- this check is to assure we don't reschedule the event to often
	if self.db.profile.frequency ~= value then
		self.db.profile.frequency = value
		
		self:OnEnable()
	end
end
