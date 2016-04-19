
local moduleName = "Maintank"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Maintank",

	["Scale"] = true,
	["Maintank frame scale."] = true
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "메인탱커",

	["Scale"] = "크기",
	["Maintank frame scale."] = "메인탱커 프레임의 크기를 조절합니다."
} end)



----------------------------------
--      Local Declaration      --
----------------------------------



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 90 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		frequency = {
			type = "range",
			name = L["Scale"],
			desc = L["Maintank frame scale."],
			min = 1,
            max = 2.0,
            step = 0.1,
            get = "GetSetScale",
            set = "GetSetScale",
		}
	}
}

plugin.defaultDB = {
	scale = 1.2
}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	self:RegisterEvent("oRA_MainTankUpdate" , "UpdateAll")
	self:RegisterEvent("oRA_UpdateConfigGUI", "UpdateAll") -- for oRA player targets
	self:RegisterEvent("RAID_ROSTER_UPDATE" , "UpdateAll") -- for the blizzard buildin maintank table

	if _G.CT_RAOptions_UpdateMTs then
		hooksecurefunc("CT_RAOptions_UpdateMTs", function() self:UpdateAll() end)
	end
end


function plugin:OnUpdate(frame)
	if InCombatLockdown() then return end

	frame:SetScale(1.0)

	-- check oRA2
	if oRA then
		if oRA.maintanktable then
			self:CheckTable(frame, oRA.maintanktable)
		end

		if oRA:HasModule("OptionalPT") then
			self:CheckTable(frame, oRA:GetModule("OptionalPT").db.profile.playertable)
		end
	end

	-- check CT_RaidAssist
	if CT_RA_MainTanks then
		self:CheckTable(frame, CT_RA_MainTanks)
	end


	-- check the blizzard buildin maintank table
	if GetPartyAssignment("MAINTANK", frame.unit) then
		frame:SetScale(self.db.profile.scale)
	end
end


function plugin:CheckTable(frame, tanks)
	local name = UnitName(frame.unit)

	for _,v in pairs(tanks) do -- the key is the tank number
		if v == name then
			frame:SetScale(self.db.profile.scale)
			break
		end
	end
end



----------------------------------
--      Option Handlers         --
----------------------------------

function plugin:GetSetScale(value)
	if type(value) == "nil" then return self.db.profile.scale end

	-- this check is to assure we don't update to often
	if self.db.profile.scale ~= value then
		self.db.profile.scale = value

		self:UpdateAll()
	end
end
