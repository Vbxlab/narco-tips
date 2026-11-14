-- Narco-Tips - Core
-- Event handling: addon load, zone change, login, logout

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("PLAYER_LOGOUT")

-- Delayed check frame (avoids checking zone too early after loading screens)
local delayFrame = CreateFrame("Frame")
delayFrame:Hide()
delayFrame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 2 then
        self:Hide()
        self.elapsed = 0
        NarcoTips:CheckAutoOpen()
    end
end)

local function StartDelayedCheck()
    delayFrame.elapsed = 0
    delayFrame:Show()
end

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "NarcoTips" then
        NarcoTips:InitDB()
        NarcoTips:Print("v" .. NarcoTips.version .. " loaded.")

        if NarcoTips.InitNotepad then NarcoTips:InitNotepad() end
        if NarcoTips.InitMinimap then NarcoTips:InitMinimap() end

    elseif event == "PLAYER_ENTERING_WORLD" then
        -- This fires on login AND on loading screens (boat transitions, instances, etc.)
        -- Zone info may not be updated yet, so delay the check by 2 seconds
        NarcoTips.alreadyAutoOpened = false
        NarcoTips:Debug("PLAYER_ENTERING_WORLD — flag reset, delayed check in 2s")
        StartDelayedCheck()

    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
        -- These fire when the zone is actually set, so we can check immediately
        if not NarcoTips:IsInCapital() then
            NarcoTips.alreadyAutoOpened = false
            -- Cancel any pending delayed check since we left the capital
            delayFrame:Hide()
            NarcoTips:Debug("Left capital — flag reset")
        else
            NarcoTips:CheckAutoOpen()
        end

    elseif event == "PLAYER_LOGOUT" then
        NarcoTips:Save()
    end
end)

NarcoTips.events = f

-- Auto-open notepad when entering a capital (only once per visit)
function NarcoTips:CheckAutoOpen()
    if not self.db or not self.db.autoOpenInCapital then return end
    if self.alreadyAutoOpened then return end

    local inCap, isFriendly = self:GetCapitalInfo()
    if not inCap then return end

    -- Only auto-open in friendly capitals, not enemy capitals
    if not isFriendly then
        self:Debug("In enemy capital — skipping auto-open")
        return
    end

    self.alreadyAutoOpened = true
    local unchecked = self:CountUnchecked()

    self:Debug("Auto-opening in friendly capital — discreet")

    if self.notepad and self.notepad.Open then
        self.notepad:Open(true, false)
    end

    -- Welcome message in chat
    local zone = GetZoneText()
    if unchecked > 0 then
        self:Print("|cFFFFFFAA" .. unchecked .. "|r tâche(s) en attente à " .. zone .. ".")
    else
        self:Print("Rien d'urgent noté à " .. zone .. ". 😊")
    end
end
