# Handoff — IronMON Tracker Generation 1

## Objective and completion bar

Build a complete Generation 1-only IronMON tracker from the Besteon tracker architecture, informed by the NDS tracker for file layout (one module = one role), not for UI. It must support Red/Blue/Yellow US/EU and French Yellow, use native RBY mechanics and memory layouts, and keep the Besteon screens.

This objective is **not complete**. Native data, battle, trainers, encounter areas, and overworld helpers have automated coverage, but no full interactive BizHawk validation has been done.

Layout decisions: `docs/superpowers/specs/2026-08-19-maintainability-layout-design.md`.

## Authoritative workspace

- Branch: current working branch (do not create `/tmp` worktrees)
- Real validated French Yellow ROM: `/run/media/vincent/7b80c546-f1fb-4c26-b197-f5c26f6e1d43/Games/Pokémon/IronMON/roms/seeds/YellowKaizo062.gbc`
- Matching real log: `/run/media/vincent/7b80c546-f1fb-4c26-b197-f5c26f6e1d43/Games/Pokémon/IronMON/roms/seeds/YellowKaizo062.gbc.log`
- UPR ZX jar: `/run/media/vincent/7b80c546-f1fb-4c26-b197-f5c26f6e1d43/Games/Pokémon/IronMON/PokeRandoZX-v4_6_1/PokeRandoZX.jar`

## Where to open a file

Each domain has one public Lua global. There is no `Gen1*` overlay and no `Runtime.lua` façade. `Main.lua` and `FileManager.lua` stay at the tracker-folder root because `Ironmon-Tracker.lua` hardcodes that bootstrap path.

| Domain | File |
| --- | --- |
| Game identity / WRAM+ROM addresses | `memory/GameProfiles.lua` (selected by `memory/GameSettings.lua`) |
| 44-byte party / battle structs | `memory/PokemonDataReader.lua` |
| BizHawk memory reads | `memory/Memory.lua` |
| Party, bag, map, badges, rods, Safari, heals | `core/Program.lua` |
| Battle state | `core/Battle.lua` |
| Tracked notes / TDAT | `core/Tracker.lua` |
| Constants / drawing / helpers | `constants/`, `drawing/`, `utils/` |
| Species tables + ROM base stats | `data/PokemonData.lua` + `data/DataAdapter.lua` (ROM reader) |
| Internal dex ids | `data/SpeciesMap.lua` |
| Moves + type chart | `data/MoveData.lua` + `data/DataAdapter.lua` |
| Routes / encounter areas | `data/RouteData.lua` |
| Trainers | `data/TrainerData.lua` |
| UPR `.log` | `data/RandomizerLog.lua` |
| Items | `data/MiscData.lua` |
| Screens | `screens/` (Besteon contracts unchanged) |

`DataAdapter` is the shared ROM/language trimmer used by `PokemonData` and `MoveData`. It is not a second species table.

## Implemented and currently passing

### Native game profiles and memory

- R/B US/EU, Yellow US/EU, and Yellow FR profiles in `memory/GameProfiles.lua`.
- Historical randomized header aliases for Red Kaizo and Yellow Kaizo.
- Native BizHawk Game Boy System Bus mappings for WRAM and ROM.
- Yellow FR addresses were checked against the real ROM; do not replace them with a blanket regional offset.
- `memory/GameSettings.lua` selects only native Gen 1 profiles. BizHawk only; mGBA was removed.

### Pokémon, moves, mechanics, items

- Native 44-byte party and active-battle readers; multi-byte fields are big-endian.
- DVs, HP DV derivation, five Stat Experience values, one Special stat.
- Exactly 151 bundled Pokémon and 165 bundled moves.
- Complete internal-species ↔ Pokédex mapping, including MissingNo gaps.
- Native base stats, types, catch rate, yield, growth, evolutions, and level-up moves from ROM.
- All six RBY experience formulas; the exp bar uses the real 24-bit experience.
- RBY type chart, including the Ghost/Psychic bug.
- Exact RBY capture probability for Master/Ultra/Great/Poké/Safari Balls and status bonuses.
- RBY item IDs, heals, status cures, PP items, stones, Balls, TM01–TM50 and HM01–HM05.
- TM/HM move IDs from each profile's native 55-byte ROM table, including Yellow FR.

### Battle and trainers

- Singles-only RBY battle core with the Besteon public API (`core/Battle.lua`).
- Trainer IDs are `classId * 0x100 + trainerNumber`. UPR global indices map through `TrainerData.GlobalLogIdToTrainerId`.
- Defeated trainers persist in `.TDAT`; gym leaders can be inferred from badges; gym/E4/rival maps plus trainers remembered where they are fought.
- Game Over / loss / final victory use native battle outcome, not GBA addresses.
- Battle restart savestate is created on battle entry.

### Logs, routes and quickload

- UPR ZX RBY base stats use one Special column.
- Walking, surfing, Old/Good/Super Rod are distinct `RouteData.EncounterArea` tables.
- Pallet Town is map `0`. Global Old/Good Rod tables live on Pallet, not synthetic `0x100`.
- `.gb` / `.gbc` quickload is implemented.
- The real French Yellow log currently parses to 124 populated encounter areas, 396 trainers and 50 TMs.

### Removed subsystems

- GachaMon, abilities, natures as active UI, mGBA, GBA battle core, Gen 2/3 table tails, Gen 3 address JSON, GBA asset packs that were not used.

## Automated verification

Run from the repository root:

```sh
set -e
for f in tools/*smoke.lua; do lua "$f"; done
for f in $(rg --files -g '*.lua'); do luac -p "$f"; done
lua tools/gen1_rom_file_integration.lua '/run/media/vincent/7b80c546-f1fb-4c26-b197-f5c26f6e1d43/Games/Pokémon/IronMON/roms/seeds/YellowKaizo062.gbc'
lua tools/gen1_log_routes_integration.lua '/run/media/vincent/7b80c546-f1fb-4c26-b197-f5c26f6e1d43/Games/Pokémon/IronMON/roms/seeds/YellowKaizo062.gbc.log'
git diff --check
git status --short
```

There are 23 smoke tests. ROM integration locates 151 stat records, 165 moves, 151 evolution/learnset pointers and 47 trainer-class pointers. This does **not** prove interactive emulator behavior.

## Required work remaining

### P0 — full BizHawk runtime validation

Main completion gate. For Red US/EU, Blue US/EU, Yellow US/EU and Yellow FR:

1. Launch `Ironmon-Tracker.lua` in a supported BizHawk version with the Game Boy core.
2. Startup, ROM identification, padding, theme/resources, no Lua errors.
3. Party reads for all six slots, nicknames, HP/status, DVs, Stat Exp, stats, moves/PP, exp bar.
4. Wild battle entry/exit, auto-swap, enemy stats/types/moves, move tracking, stat stages, catch odds, Battle Details.
5. Trainer entry/exit, class/number identity, party transitions, final rival victory.
6. Each Game Over condition and Retry Battle savestate.
7. Bag/heals/Balls/CT-CS, badges, map/route changes, log overlay, quickload.
8. Record failures and add a regression smoke for each fix.

Only Yellow FR has a real ROM in the current evidence. Do not claim other profiles are fully validated from static offsets.

Trainer-defeat and encounter-area classification are implemented in code; they still need BizHawk confirmation (gym, rival, Rocket, E4, rematches; scouting must not merge rod/land/surf tables).

### P1 — move-learning detection

`Program.getLearnedMoveInfoTable()` in `core/Program.lua` compares party levels around `wMoveNum` / `wWhichPokemon`. Confirm in BizHawk that the footer during the level-up prompt opens the correct move and never reports a stale TM/item move.

### P1 — TM/HM, UI leftovers, languages, extra logs

- Exercise TM/HM bag IDs and randomized names in BizHawk (closed-book spoilers).
- Remaining user-visible Gen 2+/GBA strings in options/languages (GachaMon copy in `Languages/*.lua`, Hidden Power UI, spa/spd sort keys on the log search screen).
- Compare UPR logs from Red, Blue, Yellow EN and Yellow FR, not only one French Yellow log.
- Trim language arrays only after confirming French log mapping and resource init.

### P2 — documentation and packaging

README, supported ROM revisions, BizHawk/core versions, `.gb/.gbc` + UPR ZX requirements, licenses (Besteon, NDS tracker), updater URLs.

## High-risk technical notes

1. **Initialization order matters.** Inspect `FileManager.LuaCode` and `FileManager.executeEachFile("initialize", ...)` before deleting a function that another module calls at load.
2. **Game Boy structure values are mixed-endian.** Party/battle multi-byte Pokémon values are big-endian; ROM pointer tables are little-endian bank pointers.
3. **Yellow FR is not a uniform address delta.** Several WRAM addresses move by five; some battle selection addresses do not; ROM tables often move by three or fifteen bytes.
4. **Trainer IDs are synthetic.** `classId * 0x100 + trainerNumber` vs UPR's single global index.
5. **RBY capture is not the Gen 3 shake formula.** Two random checks with different domains by Ball.
6. **RBY has one Special stat.** Never recreate `spa/spd` in active display or calculation paths.
7. **Passing smokes do not prove UI safety.** Most screens require BizHawk globals and are not loaded end-to-end.
8. **Continue on the current branch.** Do not introduce `/tmp` worktrees unless explicitly requested.

## Suggested next sequence

1. Launch the real Yellow FR ROM in BizHawk and fix the first startup/runtime exception until a full wild and trainer battle works.
2. Add a regression smoke for each exception.
3. Validate TM/HM, Game Over, quickload, log overlay, defeated trainers and encounter areas in Yellow FR.
4. Repeat with Yellow US, Red and Blue when lawful ROMs are available.
5. Trim leftover language/options copy and rewrite README/packaging.
6. Requirement-by-requirement completion audit; do not mark complete until all four game profiles have runtime evidence.
