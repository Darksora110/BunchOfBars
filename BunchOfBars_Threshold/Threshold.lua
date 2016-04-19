

local moduleName = "Threshold"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Threshold",

	["Health"] = true,
	["Show the line at this amount of health. 0 will hide the lines."] = true,

	["0 (hidden)"] = true,
	["Set to 0, this will hide all lines."] = true,

	["8500 (Naj'entus)"] = true,
	["Set to 8500, this is the amount the Tidal Shield at High Warlord Naj'entus explodes for."] = true,

	["26000 (Freya x3)"] = true,
	["Set to 26000, this is roughly the amount you need for Freya with all three Elders up."] = true
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "기준선",

	["Health"] = "생명력",
	["Show the line at this amount of health. 0 will hide the lines."] = "생명력을 기준선까지만 보여줍니다. 0이되면 사라집니다."
} end)


----------------------------------
--      Local Declaration      --
----------------------------------



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 98 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		add = {
			type      = "text",
			name      = L["Health"],
			desc      = L["Show the line at this amount of health. 0 will hide the lines."],
			usage     = "",
			get		  = "GetSetValue",
			set		  = "GetSetValue"
		},

		set0 = {
			type      = "toggle",
			name      = L["0 (hidden)"],
			desc      = L["Set to 0, this will hide all lines."],
			get       = "GetSetValue2",
            set       = "GetSetValue2",
			passValue = 0
		},
		set8500 = {
			type      = "toggle",
			name      = L["8500 (Naj'entus)"],
			desc      = L["Set to 8500, this is the amount the Tidal Shield at High Warlord Naj'entus explodes for."],
			get       = "GetSetValue2",
            set       = "GetSetValue2",
			passValue = 8500
		},
		set26000 = {
			type      = "toggle",
			name      = L["26000 (Freya x3)"],
			desc      = L["Set to 26000, this is roughly the amount you need for Freya with all three Elders up."],
			get       = "GetSetValue2",
            set       = "GetSetValue2",
			passValue = 26000
		}
	}
}

plugin.defaultDB = {
	value = 0
}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
end


function plugin:OnCreate(frame)
	local line = frame.parts["HealthBar"]:CreateTexture(nil, "OVERLAY")
	line:SetHeight(18)
	line:SetWidth(1)
	line:SetTexture("Interface\\Addons\\BunchOfBars\\Textures\\Charcoal")
	line:SetVertexColor(1, 0, 0, 1)
	line:Hide()

	return line
end


function plugin:OnUpdate(frame, line)
	local m = UnitHealthMax(frame.unit)

	if self.db.profile.value == 0 or self.db.profile.value > m then
		line:Hide()
	else
		local v = (self.db.profile.value / m) * 100

		line:ClearAllPoints()
		line:SetPoint("BOTTOMLEFT", frame.parts["HealthBar"], "BOTTOMLEFT", v, 0)
		line:Show()
	end
end



----------------------------------
--      Option Handlers         --
----------------------------------

function plugin:GetSetValue(v)
	if type(v) == "nil" then return self.db.profile.value end

	v = tonumber(v)

	if v == nil then -- could not convert
		v = 0
	end

	if self.db.profile.value ~= v then
		self.db.profile.value = v

		self:UpdateAll()
	end
end


function plugin:GetSetValue2(vv, v)
	if type(v) == "nil" then return (self.db.profile.value == vv) end

	if self.db.profile.value ~= vv then
		self.db.profile.value = vv

		self:UpdateAll()
	end
end
