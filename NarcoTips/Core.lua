-- Narco-Tips - Core
-- Event handling: addon load, zone change, login, logout

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("PLAYER_LOGOUT")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "NarcoTips" then
        NarcoTips:InitDB()
        NarcoTips:Print("v" .. NarcoTips.version .. " loaded.")

        if NarcoTips.InitNotepad then NarcoTips:InitNotepad() end
        if NarcoTips.InitMinimap then NarcoTips:InitMinimap() end

    elseif event == "PLAYER_ENTERING_WORLD" then
        NarcoTips.alreadyAutoOpened = false
        NarcoTips:Debug("PLAYER_ENTERING_WORLD — flag reset")
        NarcoTips:CheckAutoOpen()

    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
        if not NarcoTips:IsInCapital() then
            NarcoTips.alreadyAutoOpened = false
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

    self.alreadyAutoOpened = true
    local enemy = not isFriendly
    local unchecked = self:CountUnchecked()

    if enemy then
        self:Debug("Auto-opening in ENEMY capital — extra discreet")
    else
        self:Debug("Auto-opening in friendly capital — discreet")
    end

    if self.notepad and self.notepad.Open then
        self.notepad:Open(true, enemy)
    end

    -- Welcome message in chat
    local zone = GetZoneText()
    if unchecked > 0 then
        self:Print("|cFFFFFFAA" .. unchecked .. "|r tâche(s) en attente à " .. zone .. ".")
    else
        self:Print("Rien d'urgent noté à " .. zone .. ". 😊")
    end
end
