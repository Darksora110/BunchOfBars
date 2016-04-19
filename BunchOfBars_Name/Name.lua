

local moduleName = "UnitName"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Unit Name",

	["'Status colored Name'"] = true,
	["'(AFK/Offline)' 'Classcolored Name'"] = true,
	["'Classcolored Name'"] = true,

	["Text Format"] = true,

	["Predefined Formats"] = true,
	["Choose from a set of prefedined formats."] = true,

	["Text Justification"] = true,
	["Set the horizontal text justification."] = true,

	["Width"] = true,
	["Width of the text area."] = true
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "유닛 이름",

	["'Status colored Name'"] = "'색상화된 이름'",
	["'(AFK/Offline)' 'Classcolored Name'"] = "'자리비움/오프라인' '클래스별 이름'",
	["'Classcolored Name'"] = "'색상화된 이름'",

	["Text Format"] = "글자 설정",

	["Predefined Formats"] = "정의된 설정",
	["Choose from a set of prefedined formats."] = "미리 정의된 설정을 사용합니다.",

	["Text Justification"] = "글자 정의",
	["Set the horizontal text justification."] = "표시하고 싶은 글자를 정의합니다."
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local DogTag = LibStub("LibDogTag-3.0")


local formats = {
	["[~RaidGroup?IsLeader?Format(\"*\")][[Offline:AFK]?Name:Gray!Name:ClassColor]"]		 = L["'Status colored Name'"],
	["[~RaidGroup?IsLeader?Format(\"*\")][[Offline:AFK]:Truncate(1):Red] [Name:ClassColor]"] = L["'(AFK/Offline)' 'Classcolored Name'"],
	["[Name:ClassColor]"]																	 = L["'Classcolored Name'"]
}

local formatsdesc = { }
do
	for k in pairs(formats) do
		formatsdesc[k] = k
	end
end



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 105 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		format = {
			type  = "text",
			name  = L["Text Format"],
			desc  = L["Text Format"],
			usage = "DogTag-1.0 tags. See http://www.wowace.com/wiki/DogTag-1.0/Tags",
			get   = "GetSetFormat",
			set   = "GetSetFormat"
		},
		preformats = {
			type  = "text",
			name  = L["Predefined Formats"],
			desc  = L["Choose from a set of prefedined formats."],
			usage = "",
			validate     = formats,
			validateDesc = formatsdesc,
			get = "GetSetFormat",
			set = "GetSetFormat"
		},
		justification = {
			type     = "text",
			name     = L["Text Justification"],
			desc     = L["Set the horizontal text justification."],
			usage    = "",
			validate = { "LEFT", "CENTER", "RIGHT" },
			get      = "GetSetJustification",
			set      = "GetSetJustification"
		},
		width = {
			type = "range",
			name = L["Width"],
			desc = L["Width of the text area."],
			min = 40,
            max = 100,
            step = 5,
            get = "GetSetWidth",
            set = "GetSetWidth",
		}
	}
}

plugin.defaultDB = {
	position = 1,
	disabled = true,

	format        = "[~RaidGroup?IsLeader?Format(\"*\")][[Offline:AFK]?Name:Gray!Name:ClassColor]",
	justification = "RIGHT",
	width         = 50
}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	-- stupix fix for removing the "Dead" of just resurrected people, only works if they recieve a buff that boosts their hp
	-- why is there no event for this? Maybe PARTY_MEMBER_ENABLE?
	--self:RegisterBucketEvent("UNIT_MAXHEALTH", 2, "UpdateUnits")
end


function plugin:OnCreate(frame)
	local font = frame:CreateFontString(nil, "OVERLAY")
	font:SetFontObject(GameFontHighlight)
	font:SetWidth(self.db.profile.width)
	font:SetHeight(14)
	font:SetVertexColor(1, 1, 1, 1)
	font:SetJustifyH(self.db.profile.justification)

	return font
end


function plugin:OnUpdate(frame, font)
	DogTag:AddFontString(font, frame, self.db.profile.format, "Unit", { unit = frame.unit })
end


function plugin:OnInactive(frame, font)
	DogTag:RemoveFontString(font)
end



----------------------------------
--      Option Handlers         --
----------------------------------

function plugin:GetSetFormat(v)
	if type(v) == "nil" then return self.db.profile.format end

	-- this check is to assure we don't update to often
	if self.db.profile.format ~= v then
		self.db.profile.format = v --DogTag:CleanCode(v)

		self:UpdateAll()
	end
end


function plugin:GetSetJustification(v)
	if type(v) == "nil" then return self.db.profile.justification end

	if self.db.profile.justification ~= v then
		self.db.profile.justification = v

		self:UpdateAllWith(function(frame, font)
			font:SetJustifyH(self.db.profile.justification)
		end)
	end
end


function plugin:GetSetWidth(v)
	if type(v) == "nil" then return self.db.profile.width end

	if self.db.profile.width ~= v then
		self.db.profile.width = v

		self:UpdateAllWith(function(frame, font)
			font:SetWidth(self.db.profile.width)
		end)

		self.core:UpdateLayouts()
	end
end
