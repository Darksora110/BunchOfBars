

----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBarsCore")

L:RegisterTranslations("enUS", function() return {
	["Visual Options"] = true,
	["Options to control the looks of BunchOfBars."] = true,

	["Module Options"] = true,
	["Options for all modules."] = true,

	["Module Padding"] = true,
	["Padding between module parts."] = true,

	["Position"] = true,
	["The position of this module's frame on the unit frame."] = true,

	["Disabled"] = true,
	["Enable/Disable the module. Requires an interface reload to take effect."] = true,

	["Enabling/Disabling a module requires an interface reload to take effect (/rl)"] = true,

	["|cffffff00Click|r to lock/unlock unit frames."] = true,

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
}end)

L:RegisterTranslations("koKR", function() return {
	["Visual Options"] = "설정",
	["Options to control the looks of BunchOfBars."] = "프레임 설정",

	["Module Options"] = "모듈 설정",

	["Module Padding"] = "간격",
	["Padding between module parts."] = "각 모듈간 간격을 설정합니다.",

	["Position"] = "위치",
	["The position of this module's frame on the unit frame."] = "각 모듈의 위치를 설정합니다.",

	["|cffffff00Click|r to lock/unlock unit frames."] = "|cffffff00클릭|r하면 프레임을 고정/비고정 합니다."
}end)



----------------------------------
--      Local Declaration      --
----------------------------------



----------------------------------
--      Module Declaration      --
----------------------------------

BunchOfBars = AceLibrary("AceAddon-2.0"):new(
	"AceEvent-2.0",
	"AceModuleCore-2.0",
	"AceConsole-2.0",
	"AceDB-2.0",

	"FuBarPlugin-2.0"
)

local BunchOfBars = BunchOfBars


BunchOfBars:SetModuleMixins("AceEvent-2.0")

BunchOfBars.revision = tonumber(("$Revision: 106 $"):match("%d+"))

BunchOfBars.options = {
	type = "group",
	handler = BunchOfBars,
	args = {
		visual = {
			type     = "group",
			name     = L["Visual Options"],
			desc     = L["Options to control the looks of BunchOfBars."],
			disabled = function() return InCombatLockdown() end,
			args     = { }
		},
		module = {
			type = "group",
			name = L["Module Options"],
			desc = L["Options for all modules."],
			args = {
				padding = {
					type  = "range",
					name  = L["Module Padding"],
					desc  = L["Padding between module parts."],
					min   = 0,
					max   = 15,
					step  = 1,
					get   = "GetSetPadding", -- defined in Layout.lua
					set   = "GetSetPadding",
					order = 1
				},

				header2 = { type = "header", name = " ", order = 2 }
			}
		}
	}
}

BunchOfBars.defaults = { }




-- FuBar settings
BunchOfBars:Inject({
	hasIcon                = "Interface\\Icons\\Ability_Druid_TreeofLife",
	hasNoColor             = true,
	defaultMinimapPosition = 60,
	cannotDetachTooltip	   = true,
	hideWithoutStandby     = true,
	blizzardTooltip        = true,
	hasNoText              = true,
	independentProfile	   = true,
	OnMenuRequest          = BunchOfBars.options
})



----------------------------------
--      Module Functions        --
----------------------------------

function BunchOfBars:OnInitialize()
	self:RegisterDB("BunchOfBars2DB")
	self:RegisterDefaults("profile", self.defaults)

	self:RegisterChatCommand({"/bob", "/bunchofbars"}, self.options)
end


function BunchOfBars:OnEnable()
	self:HideShowParty()

	ClickCastFrames = ClickCastFrames or {}
	
	self:RegisterModules()
	self:UpdateLayoutOrder()

	self:CreateMaster()

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ShowMaster")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ForceUpdate")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ForceUpdate")

	self:RegisterEvent("BunchOfBarsShowMaster", "ShowMaster")


	for _,module in BunchOfBars:IterateModules() do
		if module.revision > self.revision then
			self.revision = module.revision
		end
	end

	self.version = "r"..self.revision
end


function BunchOfBars:OnClick()
	BunchOfBars.db.profile.visual.locked = not BunchOfBars.db.profile.visual.locked

	self:UpdateTooltip()
end


function BunchOfBars:OnTooltipUpdate()
	GameTooltip:AddLine("BunchOfBars ")
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(LOCKED..":", (BunchOfBars.db.profile.visual.locked and YES or NO), 1, 1, 0, 1, 1, 1) -- LOCKED, YES and NO are defined and translated somewhere in blizzard code
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["|cffffff00Click|r to lock/unlock unit frames."], 0.2, 1, 0.2)
end


function BunchOfBars:RegisterModules()
	for name,module in self:IterateModules() do
		if not module.db then
			self:RegisterDefaults(name, "profile", module.defaultDB)
			module.db = self:AcquireDBNamespace(name)
		end

		self.options.args.module.args[name] = {
			type    = "group",
			handler = module,
			name    = module.options and module.options.name or name,
			desc    = string.format("Options for %s.", module.options and module.options.name or name),
			args    = module.options and module.options.args or {}
		}

		if module.db.profile.position then
			self.options.args.module.args[name].args.position = { -- Nice.
				type = "range",
				name = L["Position"],
				desc = L["The position of this module's frame on the unit frame."],
				min  = 1,
				max  = 10,
				step = 1,
				get  = function() return module.db.profile.position end,
				set  = function(v)
					if module.db.profile.position ~= v then
						module.db.profile.position = v
						BunchOfBars:UpdateLayoutOrder()
						BunchOfBars:UpdateLayouts()
					end
				end
			}
		end

		self.options.args.module.args[name].args.disabled = {
			type = "toggle",
			name = L["Disabled"],
			desc = L["Enable/Disable the module. Requires an interface reload to take effect."],
			get  = function() return module.db.profile.disabled end,
			set  = function(v)
				if module.db.profile.disabled ~= v then
					module.db.profile.disabled = v
					self:Print(L["Enabling/Disabling a module requires an interface reload to take effect (/rl)"])
				end
			end
		}

		if module.db.profile.disabled then
			self:ToggleModuleActive(module, false)
		else
			self:ToggleModuleActive(module, true)
		end
	end
end
