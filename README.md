# Narco-Tips — WoW Forever Addon

Checklist interactive avec ouverture automatique en capitale, pensée pour aider à se souvenir des choses à faire.

## Fonctionnalités

### Checklist cliquable
- Chaque tâche a une case à cocher, un horodatage, et un texte
- Clic sur la case = cocher/décocher → sauvegarde immédiate
- Bouton de suppression individuel par tâche

### Notes datées
- Horodatage automatique (format `YYYY-MM-DD HH:MM`) à chaque création de tâche
- Visible dans la liste à côté de chaque item

### Boutons rapides pré-formatés
5 presets en haut de la fenêtre :
- **Acheter** (vert) — pré-remplit "Acheter : "
- **Vendre** (orange) — pré-remplit "Vendre : "
- **Craft** (bleu) — pré-remplit "Craft : "
- **Banque** (violet) — pré-remplit "Banque : "
- **Divers** (gris) — pas de préfixe

### Effacement facile
- **Tout cocher** — coche toutes les tâches
- **Tout décocher** — décoche toutes les tâches
- **Effacer cochés** — supprime toutes les tâches cochées

### Auto-save sur changement
- Sauvegarde à chaque action : ajout, coche, décoche, suppression, changement taille/font
- Indicateur visuel "Sauvegardé ✓" après chaque action
- Sauvegarde aussi au logout

### Réglage de la fonte
- Slider de 10 à 22px dans la barre du haut
- S'applique à l'input et à toutes les lignes de la liste

### Auto-open en capitale
- S'ouvre automatiquement à l'arrivée ou la connexion dans une capitale
- **Capitale amie** : mode discreet (max 420×340), focus sur l'input
- **Capitale ennemie** : mode extra discreet (max 280×220, alpha 0.6, pas de focus volé)
- Une seule fois par visite (flag reset en quittant la capitale)
- Message dans le chat à l'entrée : "X tâche(s) en attente" ou "Rien d'urgent 😊"

### Icône minimap
- Clic = ouvrir/fermer la checklist
- Drag = déplacer autour de la minimap
- **Badge rouge** avec le nombre de tâches non cochées
- Tooltip avec compteur et instructions

## Structure

```
NarcoTips/
├── NarcoTips.toc    # Metadata (Interface: 16001)
├── Init.lua          # Namespace, saved vars, presets, capital detection
├── Core.lua          # Events: ADDON_LOADED, zone change, auto-open logic
├── Notepad.lua       # Checklist UI: rows, presets, font slider, auto-save
└── Minimap.lua       # Minimap button + badge
```

## Installation

1. Copier `NarcoTips/` dans `<WoW Forever>/Interface/AddOns/`
2. Relancer le jeu
3. Activer dans Échap → AddOns

## Format des données

```lua
NarcoTipsDB = {
    notes = {
        {text = "potions de soin", checked = false, time = "2026-11-11 23:14", preset = "buy"},
        {text = "soie en excès", checked = true,  time = "2026-11-11 22:30", preset = "sell"},
        ...
    },
    fontSize = 14,
    windowWidth = 360,
    windowHeight = 320,
    ...
}
```

## Dev

```bash
for f in NarcoTips/*.lua; do luajit -bl "$f" /dev/null 2>&1 && echo "OK: $f" || echo "FAIL: $f"; done
```

## Capitales détectées

| Faction | Capitales |
|---------|-----------|
| Alliance | Stormwind City, Ironforge, Darnassus |
| Horde | Orgrimmar, Thunder Bluff, Undercity |

## Notes

- `## Interface: 16001` = WoW Forever 1.60.1
- Les SavedVariables sont écrites sur disque au logout ; l'auto-save sur changement garde la table à jour en mémoire en permanence
- Non testé en jeu — à valider sur le client WoW Forever
