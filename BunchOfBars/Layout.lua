

----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBarsLayout")

L:RegisterTranslations("enUS", function() return {
	["Update"] = true,
	["Update everything."] = true,

	["Recreate"] = true,
	["Recreate all frames."] = true,

	["Reset Position"] = true,
	["Move BunchOfBars to the middle of the screen."] = true,
	
	["Scale"] = true,
	["The scale of the frames."] = true,

	["Show when solo"] = true,
	["Show BunchOrBars when your on your own."] = true,

	["Show in party"] = true,
	["Show BunchOrBars when your in a party."] = true,

	["Hide Blizzard Party"] = true,
	["Hide the Bilzzard party frames."] = true,

	["Group by"] = true,
	["Group players in your raid by Group or Class."] = true,

	["Sort by"] = true,
	["Sort the player in a group by Name or Index."] = true,

	["Order by"] = true,
	["How to order the groups."] = true,
	["[1-8, STRING] a comma seperated list of raid group numbers and/or class names"] = true,

	["Filter by"] = true,
	["Only show the players or groups and/or classes on this filter list."] = true,
	["[1-8, STRING] a comma seperated list of player names or raid group numbers and/or class names.\nEmpty for no filter"] = true,

	["Players per Column"] = true,
	["Number of players per column."] = true,

	["You need to reload your user interface (/rl) for this reset to take effect."] = true
} end)

L:RegisterTranslations("koKR", function() return {
	["Update"] = "업데이트",
	["Update everything."] = "모두 업데이트합니다.",

	["Reset Position"] = "위치 초기화",
	["Move BunchOfBars to the middle of the screen."] = "모든 프레임을 중앙에 오도록 초기화 합니다.",
	
	["Scale"] = "크기",
	["The scale of the frames."] = "프레임의 크기를 설정합니다.",

	["Show in party"] = "파티 보기",
	["Show BunchOrBars when your in a party."] = "파티시에도 표시합니다."
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local SharedMedia     = LibStub("LibSharedMedia-3.0")
local SharedMediaType = SharedMedia.MediaType and SharedMedia.MediaType.STATUSBAR or "statusbar"

SharedMedia:Register(SharedMediaType, "Charcoal", "Interface\\Addons\\BunchOfBars\\Textures\\Charcoal")


local moduleorder

local sorts = {
	["NAME"]  = "Name",
	["INDEX"] = "Index"
}
local groupbys = {
	["CLASS"] = "Class",
	["GROUP"] = "Group",
	["NONE"]  = "None"
}

local partyhidden = false -- blizzard party frames are shown by default



----------------------------------
--      Module Declaration      --
----------------------------------

BunchOfBars.options.args.visual.args = {
	update = {
		type  = "execute",
		name  = L["Update"],
		desc  = L["Update everything."],
		func  = "ForceUpdate",
		order = 1
	},

	recreate = {
		type  = "execute",
		name  = L["Recreate"],
		desc  = L["Recreate all frames."],
		func  = "CreateMaster",
		order = 1
	},

	header2 = { type = "header", name = " ", order = 2 },

	reset = {
		type     = "execute",
		name     = L["Reset Position"],
		desc     = L["Move BunchOfBars to the middle of the screen."],
		func     = "ResetPosition",
		order    = 3
	},
	scale = {
		type = "range",
		name = L["Scale"],
		desc = L["The scale of the frames."],
		min  = 0.5,
		max  = 2,
		step = 0.1,
		get  = "GetSetScale",
		set  = "GetSetScale",
		order    = 4
	},

	header5 = { type = "header", name = " ", order = 5 },

	solo = {
		type = "toggle",
		name = L["Show when solo"],
		desc = L["Show BunchOrBars when your on your own."],
		get  = "GetSetSolo",
		set  = "GetSetSolo",
		order = 7
	},
	party = {
		type = "toggle",
		name = L["Show in party"],
		desc = L["Show BunchOrBars when your in a party."],
		get  = "GetSetParty",
		set  = "GetSetParty",
		order = 8
	},
	hideparty = {
		type  = "toggle",
		name  = L["Hide Blizzard Party"],
		desc  = L["Hide the Bilzzard party frames."],
		get   = "GetSetHideParty",
		set   = "GetSetHideParty",
		order = 9
	},

	header8 = { type = "header", name = " ", order = 10 },

	groupby = {
		type  = "text",
		name  = L["Group by"],
		desc  = L["Group players in your raid by Group or Class."],
		usage = false,
		validate = groupbys,
		get = "GetSetGroupBy",
		set = "GetSetGroupBy",
		order = 11
	},
	sortby = {
		type  = "text",
		name  = L["Sort by"],
		desc  = L["Sort the player in a group by Name or Index."],
		usage = false,
		validate = sorts,
		get = "GetSetSort",
		set = "GetSetSort",
		order = 12
	},
	orderstr = {
		type  = "text",
		name  = L["Order by"],
		desc  = L["How to order the groups."],
		usage = L["[1-8, STRING] a comma seperated list of raid group numbers and/or class names"],
		get   = "GetSetOrderStr",
		set   = "GetSetOrderStr",
		order = 13
	},
	filterstr = {
		type  = "text",
		name  = L["Filter by"],
		desc  = L["Only show the players or groups and/or classes on this filter list."],
		usage = L["[1-8, STRING] a comma seperated list of player names or raid group numbers and/or class names.\nEmpty for no filter"],
		get   = "GetSetFilterStr",
		set   = "GetSetFilterStr",
		order = 14
	},

	header13 = { type = "header", name = " ", order = 15 },

	players = {
		type  = "range",
		name  = L["Players per Column"],
		desc  = L["Number of players per column."],
		min   = 5,
		max   = 40,
		step  = 1,
		get   = "GetSetPlayers",
		set   = "GetSetPlayers",
		order = 16
	}
}


BunchOfBars.defaults.visual = {
	locked = false,
	x      = 400,
	y      = 400,

	padding = 4,

	scale = 1.0,

	solo	  = true,
	party     = true,
	hideparty = true,

	groupby   = "CLASS",
	sortby    = "NAME",
	orderstr  = "WARRIOR,DRUID,PALADIN,DEATHKNIGHT,PRIEST,SHAMAN,ROGUE,MAGE,WARLOCK,HUNTER",
	filterstr = "1,2,3,4,5",

	players = 25
}



----------------------------------
--      Module Functions        --
----------------------------------

function BunchOfBars:OnProfileEnable() -- will be called when our profile is reset
	self:Print(L["You need to reload your user interface (/rl) for this reset to take effect."])
	self:UpdateAll()
end


function BunchOfBars:CreateMaster()
	if self.master then
		self:DestroyMaster()
	end

	self.frames = {}

	local frame = CreateFrame("Frame", "BunchOfBarsFrame", UIParent, "SecureGroupHeaderTemplate")
	self.master = frame -- self.frame is used by FuBarPlugin

	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	
	frame:SetHeight(1)
	frame:SetWidth(1)

	self:PositionAndScale()

	frame:SetAttribute("showRaid", true)
	frame:SetAttribute("showParty", self.db.profile.visual.party)
	frame:SetAttribute("showPlayer", true)
	frame:SetAttribute("showSolo", self.db.profile.visual.solo)

	frame:SetAttribute("yOffset", -1) -- space between frames

	self.master:SetAttribute("groupBy", (self.db.profile.visual.groupby == "NONE") and nil or self.db.profile.visual.groupby)
	frame:SetAttribute("sortMethod", self.db.profile.visual.sortby)
	frame:SetAttribute("groupingOrder", self.db.profile.visual.orderstr)
	frame:SetAttribute("groupFilter", self.db.profile.visual.filterstr)

	frame:SetAttribute("columnSpacing", 2)
	frame:SetAttribute("columnAnchorPoint", "LEFT")
	self.master:SetAttribute("maxColumns", ceil(40 / self.db.profile.visual.players))
	self.master:SetAttribute("unitsPerColumn", self.db.profile.visual.players)

	frame.initialConfigFunction = self.ConfigureFrame
	frame:SetAttribute("template", "SecureUnitButtonTemplate")
	
	self:ScheduleEvent("BunchOfBarsShowMaster", 0)
	--self:AddTimer(5, "BunchOfBarsShowMaster") -- LibRockTimer
end


function BunchOfBars:ShowMaster()
	if not InCombatLockdown() then
		if not self.master:IsShown() then
			self.master:Show()
		else
			self:ForceUpdate()
		end
	end
end


function BunchOfBars:DestroyMaster()
	self.master:Hide()
	self.master = nil
end


function BunchOfBars:PositionAndScale()
	self.master:SetScale(self.db.profile.visual.scale)

	local s = self.master:GetEffectiveScale()
	local x, y = self.db.profile.visual.x / s, self.db.profile.visual.y / s

	self.master:ClearAllPoints()
	self.master:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end


function BunchOfBars.OnAttributeChanged(frame, name, value)
	if name ~= "unit" then return end -- we are only interrested in the unit attribute

	if frame.unit and not value then
		BunchOfBars:ModuleOnInactive(frame)		
		frame.unit = nil
	elseif value then
		frame.unit = value
	end
end


function BunchOfBars.OnDragStart()
	if not BunchOfBars.db.profile.visual.locked and not InCombatLockdown() then
		BunchOfBars.master:StartMoving()
	end
end

function BunchOfBars.OnDragStop()
	BunchOfBars.master:StopMovingOrSizing()

	local x,y = BunchOfBars.master:GetLeft(), BunchOfBars.master:GetTop()
	local s   = BunchOfBars.master:GetEffectiveScale()

	BunchOfBars.db.profile.visual.x = x*s
	BunchOfBars.db.profile.visual.y = y*s
end

function BunchOfBars.OnShow()
	if not this.visible then
		this.visible = true

		BunchOfBars.frames[this.unit] = this

		BunchOfBars:ModuleOnUpdate(this)
		BunchOfBars.master:StopMovingOrSizing() -- seems to fix a bug where you can't stop dragging
	end
end

function BunchOfBars.OnHide()
	if this.visible then
		this.visible = nil

		BunchOfBars.frames[this.unit] = nil
	end
end


function BunchOfBars.ConfigureFrame(frame)
	frame:SetAttribute("type1", "target")
	frame:SetAttribute("*type1", "target")

	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")

	frame:SetScript("OnDragStart"		, BunchOfBars.OnDragStart)
	frame:SetScript("OnDragStop"		, BunchOfBars.OnDragStop)
	frame:SetScript("OnShow"			, BunchOfBars.OnShow)
	frame:SetScript("OnHide"			, BunchOfBars.OnHide)
	frame:SetScript("OnAttributeChanged", BunchOfBars.OnAttributeChanged)

	frame:SetAlpha(1.0)

	BunchOfBars:ModuleOnCreate(frame)
	BunchOfBars:UpdateLayout(frame) -- apperantly we are able to change the size of the frame here, even in combat

	ClickCastFrames[frame] = true
end


function BunchOfBars:ForceUpdate()
	if not InCombatLockdown() and self.master then
		-- this will trigger the blizzard code to update all units and reshow the frames
		self.master:SetAttribute("unitsPerColumn", self.db.profile.visual.players)
	end
end


function BunchOfBars:ModuleOnCreate(frame)
	frame.parts = {}

	for name,module in self:IterateModules() do
		frame.parts[name] = module:OnCreate(frame)
	end
end

function BunchOfBars:ModuleOnUpdate(frame)
	if not UnitExists(frame.unit) then return end

	for name,module in self:IterateModules() do
		if self:IsModuleActive(module) then
			module:OnUpdate(frame, frame.parts[name])
		end
	end
end

function BunchOfBars:ModuleOnInactive(frame)
	for name,module in self:IterateModules() do
		if self:IsModuleActive(module) then
			module:OnInactive(frame, frame.parts[name])
		end
	end
end


function BunchOfBars:UpdateLayoutOrder()
	moduleorder = {}

	for name,module in self:IterateModules() do
		if self:IsModuleActive(module) then
			if module.db.profile.position then
				local done = false
				for k,v in ipairs(moduleorder) do
					if module.db.profile.position < self:GetModule(v).db.profile.position then
						table.insert(moduleorder, k, name)
						done = true
						break
					end
				end

				if not done then
					table.insert(moduleorder, name)
				end
			end
		end
	end
end


function BunchOfBars:UpdateLayout(frame)
	if InCombatLockdown() then return end

	local last = nil
	local width = 0

	-- Order and show them
	for _,name in ipairs(moduleorder) do
		local p = frame.parts[name]

		p:ClearAllPoints()
		p:SetPoint("TOP", frame, "TOP", 0, (p:GetHeight() - 20) / 4)

		p:SetPoint("LEFT", frame, "LEFT", width, 0)

		width = width + frame.parts[name]:GetWidth() + self.db.profile.visual.padding

		last = p
	end

	frame:SetWidth(math.ceil(width) + 1)
	frame:SetHeight(20)
end

function BunchOfBars:UpdateLayouts()
	for _,frame in pairs(self.frames) do
		self:UpdateLayout(frame)
	end
end


function BunchOfBars:UpdateAll()
	for _,frame in pairs(self.frames) do
		self:ModuleOnUpdate(frame)
		self:UpdateLayout(frame)
	end
end


function BunchOfBars:ResetPosition()
	self.master:ClearAllPoints()
	self.master:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end


function BunchOfBars:HideShowParty()
	if self.db.profile.visual.hideparty and not partyhidden then
		partyhidden = true

		for i = 1, 4 do
			local frame = _G["PartyMemberFrame"..i]
			frame:UnregisterAllEvents()
			frame:Hide()
			frame.Show = function() end
		end
		
		UIParent:UnregisterEvent("RAID_ROSTER_UPDATE")
	elseif partyhidden then
		partyhidden = false

		for i = 1, 4 do
			local frame = _G["PartyMemberFrame"..i]
			frame.Show = nil
			frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
			frame:RegisterEvent("PARTY_LEADER_CHANGED")
			frame:RegisterEvent("PARTY_MEMBER_ENABLE")
			frame:RegisterEvent("PARTY_MEMBER_DISABLE")
			frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
			frame:RegisterEvent("UNIT_PVP_UPDATE")
			frame:RegisterEvent("UNIT_AURA")
			frame:RegisterEvent("UNIT_PET")
			frame:RegisterEvent("VARIABLES_LOADED")
			frame:RegisterEvent("UNIT_NAME_UPDATE")
			frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
			frame:RegisterEvent("UNIT_DISPLAYPOWER")

			UnitFrame_OnEvent("PARTY_MEMBERS_CHANGED")
			
			_G.this = frame
			_G.self = frame
			PartyMemberFrame_UpdateMember()
		end
		
		UIParent:RegisterEvent("RAID_ROSTER_UPDATE")
	end
end



----------------------------------
--      Option Handlers         --
----------------------------------

function BunchOfBars:GetSetPadding(value)
	if type(value) == "nil" then return self.db.profile.visual.padding end

	-- this check is to assure we don't update to often
	if self.db.profile.visual.padding ~= value then
		self.db.profile.visual.padding = value
		
		self:UpdateLayouts()
	end
end


function BunchOfBars:GetSetScale(value)
	if type(value) == "nil" then return self.db.profile.visual.scale end

	-- this check is to assure we don't update to often
	if self.db.profile.visual.scale ~= value then
		self.db.profile.visual.scale = value
		
		self:PositionAndScale()
	end
end


function BunchOfBars:GetSetParty(v)
	if type(v) == "nil" then return self.db.profile.visual.party end

	if self.db.profile.visual.party ~= v then
		self.db.profile.visual.party = v
		
		self.master:SetAttribute("showParty", self.db.profile.visual.party)
	end
end


function BunchOfBars:GetSetSolo(v)
	if type(v) == "nil" then return self.db.profile.visual.solo end

	if self.db.profile.visual.solo ~= v then
		self.db.profile.visual.solo = v
		
		self.master:SetAttribute("showSolo", self.db.profile.visual.solo)
	end
end


function BunchOfBars:GetSetHideParty(v)	
	if type(v) == "nil" then return self.db.profile.visual.hideparty end

	if self.db.profile.visual.hideparty ~= v then
		self.db.profile.visual.hideparty = v

		self:HideShowParty()
	end
end


function BunchOfBars:GetSetGroupBy(v)
	if type(v) == "nil" then return self.db.profile.visual.groupby end

	if self.db.profile.visual.groupby ~= v then
		self.db.profile.visual.groupby = v

		if self.db.profile.visual.groupby == "CLASS" then
			self.db.profile.visual.orderstr = "WARRIOR,DRUID,PALADIN,DEATHKNIGHT,PRIEST,SHAMAN,ROGUE,MAGE,WARLOCK,HUNTER"
		elseif self.db.profile.visual.groupby == "GROUP" then
			self.db.profile.visual.orderstr = "1,2,3,4,5,6,7,8"
		end

		self.master:SetAttribute("groupBy", (self.db.profile.visual.groupby == "NONE") and nil or self.db.profile.visual.groupby)
		self.master:SetAttribute("groupingOrder", self.db.profile.visual.orderstr)
	end
end


function BunchOfBars:GetSetSort(v)	
	if type(v) == "nil" then return self.db.profile.visual.sortby end

	if self.db.profile.visual.sortby ~= v then
		self.db.profile.visual.sortby = v

		self.master:SetAttribute("sortMethod", self.db.profile.visual.sortby)
	end
end


function BunchOfBars:GetSetOrderStr(v)
	if type(v) == "nil" then return self.db.profile.visual.orderstr end

	if self.db.profile.visual.orderstr ~= v then
		self.db.profile.visual.orderstr = string.upper(v)

		self.master:SetAttribute("groupBy", (self.db.profile.visual.groupby == "NONE") and nil or self.db.profile.visual.groupby)
		self.master:SetAttribute("groupingOrder", self.db.profile.visual.orderstr)
	end
end


function BunchOfBars:GetSetFilterStr(v)
	if type(v) == "nil" then return self.db.profile.visual.filterstr or "" end

	if self.db.profile.visual.filterstr ~= v then
		self.db.profile.visual.filterstr = v

		if self.db.profile.visual.filterstr == "" then
			self.db.profile.visual.filterstr = nil
			self.master:SetAttribute("groupFilter", nil)
			self.master:SetAttribute("nameList"   , nil)
		else
			local s = string.upper(self.db.profile.visual.filterstr)
			local hasclass, hasgroup = false, false

			if string.find(s, "%d") then
				hasgroup = true
			end

			if string.find(s, "WARRIOR") or
			   string.find(s, "DRUID") or
			   string.find(s, "PALADIN") or
			   string.find(s, "DEATHKNIGHT") or
			   string.find(s, "PRIEST") or
			   string.find(s, "SHAMAN") or
			   string.find(s, "ROGUE") or
			   string.find(s, "MAGE") or
			   string.find(s, "WARLOCK") or
			   string.find(s, "HUNTER") then
			   hasclass = true
			end

			if hasgroup or hasclass then
				self.db.profile.visual.filterstr = s
				self.master:SetAttribute("groupFilter", self.db.profile.visual.filterstr)
				self.master:SetAttribute("strictFiltering", (hasgroup and hasclass) and true or false)
				self.master:SetAttribute("nameList"   , nil)
			else
				self.master:SetAttribute("groupFilter"    , nil)
				self.master:SetAttribute("strictFiltering", false)
				self.master:SetAttribute("nameList"       , self.db.profile.visual.filterstr)
			end
		end
	end
end


function BunchOfBars:GetSetPlayers(v)
	if type(v) == "nil" then return self.db.profile.visual.players end

	if self.db.profile.visual.players ~= v then
		self.db.profile.visual.players = v

		self.master:SetAttribute("maxColumns", ceil(40 / self.db.profile.visual.players))
		self.master:SetAttribute("unitsPerColumn", self.db.profile.visual.players)
	end
end
