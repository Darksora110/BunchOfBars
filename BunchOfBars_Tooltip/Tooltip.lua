

local moduleName = "Tooltip"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Tooltip",

	["Show Tooltip"] = true,
	["When to show the unit's tooltip."] = true,

	["Always"] = true,
	["Out Of Combat"] = true,
	["Never"] = true
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "툴팁",

	["Show Tooltip"] = "툴팁 보기",
	["When to show the unit's tooltip."] = "유닛의 툴팁을 표시합니다.",

	["Always"] = "항상",
	["Out Of Combat"] = "비전투시",
	["Never"] = "보지않음"
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local tooltip = {
	L["Out Of Combat"],
	L["Always"],
	L["Never"]
}

local tooltiprev = { } -- reverse lookup of the tooltip table
do
	for k,v in ipairs(tooltip) do
		tooltiprev[v] = k
	end
end



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName, "AceHook-2.1")

plugin.revision = tonumber(("$Revision: 95 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		tooltip = {
			type     = "text",
			name     = L["Show Tooltip"],
			desc     = L["When to show the unit's tooltip."],
			usage    = "",
			validate = tooltip,
			get      = "GetSetToolTip",
			set      = "GetSetToolTip"
		}
	}
}
		
plugin.defaultDB = {
	showtooltip = 1 -- Out Of Combat
}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnUpdate(frame)
	if not self:IsHooked(frame, "OnEnter") then
		self:HookScript(frame, "OnEnter")
		self:HookScript(frame, "OnLeave")
	end
end


function plugin:OnInactive(frame)
	if self:IsHooked(frame, "OnEnter") then
		self:Unhook(frame, "OnEnter")
		self:Unhook(frame, "OnLeave")
	end
end


function plugin:OnEnter(frame)
	if self.db.profile.showtooltip == 2 or -- Always
	   (self.db.profile.showtooltip == 1 and not InCombatLockdown()) then -- Out Of Combat
	    this.unit = frame.unit
		UnitFrame_OnEnter(this)
		frame:SetScript("OnUpdate", UnitFrame_OnUpdate)

		--GameTooltip:AppendText(" |cffff0000("..frame.unit..")|r") -- Useful for testing.
	end

	self.hooks[frame].OnEnter(frame)
end


function plugin:OnLeave(frame)
	UnitFrame_OnLeave()
	frame:SetScript("OnUpdate", nil)

	self.hooks[frame].OnLeave(frame)
end



----------------------------------
--      Option Handlers         --
----------------------------------

function plugin:GetSetToolTip(v)
	if type(v) == "nil" then return tooltip[self.db.profile.showtooltip] end

	self.db.profile.showtooltip = tooltiprev[v]
end
