

local moduleName = "Agro"



----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BunchOfBars"..moduleName)

L:RegisterTranslations("enUS", function() return {
	[moduleName] = "Agro Monitor",

	["Check frequency"] = true,
	["Frequency in seconds."] = true,

	["Sound Warning"] = true,
	["Play a sound when you get agro in these area's."] = true,

	["Disable"] = true,
	["Everywhere"] = true,
	["Party,Raid,Outdoors"] = true,
	["Party,Raid,Outdoors,Arena"] = true
} end)

L:RegisterTranslations("koKR", function() return {
	[moduleName] = "어그로 알림이",

	["Check frequency"] = "빈도 체크",
	["Frequency in seconds."] = "초당 빈도수",

	["Sound Warning"] = "소리 경고",
} end)



----------------------------------
--      Local Declaration      --
----------------------------------

local lookup = { } -- table for name to unit id lookups
local myunit
local playsound = false

local where = {
	L["Disable"],
	L["Everywhere"],
	L["Party,Raid,Outdoors"],
	L["Party,Raid,Outdoors,Arena"]
}

local whererev = { } -- reverse lookup of the where table
do
	for k,v in ipairs(where) do
		whererev[v] = k
	end
end

local sound = "Sound\\Creature\\Murloc\\mMurlocAggroOld.wav"
-- "Sound\\Spells\\PVPFlagTakenHorde.wav"


-- localize these functions to speed up the main loop a bit
local UnitExists = UnitExists
local UnitIsEnemy = UnitIsEnemy
local UnitIsUnit = UnitIsUnit



----------------------------------
--      Module Declaration      --
----------------------------------

local plugin = BunchOfBars:NewModule(moduleName)

plugin.revision = tonumber(("$Revision: 100 $"):match("%d+"))

plugin.options = {
	name = L[moduleName],
	args = {
		frequency = {
			type = "range",
			name = L["Check frequency"],
			desc = L["Frequency in seconds."],
			min = 0.1,
            max = 2.0,
            step = 0.05,
            get = "GetSetFrequency",
            set = "GetSetFrequency",
		},
		sound = {
			type     = "text",
			name     = L["Sound Warning"],
			desc     = L["Play a sound when you get agro in these area's."],
			usage    = "",
			validate = where,
            get      = "GetSetSound",
            set      = "GetSetSound"
		},
	}
}

plugin.defaultDB = {
	frequency = 0.25,
	sound     = 4 -- Party,Raid,Outdoors,Arena
}


plugin.agro = {} -- can't be local since other modules need access
--plugin.agrounit = {}



----------------------------------
--      Module Functions        --
----------------------------------

function plugin:OnEnable()
	self:ScheduleRepeatingEvent("BunchOfBars_AgroUpdate", self.Update, self.db.profile.frequency, self)

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end


function plugin:OnUpdate(frame)
	lookup[UnitName(frame.unit)] = frame.unit

	if UnitIsUnit(frame.unit, "player") then
		myunit = frame.unit
	end
end


function plugin:Update()
	local tanking = self.agro[myunit]
	local threat, exists

	for unit in pairs(self.core.frames) do
		self.agro[unit] = 0
		--self.agrounit[unit] = { }
	end

	for unit in pairs(self.core.frames) do
		--[[if UnitExists(unit.."target") and UnitCanAttack(unit.."target", "player") and UnitExists(unit.."targettarget") then

			-- did I just get agro?
			if playsound and (GetCVar("Sound_EnableSFX") == 1) and not self.agro[myunit] and UnitIsUnit(unit.."targettarget", "player") then
				PlaySoundFile(sound)
			end

			local tunit = lookup[UnitName(unit.."targettarget")]
			if tunit then -- check if the person is in out party/raid
				self.agro[tunit] = self.db.profile.frequency + 1.5
				self.agrounit[tunit] = unit.."target"
			end
		end]]--

		if UnitExists(unit.."target") and UnitCanAttack(unit.."target", "player") then
			exists = UnitExists(unit.."targettarget")

			if playsound and tanking and (tanking < 2) and exists and (GetCVar("Sound_EnableSFX") == 1) and UnitIsUnit(unit.."targettarget", "player") then
				PlaySoundFile(sound)
			end

			if UnitPlayerControlled(unit.."target") then
				if exists then
					local tunit = lookup[UnitName(unit.."targettarget")]
					if tunit then -- check if the person is in out party/raid
						self.agro[tunit] = 3
						--self.agrounit[tunit][unit.."target"] = true

						self:TriggerEvent("BunchOfBars_Agro", tunit)
					end
				end
			else
				for tunit in pairs(self.core.frames) do
					threat = UnitThreatSituation(tunit, unit.."target")

					if threat then
						self.agro[tunit] = max(self.agro[tunit], threat)

						--[[if (threat > 1) then
							self.agrounit[tunit][unit.."target"] = true
						end]]--
					end
				end
			end
		end
	end

	for unit in pairs(self.core.frames) do
		if self.agro[unit] then
			self:TriggerEvent("BunchOfBars_Agro", unit)
		end
	end

	--[[for unit in pairs(self.agro) do
		self.agro[unit] = self.agro[unit] - self.db.profile.frequency

		if self.agro[unit] < 0 then
			self.agro[unit] = nil
		end

		self:TriggerEvent("BunchOfBars_Agro", unit)
	end]]--
end


function plugin:OnInactive(frame)
	self.agro[frame.unit] = nil
end


function plugin:ZONE_CHANGED_NEW_AREA()
	local _, it = IsInInstance()

	if (self.db.profile.sound == 2) or -- Everywhere
	   (self.db.profile.sound == 3 and it ~= "pvp" and it ~= "arena") or -- Party,Raid,Outdoors
	   (self.db.profile.sound == 4 and it ~= "pvp") then -- Party,Raid,Outdoors,Arena
		playsound = true
	else
		playsound = false
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


function plugin:GetSetSound(v)
	if type(v) == "nil" then return where[self.db.profile.sound] end

	self.db.profile.sound = whererev[v]

	self:ZONE_CHANGED_NEW_AREA()

	if self.db.profile.sound > 1 then
		PlaySoundFile(sound)
	end
end
