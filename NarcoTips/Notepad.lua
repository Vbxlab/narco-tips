-- Narco-Tips - Notepad
-- Interactive checklist with presets, timestamps, font sizing, auto-save

function NarcoTips:InitNotepad()
    local db = self.db
    local fontSize = db.fontSize or 14

    -- === Main window ===
    local frame = CreateFrame("Frame", "NarcoTipsNotepad", UIParent)
    frame:SetSize(db.windowWidth or 360, db.windowHeight or 320)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetResizable(true)
    frame:SetAlpha(db.windowAlpha or 0.88)
    frame:Hide()

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.08, 0.10, 1.0)

    local borderTex = frame:CreateTexture(nil, "BORDER")
    borderTex:SetPoint("TOPLEFT", 1, -1)
    borderTex:SetPoint("BOTTOMRIGHT", -1, 1)
    borderTex:SetColorTexture(0.3, 0.2, 0.5, 0.7)

    -- === Title bar ===
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetHeight(24)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    titleBar:EnableMouse(true)

    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetAllPoints()
    titleBg:SetColorTexture(0.15, 0.10, 0.25, 1.0)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 8, 0)
    titleText:SetText("|cFF9966FFNarco-Tips|r")

    -- Item count badge in title
    local countText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    countText:SetPoint("RIGHT", titleBar, "RIGHT", -30, 0)

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)

    -- === Preset buttons bar ===
    local presetBar = CreateFrame("Frame", nil, frame)
    presetBar:SetHeight(22)
    presetBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -28)
    presetBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -28)

    local presetBtns = {}
    local px = 0
    for _, preset in ipairs(self.presets) do
        local btn = CreateFrame("Button", nil, presetBar, "UIPanelButtonTemplate")
        btn:SetSize(52, 20)
        btn:SetPoint("LEFT", presetBar, "LEFT", px, 0)
        btn:SetText(preset.label)
        btn:SetScript("OnClick", function()
            NarcoTips:AddItemFromPreset(preset)
        end)
        presetBtns[preset.key] = btn
        px = px + 56
    end

    -- Font size slider (compact)
    local fontLabel = presetBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fontLabel:SetPoint("RIGHT", presetBar, "RIGHT", -2, 0)
    fontLabel:SetText("Aa")

    local fontSlider = CreateFrame("Slider", nil, presetBar, "OptionsSliderTemplate")
    fontSlider:SetPoint("RIGHT", fontLabel, "LEFT", -4, 0)
    fontSlider:SetSize(80, 16)
    fontSlider:SetMinMaxValues(10, 22)
    fontSlider:SetValueStep(1)
    fontSlider:SetValue(fontSize)
    fontSlider:SetScript("OnValueChanged", function(self, value)
        NarcoTips.db.fontSize = math.floor(value)
        NarcoTips:UpdateFontSize()
        NarcoTips:Save()
    end)

    -- === Input field (add new item) ===
    local input = CreateFrame("EditBox", "NarcoTipsInput", frame)
    input:SetHeight(24)
    input:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -54)
    input:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -54)
    input:SetFontObject("ChatFontNormal")
    input:SetAutoFocus(false)
    input:SetMaxLetters(120)
    input:EnableMouse(true)

    -- Background for input
    local inputBg = input:CreateTexture(nil, "BACKGROUND")
    inputBg:SetAllPoints()
    inputBg:SetColorTexture(0.12, 0.12, 0.16, 1.0)

    local inputBorder = input:CreateTexture(nil, "BORDER")
    inputBorder:SetPoint("TOPLEFT", -1, 1)
    inputBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    inputBorder:SetColorTexture(0.25, 0.20, 0.40, 0.5)

    input:SetTextInsets(6, 6, 2, 2)
    input:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        if text and text ~= "" then
            NarcoTips:AddItem(text)
            self:SetText("")
            self:ClearFocus()
        end
    end)
    input:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)

    -- Placeholder text
    local placeholder = input:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    placeholder:SetPoint("LEFT", input, "LEFT", 8, 0)
    placeholder:SetText("Tape une tâche puis Entrée…")
    input:SetScript("OnEditFocusGained", function() placeholder:Hide() end)
    input:SetScript("OnEditFocusLost", function()
        if input:GetText() == "" then placeholder:Show() end
    end)

    -- === Scroll list ===
    local scroll = CreateFrame("ScrollFrame", "NarcoTipsScroll", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -84)
    scroll:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -28, -84)
    scroll:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 36)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 36)

    local content = CreateFrame("Frame", "NarcoTipsContent", scroll)
    content:SetSize(scroll:GetWidth(), 1)
    scroll:SetScrollChild(content)

    -- === Bottom action bar ===
    local bottomBar = CreateFrame("Frame", nil, frame)
    bottomBar:SetHeight(28)
    bottomBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 4, 4)
    bottomBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)

    local btnCheckAll = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    btnCheckAll:SetSize(90, 22)
    btnCheckAll:SetPoint("LEFT", bottomBar, "LEFT", 0, 0)
    btnCheckAll:SetText("Tout cocher")

    local btnUncheckAll = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    btnUncheckAll:SetSize(100, 22)
    btnUncheckAll:SetPoint("LEFT", btnCheckAll, "RIGHT", 4, 0)
    btnUncheckAll:SetText("Tout décocher")

    local btnClearChecked = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    btnClearChecked:SetSize(110, 22)
    btnClearChecked:SetPoint("LEFT", btnUncheckAll, "RIGHT", 4, 0)
    btnClearChecked:SetText("Effacer cochés")

    -- Save indicator
    local saveIndicator = bottomBar:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    saveIndicator:SetPoint("RIGHT", bottomBar, "RIGHT", 0, 0)
    saveIndicator:SetText("")

    -- === Resize handle ===
    local resize = CreateFrame("Button", nil, frame)
    resize:SetSize(16, 16)
    resize:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

    resize:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
    resize:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        db.windowWidth = frame:GetWidth()
        db.windowHeight = frame:GetHeight()
        NarcoTips:Save()
        NarcoTips:RefreshList()
    end)

    -- === Dragging via title bar ===
    titleBar:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then frame:StartMoving() end
    end)
    titleBar:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)

    -- ESC to close
    tinsert(UISpecialFrames, "NarcoTipsNotepad")

    -- === Row management ===
    local rows = {}
    local ROW_HEIGHT = 28

    local function CreateRow(idx)
        local row = CreateFrame("Frame", nil, content)
        row:SetHeight(ROW_HEIGHT)

        -- Checkbox
        local check = CreateFrame("CheckButton", nil, row, "ChatConfigCheckButtonTemplate")
        check:SetPoint("LEFT", row, "LEFT", 4, 0)
        check:SetSize(20, 20)

        -- Timestamp
        local time = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        time:SetPoint("LEFT", check, "RIGHT", 4, 0)
        time:SetWidth(90)
        time:SetJustifyH("LEFT")

        -- Text
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", time, "RIGHT", 4, 0)
        text:SetPoint("RIGHT", row, "RIGHT", -24, 0)
        text:SetJustifyH("LEFT")
        text:SetWordWrap(true)

        -- Delete button
        local del = CreateFrame("Button", nil, row)
        del:SetSize(18, 18)
        del:SetPoint("RIGHT", row, "RIGHT", -2, 0)
        del:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
        del:SetHighlightTexture("Interface\\Buttons\\UI-MinusButton-Highlight")
        del:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")

        row.check = check
        row.time = time
        row.text = text
        row.del = del
        return row
    end

    -- === Flash save indicator ===
    local function FlashSaved()
        saveIndicator:SetText("|cFF4CAF50Sauvegardé ✓|r")
        C_Timer.After(1.5, function()
            saveIndicator:SetText("")
        end)
    end

    -- === Refresh the list display ===
    function NarcoTips:RefreshList()
        local notes = db.notes or {}
        local n = #notes

        -- Update content height
        content:SetHeight(math.max(n * ROW_HEIGHT, 1))

        -- Update count badge
        local unchecked = self:CountUnchecked()
        if unchecked > 0 then
            countText:SetText("|cFFFFAA00" .. unchecked .. "|r à faire")
        else
            countText:SetText("|cFF4CAF50✓|r")
        end

        -- Create or update rows
        for i = 1, n do
            if not rows[i] then
                rows[i] = CreateRow(i)
            end
            local row = rows[i]
            row:ClearAllPoints()
            if i == 1 then
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
                row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
            else
                row:SetPoint("TOPLEFT", rows[i-1], "BOTTOMLEFT", 0, 0)
                row:SetPoint("TOPRIGHT", rows[i-1], "BOTTOMRIGHT", 0, 0)
            end

            local item = notes[i]
            row.check:SetChecked(item.checked)

            -- Timestamp
            row.time:SetText(item.time or "")

            -- Text with preset color and strikethrough if checked
            local prefix = ""
            local color = "|cFFCCCCCC"
            if item.preset then
                for _, p in ipairs(self.presets) do
                    if p.key == item.preset then
                        color = p.color
                        prefix = p.prefix
                        break
                    end
                end
            end

            local displayText = color .. prefix .. item.text .. "|r"
            if item.checked then
                displayText = "|cFF666666" .. prefix .. item.text .. "|r"
            end
            row.text:SetText(displayText)

            -- Checkbox handler
            row.check:SetScript("OnClick", function(self)
                item.checked = self:GetChecked()
                NarcoTips:Save()
                NarcoTips:RefreshList()
                FlashSaved()
            end)

            -- Delete handler
            row.del:SetScript("OnClick", function()
                table.remove(notes, i)
                NarcoTips:Save()
                NarcoTips:RefreshList()
                FlashSaved()
            end)

            row:Show()
        end

        -- Hide extra rows
        for i = n + 1, #rows do
            rows[i]:Hide()
        end

        -- Update minimap badge
        if self.UpdateMinimapBadge then self:UpdateMinimapBadge() end
    end

    -- === Add item ===
    function NarcoTips:AddItem(text, presetKey)
        local item = {
            text = text,
            checked = false,
            time = self:GetTimestamp(),
            preset = presetKey or "misc",
        }
        table.insert(db.notes, item)
        self:Save()
        self:RefreshList()
        FlashSaved()
    end

    -- Add item from preset (prompt for text via input field)
    function NarcoTips:AddItemFromPreset(preset)
        -- Focus the input and pre-fill with preset prefix
        input:SetText(preset.prefix)
        input:SetFocus()
        input:HighlightText(0, 0)
        input:SetCursorPosition(#preset.prefix)

        -- Store pending preset for when Enter is pressed
        input.pendingPreset = preset.key
    end

    -- Override input EnterPressed to handle presets
    local originalOnEnterPressed = input:GetScript("OnEnterPressed")
    input:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        if text and text ~= "" then
            local presetKey = self.pendingPreset or "misc"
            -- Strip the prefix from the text if it matches
            local preset = nil
            for _, p in ipairs(NarcoTips.presets) do
                if p.key == presetKey then preset = p end
            end
            local cleanText = text
            if preset and preset.prefix ~= "" then
                -- Check if text starts with the prefix
                local prefixLen = #preset.prefix
                if text:sub(1, prefixLen) == preset.prefix then
                    cleanText = text:sub(prefixLen + 1)
                end
            end
            if cleanText ~= "" then
                NarcoTips:AddItem(cleanText, presetKey)
            end
            self:SetText("")
            self.pendingPreset = nil
            self:ClearFocus()
        end
    end)

    -- === Font size control ===
    function NarcoTips:UpdateFontSize()
        local size = self.db.fontSize or 14
        local fontPath = "Fonts\\FRIZQT__.TTF"
        -- Update input font
        input:SetFont(fontPath, size)
        -- Update all row texts
        for _, row in ipairs(rows) do
            if row:IsShown() then
                row.text:SetFont(fontPath, size)
            end
        end
    end

    -- === Bottom bar actions ===
    btnCheckAll:SetScript("OnClick", function()
        for _, item in ipairs(db.notes) do
            item.checked = true
        end
        NarcoTips:Save()
        NarcoTips:RefreshList()
        FlashSaved()
    end)

    btnUncheckAll:SetScript("OnClick", function()
        for _, item in ipairs(db.notes) do
            item.checked = false
        end
        NarcoTips:Save()
        NarcoTips:RefreshList()
        FlashSaved()
    end)

    btnClearChecked:SetScript("OnClick", function()
        local remaining = {}
        for _, item in ipairs(db.notes) do
            if not item.checked then
                table.insert(remaining, item)
            end
        end
        db.notes = remaining
        NarcoTips:Save()
        NarcoTips:RefreshList()
        FlashSaved()
    end)

    -- === Auto-save on content scroll size change ===
    scroll:SetScript("OnSizeChanged", function()
        content:SetWidth(scroll:GetWidth())
    end)

    -- === Save and close ===
    local function SaveAndClose()
        db.windowWidth = frame:GetWidth()
        db.windowHeight = frame:GetHeight()
        NarcoTips:Save()
        NarcoTips:Debug("Saved and closed")
        frame:Hide()
    end

    closeBtn:SetScript("OnClick", SaveAndClose)

    -- Logout save
    local logoutFrame = CreateFrame("Frame")
    logoutFrame:RegisterEvent("PLAYER_LOGOUT")
    logoutFrame:SetScript("OnEvent", function()
        NarcoTips:Save()
    end)

    -- === Public methods ===
    function frame:Open(discreet, enemy)
        if discreet then
            local w = db.windowWidth or 360
            local h = db.windowHeight or 320
            if enemy then
                if w > 280 then w = 280 end
                if h > 220 then h = 220 end
                frame:SetAlpha(math.min(db.windowAlpha or 0.88, 0.6))
            else
                if w > 420 then w = 420 end
                if h > 340 then h = 340 end
                frame:SetAlpha(db.windowAlpha or 0.88)
            end
            frame:SetSize(w, h)
        else
            frame:SetAlpha(db.windowAlpha or 0.88)
            frame:SetSize(db.windowWidth or 360, db.windowHeight or 320)
        end
        frame:Show()
        NarcoTips:RefreshList()
        NarcoTips:UpdateFontSize()
        if enemy then
            input:ClearFocus()
        else
            input:SetFocus()
        end
        NarcoTips:Debug("Notepad opened" .. (enemy and " (enemy)" or (discreet and " (discreet)" or "")))
    end

    function frame:Toggle()
        if frame:IsShown() then
            SaveAndClose()
        else
            frame:Open(false)
        end
    end

    NarcoTips.notepad = frame

    -- Initial refresh
    self:RefreshList()
    self:UpdateFontSize()
end
