# UI layout

Screens and the layout widget kit live here so you can find things by role.

## Where to look

| Folder | What it is |
| --- | --- |
| `screens/combat/` | HUD combat : `TrackerScreenLayout` (géométrie), `TrackerScreenButtons` (boutons), `TrackerScreen` (dessin / input) |
| `screens/log/` | Randomizer log overlay : `LogOverlayLayout`, `LogSearchLayout` (panneau recherche), `LogOverlay`, tabs |
| `screens/setup/` | Settings, startup, navigation menu, language, quickload |
| `screens/notebook/` | Notes, seen Pokémon, stats history |
| `screens/tools/` | Calculators, heals, time machine, game over, crash recovery |
| `screens/stream/` | Streamer / Stream Connect |
| `screens/extensions/` | Custom extension screens |
| `screens/overlay/` | Extra overlays (e.g. team view) |
| `widgets/` | Layout kit (`Layout`, `Frame`, `Box`, `Component`) — NDS-inspired, draws with Besteon `Theme` |

Combat HUD is split for navigation:
- `screens/combat/TrackerScreenLayout.lua` — panel geometry + button hitbox sync
- `screens/combat/TrackerScreenButtons.lua` — button definitions
- `screens/combat/TrackerScreen.lua` — draw / input / carousel logic

Lua **global names** stay the same (`TrackerScreen`, …). Loading is wired in `FileManager.lua`.
