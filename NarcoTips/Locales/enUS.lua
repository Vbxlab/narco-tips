-- Narco-Tips - English locale (fallback/default)
-- This file must always load first

NarcoTips = NarcoTips or {}

local L = {}
NarcoTips.L = L
NarcoTips.localeKeys = {"enUS", "frFR", "deDE", "itIT", "esES"}

-- Default strings (English)
L.enUS = {
    -- Presets
    buy         = "Buy",
    sell        = "Sell",
    craft       = "Craft",
    bank        = "Bank",
    misc        = "Misc",
    buyPrefix   = "Buy: ",
    sellPrefix  = "Sell: ",
    craftPrefix = "Craft: ",
    bankPrefix  = "Bank: ",
    miscPrefix  = "",

    -- UI
    title           = "Narco-Tips",
    placeholder     = "Type a task then press Enter…",
    checkAll        = "Check All",
    uncheckAll      = "Uncheck All",
    clearChecked    = "Clear Checked",
    saved           = "Saved ✓",
    tasksRemaining  = "to do",

    -- Chat messages
    loaded          = "loaded.",
    tasksPending    = "task(s) pending in",
    nothingUrgent   = "Nothing urgent noted in",

    -- Minimap tooltip
    tooltipTasks    = "task(s) to do",
    tooltipNoTasks  = "No pending tasks ✓",
    tooltipClick    = "Click: open/close",
    tooltipDrag     = "Drag: move icon",

    -- Language names (displayed in selector)
    lang_enUS = "EN",
    lang_frFR = "FR",
    lang_deDE = "DE",
    lang_itIT = "IT",
    lang_esES = "ES",
}
