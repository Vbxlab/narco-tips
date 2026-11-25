# Narco-Tips — WoW Forever Addon

A discreet checklist addon for World of Warcraft: Forever that helps you keep track of tasks to do in capital cities.

Originally created for a friend who, due to illness and treatment side effects, kept forgetting what he had planned to craft, buy, or sell once he reached a capital. Narco-Tips solves this by automatically opening a personal checklist the moment you enter a friendly capital — no need to remember to check anything, it's just there.

## Features

### Auto-open in capitals
- Automatically opens when you arrive in a friendly capital city
- Opens discreetly without stealing focus — your movement keys keep working
- One trigger per visit (resets when you leave the capital)
- No auto-open in enemy capitals
- Delayed check after loading screens (boat transitions) to avoid false triggers
- Chat message on arrival: "X task(s) pending" or "Nothing urgent 😊"

### Clickable checklist
- Each task has a checkbox, a timestamp, and a delete button
- Check things off as you complete them
- Dynamic row height for long notes (text wraps, no truncation)
- No character limit on task text

### Quick-add presets
- Five preset buttons: Buy, Sell, Craft, Bank, Misc
- Color-coded categories (green, orange, blue, purple, grey)
- Auto-sized buttons that adapt to translated text length

### Auto-save
- Every change is saved instantly with visual confirmation ("Saved ✓")
- Notes persist across logouts and reloads via SavedVariables
- Saved on window close and on logout

### Adjustable font size
- Increase or decrease text size (10–22px) with + and − buttons

### Resizable & draggable
- Position and size the window however you like
- State saved between sessions (size, position, alpha)

### Minimap button
- Click to toggle the checklist
- Draggable around the minimap
- Badge showing the number of pending tasks
- Tooltip with task count and instructions

### Multilingual (EN / FR / DE / IT / ES)
- Auto-detects client language via `GetLocale()`
- Manual language selector in the title bar (cycle: EN → FR → DE → IT → ES)
- Language choice saved in SavedVariables

## Installation

1. Download the latest release zip
2. Extract the `NarcoTips/` folder into your `Interface/AddOns/` directory
3. Launch the game
4. Enable in Esc → AddOns

## Structure

```
NarcoTips/
├── NarcoTips.toc       # Metadata (Interface: 16001)
├── Init.lua             # Namespace, saved vars, localization, capital detection
├── Core.lua             # Events: addon load, zone change, auto-open logic
├── Notepad.lua          # Checklist UI: rows, presets, font buttons, language selector, auto-save
├── Minimap.lua          # Minimap button + badge (LibDBIcon-1.0 layout)
└── Locales/
    ├── enUS.lua         # English (default fallback)
    ├── frFR.lua         # French
    ├── deDE.lua         # German
    ├── itIT.lua         # Italian
    └── esES.lua         # Spanish
```

## Capitales détectées

| Faction | Capitales |
|---------|-----------|
| Alliance | Stormwind City / Hurlevent, Ironforge / Forgefer, Darnassus |
| Horde | Orgrimmar, Thunder Bluff / Les Pitons du Tonnerre, Undercity / Fossoyeuse |

## Dev

```bash
# Syntax check (LuaJIT)
for f in NarcoTips/*.lua NarcoTips/Locales/*.lua; do luajit -bl "$f" /dev/null 2>&1 && echo "OK: $f" || echo "FAIL: $f"; done
```

## Links

- **GitHub:** https://github.com/Vbxlab/narco-tips
- **CurseForge:** (pending approval)
- **WoW Forever version:** 1.60.1 (Interface: 16001)

## Changelog

### v1.4.1
- Localization: EN / FR / DE / IT / ES
- Auto-detect client language + manual selector
- Auto-sized preset buttons for long translations

### v1.3.0
- New minimap icon (INV_Misc_Note_01)

### v1.2.0
- Auto-open no longer steals focus (movement keys not captured)

### v1.1.0
- Minimap button: LibDBIcon-1.0 standard layout
- No auto-open in enemy capitals
- Delayed check after loading screens (boat transitions)
- Dynamic row height for long notes
- Unlimited text length

### v1.0.0
- Initial release: checklist, presets, timestamps, auto-save, font sizing, minimap button
