-- Narco-Tips - Minimap Button
-- Click to toggle notepad, draggable around minimap, badge with unchecked count

function NarcoTips:InitMinimap()
    local db = self.db

    local button = CreateFrame("Button", "NarcoTipsMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)

    -- Icon texture (vanilla-safe path)
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)

    -- Highlight on hover
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetAllPoints(icon)

    -- Border ring — aligned with vanilla minimap button standard
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", -6, 5)

    -- Badge (count overlay)
    local badge = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    badge:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)
    badge:SetText("")

    -- Position on minimap
    local function UpdatePosition(angle)
        local x = math.cos(angle) * 78
        local y = math.sin(angle) * 78
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end
    UpdatePosition(db.minimapAngle or 4.71)

    -- Drag to rotate
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            local angle = math.atan2(py - my, px - mx)
            UpdatePosition(angle)
            db.minimapAngle = angle
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil)
        NarcoTips:Save()
    end)

    -- Click to toggle notepad
    button:SetScript("OnClick", function()
        if NarcoTips.notepad and NarcoTips.notepad.Toggle then
            NarcoTips.notepad:Toggle()
        end
    end)

    -- Tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("|cFF9966FFNarco-Tips|r")
        local unchecked = NarcoTips:CountUnchecked()
        if unchecked > 0 then
            GameTooltip:AddLine("|cFFFFAA00" .. unchecked .. "|r tâche(s) à faire", 1, 1, 1)
        else
            GameTooltip:AddLine("Aucune tâche en attente |cFF4CAF50✓|r", 0.7, 0.7, 0.7)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Clic: ouvrir/fermer", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Glisser: déplacer l'icône", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    NarcoTips.minimap = button
    NarcoTips.badge = badge

    -- Initial badge update
    self:UpdateMinimapBadge()
end

-- Update the badge on the minimap button
function NarcoTips:UpdateMinimapBadge()
    if not self.badge then return end
    local n = self:CountUnchecked()
    if n > 0 then
        self.badge:SetText("|cFFFF4444" .. n .. "|r")
    else
        self.badge:SetText("")
    end
end
