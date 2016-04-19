local BunchOfBars = BunchOfBars;

if (not BunchOfBars:HasModule("HealthBar")) then return end
if (BunchOfBars:HasModule("VisualHeal")) then return end

local BunchOfBars_VisualHeal = BunchOfBars:NewModule("VisualHeal")

BunchOfBars_VisualHeal.revision = tonumber(("$Revision: 81 $"):match("%d+"))

local UnitName = UnitName;
local UnitExists = UnitExists;
local UnitHealthMax = UnitHealthMax;
local GetTime = GetTime;
local UnitIsUnit = UnitIsUnit;
local pairs = pairs;

----------------------------------
--      Module Functions        --
----------------------------------

function BunchOfBars_VisualHeal:OnInitialize()
    self.PlayerName = UnitName('player');
    self.HealComm = LibStub:GetLibrary("LibHealComm-3.0");
end

function BunchOfBars_VisualHeal:OnEnable()
    self.HealComm.RegisterCallback(self, "HealComm_DirectHealStart");
    self.HealComm.RegisterCallback(self, "HealComm_DirectHealUpdate");
    self.HealComm.RegisterCallback(self, "HealComm_DirectHealStop");
    self.HealComm.RegisterCallback(self, "HealComm_HealModifierUpdate");

	self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
end

function BunchOfBars_VisualHeal:HealComm_DirectHealStart(event, healerName, healSize, endTime, ...)
    if ((healerName == self.PlayerName) and UnitExists(...)) then
        self.IsCasting = true;
        self.HealingTargetName = ...; 
        self.HealingSize = healSize;
        self.EndTime = endTime;
    end

    if (select('#', ...) > 1) then
        self:UpdateAll();
    else
        for _,frame in pairs(self.core.frames) do
            if (UnitExists(frame.unit) and UnitIsUnit(frame.unit, ...)) then
                self:OnUpdate(frame, frame.parts[self.name])
            end
        end
    end
end

function BunchOfBars_VisualHeal:HealComm_DirectHealUpdate(event, healerName, healSize, endTime, ...)
    if (healerName == self.PlayerName) then
        self.EndTime = endTime;
    end

    if (select('#', ...) > 1) then
        self:UpdateAll();
    else
        for _,frame in pairs(self.core.frames) do
            if (UnitExists(frame.unit) and UnitIsUnit(frame.unit, ...)) then
                self:OnUpdate(frame, frame.parts[self.name])
            end
        end
    end
end

function BunchOfBars_VisualHeal:HealComm_DirectHealStop(event, healerName, healSize, succeeded, ...)
    if (healerName == self.PlayerName) then
        self.IsCasting = false;
    end

    if (select('#', ...) > 1) then
        self:UpdateAll();
    else
        for _,frame in pairs(self.core.frames) do
            if (UnitExists(frame.unit) and UnitIsUnit(frame.unit, ...)) then
                self:OnUpdate(frame, frame.parts[self.name])
            end
        end
    end
end

function BunchOfBars_VisualHeal:HealComm_HealModifierUpdate(event, unit, targetName, healModifier)
    for _,frame in pairs(self.core.frames) do
        if (UnitExists(frame.unit) and UnitIsUnit(unit, frame.unit)) then
            self:OnUpdate(frame, frame.parts[self.name])
        end
    end
end

function BunchOfBars_VisualHeal:OnCreate(frame)
    local part = {};
    local healthBar = frame.parts["HealthBar"];
    local playerHealBar = CreateFrame("StatusBar", nil, frame);
    local incomingHealBar = CreateFrame("StatusBar", nil, frame);
    part.playerHealBar = playerHealBar;
    part.incomingHealBar = incomingHealBar;

    local playerHealBarSpark = CreateFrame("Frame", nil, playerHealBar);
    local incomingHealBarSpark = CreateFrame("Frame", nil, incomingHealBar);
    playerHealBarSpark.texture = playerHealBarSpark:CreateTexture(nil, "OVERLAY");
    incomingHealBarSpark.texture = incomingHealBarSpark:CreateTexture(nil, "OVERLAY");
    part.playerHealBarSpark = playerHealBarSpark;
    part.incomingHealBarSpark = incomingHealBarSpark;

    local frameLevel = healthBar:GetFrameLevel();
    frame.parts["HealthBar"]:SetFrameLevel(frameLevel)
    playerHealBar:SetFrameLevel(frameLevel + 1);
    incomingHealBar:SetFrameLevel(frameLevel + 1);

    playerHealBar:SetMinMaxValues(0.0, 1.0);
    incomingHealBar:SetMinMaxValues(0.0, 1.0);
    playerHealBar:SetValue(0.0);
    incomingHealBar:SetValue(0.0);

    local texture = healthBar:GetStatusBarTexture():GetTexture();
    playerHealBar:SetStatusBarTexture(texture);
    incomingHealBar:SetStatusBarTexture(texture);

    incomingHealBar:SetWidth(100)
    incomingHealBar:SetHeight(18)
    playerHealBar:SetWidth(100)
    playerHealBar:SetHeight(18)

    playerHealBarSpark.texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");
    incomingHealBarSpark.texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");
    playerHealBarSpark.texture:SetBlendMode('ADD');
    incomingHealBarSpark.texture:SetBlendMode('ADD');
    playerHealBarSpark.texture:SetPoint('CENTER', playerHealBarSpark, 'CENTER');
    incomingHealBarSpark.texture:SetPoint('CENTER', incomingHealBarSpark, 'CENTER');
    playerHealBarSpark:SetWidth(16);
    incomingHealBarSpark:SetWidth(16);
    playerHealBarSpark.texture:SetWidth(16);
    incomingHealBarSpark.texture:SetWidth(16);
    playerHealBarSpark:SetHeight(2 * 18);
    playerHealBarSpark.texture:SetHeight(2 * 18);
    incomingHealBarSpark:SetHeight(2 * 18);
    incomingHealBarSpark.texture:SetHeight(2 * 18);
    playerHealBarSpark:SetPoint('CENTER', playerHealBar, 'LEFT', 0, 0);
    incomingHealBarSpark:SetPoint('CENTER', incomingHealBar, 'LEFT', 0, 0);

    return part;
end

function BunchOfBars_VisualHeal:OnUpdate(frame, part)
    local healthBar = frame.parts["HealthBar"];
    local playerHealBar = part.playerHealBar;
    local incomingHealBar = part.incomingHealBar;
    local unit = frame.unit;
    local incomingHeal;
    local isCastingOnThisUnit;

    if (not playerHealBar) then return end

    if (self.IsCasting and UnitIsUnit(unit, self.HealingTargetName)) then
        isCastingOnThisUnit = true;
    end

    if (isCastingOnThisUnit) then
        incomingHeal = self.HealComm:UnitIncomingHealGet(unit, self.EndTime);
    else
        incomingHeal = select(2, self.HealComm:UnitIncomingHealGet(unit, GetTime()));
    end    

    playerHealBar:Hide();
    incomingHealBar:Hide();

    -- Bail out early if nothing going on for this unit
    if (not isCastingOnThisUnit and not incomingHeal) then
        playerHealBar:SetValue(0.0);
        incomingHealBar:SetValue(0.0);
        return;
    end
    local healModifier = self.HealComm:UnitHealModifierGet(unit);

    local unitHealth = UnitHealth(unit);
    local unitHealthMax = UnitHealthMax(unit);

    local cPerc = unitHealth / unitHealthMax;
    local iPerc = healModifier * (incomingHeal or 0.0) / unitHealthMax;
    local pPerc = healModifier * (isCastingOnThisUnit and self.HealingSize or 0.0) / unitHealthMax;

    -- Determine waste (in percent)
    local waste;
    if (pPerc > 0.0) then
        if (cPerc + iPerc > 1.0) then
            waste = 1.0;
        else
            waste = cPerc + iPerc + pPerc - 1.0;
            if (waste > 0.0) then
                waste = waste / pPerc;
            else
                waste = 0.0;
            end
        end
    else
        waste = 0.0;
    end

    -- Calculate colour for overheal severity
    local red = waste > 0.1 and 1 or waste * 10;
    local green = waste < 0.1 and 1 or -2.5 * waste + 1.25;

    -- Update bars
    playerHealBar:SetValue(pPerc);
    incomingHealBar:SetValue(iPerc);

    -- Set colours
    playerHealBar:SetStatusBarColor(red, green, 0.0, 0.60);
    incomingHealBar:SetStatusBarColor(0.4, 0.6, 0.4, 0.40);

    playerHealBar:ClearAllPoints();
    incomingHealBar:ClearAllPoints();    

    local n = healthBar:GetWidth() * cPerc;
    incomingHealBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", n, 0);
    n = n + incomingHealBar:GetWidth() * iPerc;
    playerHealBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", n, 0);

    if (isCastingOnThisUnit) then
        playerHealBar:Show();
    end
    if (incomingHeal and incomingHeal > 0) then
        incomingHealBar:Show();
    end
end
