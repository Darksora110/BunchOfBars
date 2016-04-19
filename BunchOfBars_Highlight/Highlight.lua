

local moduleName = "Highlight"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Highlight"
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "강조"
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local target = "target"



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName, "AceHook-2.1")

plugin.revision = tonumber(("$Revision: 95 $"):match("%d+"))



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
end


function plugin:OnCreate(frame)
	local highlight = frame:CreateTexture(nil, "BACKGROUND")
	highlight:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
	highlight:SetVertexColor(1, 1, 1, 0.25)
	highlight:ClearAllPoints()
	highlight:SetAllPoints(frame)
	highlight:Hide()

	return highlight
end


function plugin:OnInactive(frame)
	if self:IsHooked(frame, "OnEnter") then
		self:Unhook(frame, "OnEnter")
		self:Unhook(frame, "OnLeave")
	end
end


function plugin:OnUpdate(frame)
	if not self:IsHooked(frame, "OnEnter") then
		self:HookScript(frame, "OnEnter")
		self:HookScript(frame, "OnLeave")
	end
end


function plugin:PLAYER_TARGET_CHANGED()
	if UnitIsEnemy("player", "target") then
		target = "targettarget"
	else
		target = "target"
	end

	self:UpdateAllWith(function(frame, highlight)
		if UnitIsUnit(frame.unit, target) then
			highlight:Show()
		else
			highlight:Hide()
		end
	end)
end


function plugin:OnEnter(frame)
	frame.parts[self.name]:Show()

	if frame:GetAlpha() < 1.0 then
		frame:SetAlpha(0.5)
	end

	self.hooks[frame].OnEnter(frame)
end


function plugin:OnLeave(frame)
	if not UnitIsUnit(frame.unit, target) then
		frame.parts[self.name]:Hide()
	end

	if frame:GetAlpha() < 1.0 then
		frame:SetAlpha(0.3)
	end

	self.hooks[frame].OnLeave(frame)
end
