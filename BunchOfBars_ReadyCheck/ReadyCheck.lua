

local moduleName = "ReadyCheck"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Ready Check",

	["Justification"] = true,
	["Set the horizontal justification."] = true
} end)

L:RegisterTranslations("koKR", function() return {
	["Justification"] = "표시",
	["Set the horizontal justification."] = "아이콘 위치를 설정합니다."
} end)

----------------------------------
--      Local Declaration      --
----------------------------------

local checking = false
local alpha    = 0



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 63 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		justification = {
			type     = "text",
			name     = L["Justification"],
			desc     = L["Set the horizontal justification."],
			usage    = "",
			validate = { "LEFT", "CENTER", "RIGHT" },
			get      = "GetSetJustification",
			set      = "GetSetJustification"
		}
	}
}

plugin.defaultDB = {
	justification = "RIGHT"
}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM", "UpdateAll")
	self:RegisterEvent("READY_CHECK_FINISHED")
end


function plugin:OnCreate(frame)
	local icon = frame.parts["HealthBar"]:CreateTexture(nil, "OVERLAY")
	icon:SetHeight(14)
	icon:SetWidth(14)
	icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
	icon:SetTexCoord(0.04, 0.96, 0.04, 0.96)
	self:SetPoints(frame, icon)
	icon:Hide()

	return icon
end


function plugin:SetPoints(frame, icon)
	icon:ClearAllPoints()

	if self.db.profile.justification == "LEFT" then
		icon:SetPoint("LEFT", frame.parts["HealthBar"], "LEFT", 2, 0)
	elseif self.db.profile.justification == "CENTER" then
		icon:SetPoint("CENTER", frame.parts["HealthBar"], "CENTER", 0, 0)
	else
		icon:SetPoint("RIGHT", frame.parts["HealthBar"], "RIGHT", -2, 0)
	end
end


function plugin:FadeOut()
	alpha = alpha - 0.2

	self:UpdateAll()
end


function plugin:OnUpdate(frame, icon)
	if checking then
		local status = GetReadyCheckStatus(frame.unit)

		if status == "ready" then
			icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
		elseif status == "notready" then
			icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
		else
			icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
		end
	end

	if alpha > 0 then
		icon:SetAlpha(alpha)
		icon:Show()
	else
		icon:Hide()
	end
end


function plugin:READY_CHECK()
	if IsRaidLeader() or IsRaidOfficer() or IsPartyLeader() then
		checking = true
		alpha    = 1.0
		self:UpdateAll()
	end
end


function plugin:READY_CHECK_FINISHED()
	checking = false

	self:ScheduleEvent(self.FadeOut, 0.5, self)
	self:ScheduleEvent(self.FadeOut, 1  , self)
	self:ScheduleEvent(self.FadeOut, 1.5, self)
	self:ScheduleEvent(self.FadeOut, 2  , self)
	self:ScheduleEvent(self.FadeOut, 3  , self)
end



----------------------------------
--      Option Handlers         --
----------------------------------

function plugin:GetSetJustification(v)
	if type(v) == "nil" then return self.db.profile.justification end

	if self.db.profile.justification ~= v then
		self.db.profile.justification = v

		self:UpdateAllWith("SetPoints")
	end
end
