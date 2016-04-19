

----------------------------
--      Localization      --
----------------------------



----------------------------------
--      Local Declaration      --
----------------------------------

local pairs = pairs
local UnitExists = UnitExists



----------------------------------
--      Module Declaration      --
----------------------------------

BunchOfBars.modulePrototype.core = BunchOfBars

BunchOfBars.modulePrototype.defaultDB = {}



----------------------------------
--      Module Functions        --
----------------------------------

function BunchOfBars.modulePrototype:OnCreate(frame)
	return nil -- do nothing
end

function BunchOfBars.modulePrototype:OnUpdate(frame, mypart)
	-- do nothing
end

function BunchOfBars.modulePrototype:OnInactive(frame, mypart)
	-- do nothing
end


function BunchOfBars.modulePrototype:UpdateAll()
	if not self.core.frames then return end

	for _,frame in pairs(self.core.frames) do
		if UnitExists(frame.unit) then
			self:OnUpdate(frame, frame.parts[self.name])
		end
	end
end


function BunchOfBars.modulePrototype:UpdateAllWith(func)
	if type(func) == "function" then
		for _,frame in pairs(self.core.frames) do
			if UnitExists(frame.unit) then
				func(frame, frame.parts[self.name])
			end
		end
	else -- let's just assume it's a string as it should be
		for _,frame in pairs(self.core.frames) do
			if UnitExists(frame.unit) then
				self[func](self, frame, frame.parts[self.name])
			end
		end
	end
end


function BunchOfBars.modulePrototype:UpdateUnits(units)
	if not self.core.frames then return end

	for unit in pairs(units) do
        if self.core.frames[unit] and UnitExists(unit) then
			self:OnUpdate(self.core.frames[unit], self.core.frames[unit].parts[self.name])
		end
    end
end


function BunchOfBars.modulePrototype:UpdateUnit(unit)
	if not self.core.frames then return end

	-- maybe use for ... and UnitIsUnit
	if self.core.frames[unit] and UnitExists(unit) then
		self:OnUpdate(self.core.frames[unit], self.core.frames[unit].parts[self.name])
	end
end



function BunchOfBars.modulePrototype:UpdateAllPets()
	if not self.core.frames then return end

	for _,frame in pairs(self.core.frames) do
		--local pet = string.gsub(frame.unit, "(%a+)(%d*)", "%1pet%2")

		if UnitExists(frame.unit) and UnitExists(frame.unit.."pet") then
			self:OnUpdatePet(frame, frame.parts[self.name])
		end
	end
end


function BunchOfBars.modulePrototype:UpdatePets(pets)
	if not self.core.frames then return end

	for pet in pairs(pets) do
		self:UpdatePet(pet)
    end
end


function BunchOfBars.modulePrototype:UpdatePet(pet)
	if not self.core.frames then return end

	if pet == "pet" then
		pet = "playerpet"
	end

	local i = string.find(pet, "pet")

	if i then
		local unit = string.gsub(pet, "pet", "")

		-- maybe use for ... and UnitIsUnit
		if self.core.frames[unit] and UnitExists(unit) then
			self:OnUpdatePet(self.core.frames[unit], self.core.frames[unit].parts[self.name])
		end
	end
end



function BunchOfBars.modulePrototype:UpdateBoth(unit)
	self:UpdateUnit(unit)
	self:UpdatePet(unit)
end
