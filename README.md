# IronMON Tracker — Generation 1

A BizHawk Lua tracker for IronMON on original Game Boy Pokémon games. It is based on the [Besteon Ironmon Tracker](https://github.com/besteon/Ironmon-Tracker) architecture, with native Red/Blue/Yellow memory layouts and mechanics instead of GBA ones.

## Supported games

| Game | Regions | Notes |
| --- | --- | --- |
| Pokémon Red | US/EU | Also recognizes historical randomized Red Kaizo headers |
| Pokémon Blue | US/EU | |
| Pokémon Yellow | US/EU | Also recognizes historical randomized Yellow Kaizo headers |
| Pokémon Yellow | France | Runtime-confirmed WRAM; not a uniform offset from Yellow US |

ROMs must be `.gb` or `.gbc`. Pair a Universal Pokémon Randomizer ZX log (`.gbc.log` / `.gb.log`) when you want route, trainer, and TM information from the seed.

## Emulator

- **BizHawk** 2.8 or newer, with a Game Boy core (Gambatte or GBHawk)
- mGBA is **not** supported

Open `Ironmon-Tracker.lua` from BizHawk: **Tools → Lua Console → Script → Open Script**.

## Code layout (where to look)

| Folder | Role |
| --- | --- |
| `ironmon_tracker/memory/` | Game profiles, WRAM/ROM reads |
| `ironmon_tracker/data/` | Species, moves, routes, trainers, log parser |
| `ironmon_tracker/core/` | Program loop, battle, tracker notes |
| `ironmon_tracker/ui/screens/` | Screens by role (`combat/`, `log/`, `setup/`, …) — see `ui/README.md` |
| `ironmon_tracker/ui/widgets/` | Layout kit (`Layout`, `Frame`, `Box`, `Component`) |
| `ironmon_tracker/drawing/` | Drawing helpers and themes |

## What this tracker reads

- Party and enemy 44-byte RBY structures (big-endian HP/stats/experience)
- DVs, HP DV derivation, Stat Experience, one Special stat
- Native type chart, including the Ghost/Psychic bug
- Exact RBY capture odds (Master/Ultra/Great/Poké/Safari)
- Wild vs trainer battles, stat stages, move tracking, Battle Details
- Bag items including TM01–TM50 and HM01–HM05
- Defeated trainers (session + save file, with gym leaders inferred from badges)
- Encounter tables split by walking, surfing, Old Rod, Good Rod, and Super Rod
- UPR ZX RBY logs (English and French names)

## Randomizer

Use [Universal Pokémon Randomizer ZX](https://github.com/Ajarmar/universal-pokemon-randomizer-zx) with a Red, Blue, or Yellow ROM. Keep the generated `.log` next to the ROM for log overlay / open-book features.

## Attribution

Retains architecture and UI from Besteon's Ironmon Tracker. Native Generation 1 memory and battle behavior draw on pret's [pokered](https://github.com/pret/pokered) / [pokeyellow](https://github.com/pret/pokeyellow) research and patterns from the [NDS Ironmon Tracker](https://github.com/Brian0255/NDS-Ironmon-Tracker).

## Remaining validation

Interactive BizHawk checks for Red US/EU, Blue US/EU, and Yellow US/EU still need lawful test ROMs. Yellow FR has ROM/log integration coverage; a full in-emulator pass is the completion gate.
