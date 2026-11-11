-- Narco-Tips - Initialization
-- Namespace, saved variables, defaults

NarcoTips = {}
NarcoTips.version = "1.0.0"

-- Default settings (account-wide, persisted via SavedVariables)
NarcoTips.defaults = {
    notes = {},            -- checklist items: {text, checked, time, preset}
    autoOpenInCapital = true,
    minimapAngle = 4.71,   -- default: left side of minimap
    -- window state
    windowWidth = 360,
    windowHeight = 320,
    windowAlpha = 0.88,
    -- font
    fontSize = 14,
}

-- In-memory state
NarcoTips.alreadyAutoOpened = false
NarcoTips.notepad = nil
NarcoTips.minimap = nil
NarcoTips.db = nil

-- Capital cities mapped to their faction
-- Both English and French names (client may be in either language)
NarcoTips.capitals = {
    -- English
    ["Stormwind City"]  = "Alliance",
    ["Ironforge"]       = "Alliance",
    ["Darnassus"]       = "Alliance",
    ["Orgrimmar"]       = "Horde",
    ["Thunder Bluff"]   = "Horde",
    ["Undercity"]       = "Horde",
    -- French
    ["Hurlevent"]       = "Alliance",
    ["Forgefer"]        = "Alliance",
    ["Les Pitons du Tonnerre"] = "Horde",
    ["Fossoyeuse"]      = "Horde",
}

-- Preset buttons configuration
NarcoTips.presets = {
    {key = "buy",    label = "Acheter",  prefix = "Acheter : ",   color = "|cFF4CAF50"},  -- green
    {key = "sell",   label = "Vendre",   prefix = "Vendre : ",    color = "|cFFFF9800"},  -- orange
    {key = "craft",  label = "Craft",    prefix = "Craft : ",     color = "|cFF2196F3"},  -- blue
    {key = "bank",   label = "Banque",   prefix = "Banque : ",    color = "|cFF9C27B0"},  -- purple
    {key = "misc",   label = "Divers",   prefix = "",             color = "|cFFCCCCCC"},  -- grey
}

-- Deep merge helper
local function mergeDefaults(saved, defaults)
    if type(saved) ~= "table" then saved = {} end
    if type(defaults) ~= "table" then return saved end
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            saved[k] = mergeDefaults(saved[k], v)
        elseif saved[k] == nil then
            saved[k] = v
        end
    end
    return saved
end

function NarcoTips:InitDB()
    NarcoTipsDB = NarcoTipsDB or {}
    self.db = mergeDefaults(NarcoTipsDB, self.defaults)
end

-- Save current state to SavedVariables
function NarcoTips:Save()
    if not self.db then return end
    -- Only save plain text (strip color codes from display)
    local cleanNotes = {}
    for i, item in ipairs(self.db.notes) do
        cleanNotes[i] = {
            text = item.text,
            checked = item.checked,
            time = item.time,
            preset = item.preset,
        }
    end
    NarcoTipsDB = self.db
    NarcoTipsDB.notes = cleanNotes
end

function NarcoTips:Print(msg)
    print("|cFF9966FF[Narco-Tips]|r " .. tostring(msg))
end

function NarcoTips:Debug(msg)
    -- print("|cFFFF6600[NT-DBG]|r " .. tostring(msg))
end

-- Get capital info
-- Returns: inCapital (bool), isFriendly (bool|nil)
function NarcoTips:GetCapitalInfo()
    -- Try multiple zone APIs to be safe
    local zone = GetRealZoneText() or ""
    local sub = GetSubZoneText() or ""
    local zoneText = GetZoneText() or ""
    local capFaction = self.capitals[zone] or self.capitals[sub] or self.capitals[zoneText]
    if not capFaction then
        return false, nil
    end
    local playerFaction = UnitFactionGroup("player")
    return true, (capFaction == playerFaction)
end

function NarcoTips:IsInCapital()
    local inCap, _ = self:GetCapitalInfo()
    return inCap
end

function NarcoTips:IsInFriendlyCapital()
    local inCap, isFriendly = self:GetCapitalInfo()
    return inCap and isFriendly
end

function NarcoTips:IsInEnemyCapital()
    local inCap, isFriendly = self:GetCapitalInfo()
    return inCap and not isFriendly
end

-- Count unchecked items
function NarcoTips:CountUnchecked()
    if not self.db or not self.db.notes then return 0 end
    local n = 0
    for _, item in ipairs(self.db.notes) do
        if not item.checked then n = n + 1 end
    end
    return n
end

-- Format timestamp for new entries
function NarcoTips:GetTimestamp()
    return date("%Y-%m-%d %H:%M")
end
