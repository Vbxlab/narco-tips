-- Narco-Tips - Initialization
-- Namespace, saved variables, defaults, localization

NarcoTips = NarcoTips or {}
NarcoTips.version = "1.4.1"

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
    -- language: nil = auto-detect, or "enUS"/"frFR"/"deDE"/"itIT"/"esES"
    language = nil,
}

-- In-memory state
NarcoTips.alreadyAutoOpened = false
NarcoTips.notepad = nil
NarcoTips.minimap = nil
NarcoTips.db = nil

-- Capital cities mapped to their faction
-- All supported client languages (EN/FR/DE/IT/ES)
NarcoTips.capitals = {
    -- English
    ["Stormwind City"]  = "Alliance",
    ["Ironforge"]       = "Alliance",
    ["Darnassus"]       = "Alliance",
    ["Orgrimmar"]       = "Horde",
    ["Thunder Bluff"]   = "Horde",
    ["Undercity"]       = "Horde",
    -- French
    ["Hurlevent"]               = "Alliance",
    ["Forgefer"]                = "Alliance",
    ["Les Pitons du Tonnerre"]  = "Horde",
    ["Fossoyeuse"]              = "Horde",
    -- German
    ["Sturmwind"]       = "Alliance",
    ["Eisenschmiede"]   = "Alliance",
    ["Donnerfels"]      = "Horde",
    ["Unterstadt"]      = "Horde",
    -- Italian
    ["Roccavento"]      = "Alliance",
    ["Forgiardente"]    = "Alliance",
    ["Picco del Tuono"] = "Horde",
    ["Sepulcra"]        = "Horde",
    -- Spanish
    ["Ventormenta"]     = "Alliance",
    ["Forjaz"]          = "Alliance",
    ["Cima del Trueno"] = "Horde",
    ["Entrañas"]        = "Horde",
}

-- Presets configuration (keys reference locale strings)
NarcoTips.presetKeys = {"buy", "sell", "craft", "bank", "misc"}

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

-- === Localization ===

-- Get current locale string
function NarcoTips:T(key)
    local lang = self:GetCurrentLanguage()
    local L = self.L
    if L[lang] and L[lang][key] then
        return L[lang][key]
    end
    -- Fallback to English
    if L.enUS and L.enUS[key] then
        return L.enUS[key]
    end
    return key
end

-- Determine current language: manual override or auto-detect
function NarcoTips:GetCurrentLanguage()
    if self.db and self.db.language then
        return self.db.language
    end
    -- Auto-detect from client
    local locale = GetLocale()
    if self.L[locale] then
        return locale
    end
    return "enUS"
end

-- Set manual language override
function NarcoTips:SetLanguage(lang)
    self.db.language = lang
    self:Save()
end

-- Get list of available languages
function NarcoTips:GetAvailableLanguages()
    return self.localeKeys or {"enUS"}
end

-- Get display name for a language code
function NarcoTips:GetLanguageDisplay(lang)
    local key = "lang_" .. lang
    local text = self:T(key)
    return text
end

-- Save current state to SavedVariables
function NarcoTips:Save()
    if not self.db then return end
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
    print("|cFF9966FF[" .. self:T("title") .. "]|r " .. tostring(msg))
end

function NarcoTips:Debug(msg)
    -- print("|cFFFF6600[NT-DBG]|r " .. tostring(msg))
end

-- Capital detection
function NarcoTips:GetCapitalInfo()
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

function NarcoTips:CountUnchecked()
    if not self.db or not self.db.notes then return 0 end
    local n = 0
    for _, item in ipairs(self.db.notes) do
        if not item.checked then n = n + 1 end
    end
    return n
end

function NarcoTips:GetTimestamp()
    return date("%Y-%m-%d %H:%M")
end
