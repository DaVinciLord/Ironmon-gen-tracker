# UI layout

Screens and the layout widget kit live here so you can find things by role.

## Where to look

| Folder | What it is |
| --- | --- |
| `screens/combat/` | In-battle HUD and related (`TrackerScreen`, info, trainers on route, …) |
| `screens/log/` | Randomizer log overlay and its tabs |
| `screens/setup/` | Settings, startup, navigation menu, language, quickload |
| `screens/notebook/` | Notes, seen Pokémon, stats history |
| `screens/tools/` | Calculators, heals, time machine, game over, crash recovery |
| `screens/stream/` | Streamer / Stream Connect |
| `screens/extensions/` | Custom extension screens |
| `screens/overlay/` | Extra overlays (e.g. team view) |
| `widgets/` | Layout kit (`Layout`, `Frame`, `Box`, `Component`) — NDS-inspired, draws with Besteon `Theme` |

Combat HUD geometry lives in `screens/combat/TrackerScreenLayout.lua` (the boxes you see beside the game). `TrackerScreen.lua` still owns buttons, input, and text; it asks the layout for positions instead of scattering magic numbers.
