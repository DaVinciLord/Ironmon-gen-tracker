# Handoff — IronMON Tracker Generation 1

## Objective and completion bar

Build a complete Generation 1-only IronMON tracker from the current Besteon tracker architecture, informed by the NDS tracker where useful. It must support Red/Blue/Yellow US/EU and French Yellow, preserve current validated information, use native RBY mechanics and memory layouts, and remove features/data that do not exist in Generation 1.

This objective is **not complete**. Native data, battle, trainer-defeat, encounter-area, and overworld helpers now have automated coverage on the current branch, but no full interactive BizHawk validation has been completed.

## Authoritative workspace

- Branch: current working branch (do not create `/tmp` worktrees)
- Real validated French Yellow ROM: `/run/media/vincent/7b80c546-f1fb-4c26-b197-f5c26f6e1d43/Games/Pokémon/IronMON/roms/seeds/YellowKaizo062.gbc`
- Matching real log: `/run/media/vincent/7b80c546-f1fb-4c26-b197-f5c26f6e1d43/Games/Pokémon/IronMON/roms/seeds/YellowKaizo062.gbc.log`
- UPR ZX jar: `/run/media/vincent/7b80c546-f1fb-4c26-b197-f5c26f6e1d43/Games/Pokémon/IronMON/PokeRandoZX-v4_6_1/PokeRandoZX.jar`

## Implemented and currently passing

### Native game profiles and memory

- R/B US/EU, Yellow US/EU, and Yellow FR profiles in `ironmon_tracker/GameProfiles.lua`.
- Historical randomized header aliases currently recognized for Red Kaizo and Yellow Kaizo.
- Native BizHawk Game Boy System Bus mappings for WRAM and ROM.
- Yellow FR addresses were checked against the real ROM/runtime information; do not replace them with a blanket regional offset.
- The old Ruby/Sapphire/Emerald/FRLG JSON address registry was removed.
- `GameSettings.lua` now selects only native Gen 1 profiles.
- BizHawk is the intended and currently supported emulator; mGBA support was removed from the launcher/runtime path.

### Pokémon, moves, mechanics, items

- Native 44-byte party and active-battle readers.
- Correct big-endian HP/stats/experience reads.
- DVs, HP DV derivation, five Stat Experience values, and one Special stat.
- Exactly 151 bundled Pokémon and 165 bundled moves remain in the active data files.
- Complete internal-species ↔ Pokédex mapping, including MissingNo gaps.
- Native base stats, types, catch rate, base experience yield, growth rate, evolutions, and level-up moves are read from ROM.
- All six RBY experience formulas are implemented; the runtime experience bar uses the Pokémon's real 24-bit experience.
- Native type/category model and the RBY type chart, including the Ghost/Psychic bug.
- Exact RBY capture probability for Master/Ultra/Great/Poké/Safari Ball logic and status bonuses.
- RBY item IDs, heals, status cures, PP items, evolution stones, Balls, TM01–TM50 and HM01–HM05.
- TM/HM move IDs are read from each profile's native 55-byte ROM table, including Yellow FR.
- Dynamic battle types are read from native battle structs, preserving Conversion/Transform changes.

### Battle and trainers

- The inherited 1,162-line GBA battle core was replaced with a small native singles-only RBY state contract.
- Battle.lua is the RBY battle backend with the Besteon public API (no GBA Battle.lua, no post-load `.apply()`).
- Program.lua memory readers are native Gen 1 (party, bag, badges, map, TM/HM, Safari, repel, PC heals). They delegate to `Runtime.lua` and `data/Gen1TrainerData.lua` instead of patching GBA function pointers after load.
- Battle Details is the Besteon effects screen; GameFuncs read RBY battle-status bits in the same file.
- GBA Hoenn/FRLG map dumps, GBA item tables, and GBA trainer-id dumps were removed from RouteData, MiscData, RandomizerLog, and TrainerData.
- Native trainer class/party IDs, class counts, ROM party decoding and final-rival detection.
- Game Over/loss/final victory no longer reads GBA outcome/opponent addresses.
- Battle restart savestate is created on battle entry.

### Logs, routes and quickload

- UPR ZX RBY base stats use one Special column.
- Native RBY evolution, moveset, trainer and TM log parsing.
- Global UPR trainer indices are mapped to native class/party IDs.
- RBY encounter-slot rates and English/French route-name mapping.
- Old/Good Rod global tables are propagated to Super Rod locations.
- `.gb` and `.gbc` quickload support is implemented.
- The real French Yellow log currently parses to 124 populated encounter areas, 396 trainers and 50 TMs.

### Removed subsystems

- GachaMon runtime/data/UI/network/options.
- Ability data, lookup, filters and active UI.
- Held-item/nature/ability rows from primary Gen 1 views.
- mGBA runtime/display modules.
- GBA Battle Details and battle core.
- Gen 2/3 Pokémon and move table tails.
- Gen 3 address JSON files.

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

At handoff time there are 23 smoke tests. The ROM integration proves the real Yellow FR profile can locate 151 stat records, 165 moves, 151 evolution/learnset pointers and 47 trainer-class pointers. This does **not** prove interactive emulator behavior.

## Required work remaining — functional priority

### P0 — full BizHawk runtime validation

This is the main completion gate and has not been done.

For each of Red US/EU, Blue US/EU, Yellow US/EU and Yellow FR:

1. Launch `Ironmon-Tracker.lua` in a supported BizHawk version with the correct Game Boy core.
2. Verify startup, ROM identification, padding, theme/resources and no Lua errors.
3. Start/load a run and verify party reads for all six slots, nicknames, HP/status, DVs, Stat Exp, stats, moves/PP and experience bar.
4. Verify wild battle entry/exit, auto-swap, enemy stats/types/moves, move tracking, stat stages, catch odds and Battle Details.
5. Verify trainer entry/exit, class/number identity, party transitions and final rival victory.
6. Verify each Game Over condition and Retry Battle savestate.
7. Verify bag/heals/Balls/CT-CS, badges, map/route changes, log overlay and quickload.
8. Record screenshots and exact failures. Add a regression test for every fixed runtime failure.

Only Yellow FR has a real ROM available in the current evidence. Obtain lawful test ROMs or user-provided runtime access for the other three profiles; do not claim those profiles are fully validated from static offsets alone.

### P0 — defeated trainers and route completion

Implemented on the current branch (session + `.TDAT` persistence, gym leaders inferred from badges, static gym/E4/rival maps plus trainers remembered where they are fought). Still needs BizHawk verification for gym, rival, Rocket, Elite Four and rematch/duplicate-class edge cases.

### P0 — encounter-area classification

Implemented: walking, surfing, Old/Good/Super Rod are distinct `RouteData.EncounterArea` tables. Global rod tables stay on Pallet Town (`0x00`), not the synthetic `0x100` map. Still needs BizHawk confirmation that scouting does not merge tables.

### P0 — loaded GBA code paths that can still crash

The former `ironmon_tracker/gen1/` folder is gone. Modules now live next to Besteon (`GameProfiles.lua`, `PokemonDataReader.lua`, `Runtime.lua`, `data/DataAdapter.lua`, `data/SpeciesMap.lua`, `data/Gen1RouteData.lua`, `data/Gen1TrainerData.lua`, `data/Gen1RandomizerLog.lua`). Item tables are native in `MiscData.lua`. `TrackerAPI.getOpponentTrainerId` / `getBattleOutcome` read RBY WRAM. Save-block, encryption, nature and mGBA load paths are stubs or explicit BizHawk-only errors. `PokemonData.buildData` / `MoveData.buildData` call the native ROM readers.

Remaining source cleanup (not a BizHawk crash risk if unused): Hoenn trainer class names, leftover GBA `Program.Addresses` constants, Gen 3 `MoveData.Values` ids, rse/gachamon/walking-sprite assets, and Debug GBA helpers.

### P1 — move-learning detection

- Add the necessary per-profile WRAM addresses/state for `wMoveNum`, `wWhichPokemon` and a reliable "currently learning a level-up move" discriminator.
- Replace the current safe no-op `Gen1Runtime.getLearnedMoveInfoTable()`.
- Verify clicking the game footer during the prompt opens the correct move information and never reports a stale TM/item move.

### P1 — native overworld helpers

Audit and implement only the Gen 1 equivalents actually used by active screens/options:

- player tile position;
- repel steps;
- Safari Zone state;
- evolution scene detection;
- start-menu detection;
- starter/lab state and random Ball picker;
- PC heal tracking;
- Flash/dark-area handling;
- badge/gym state;
- map names and combined dungeon areas.

Remove corresponding options/screens if they have no meaningful RBY equivalent.

### P1 — TM/HM end-to-end UI validation

Commit `3ae6b0ec` added the native data path and automated tests, but it has not been exercised in BizHawk.

- Verify bag IDs C4–C8 and C9–FA appear correctly.
- Verify randomized TM names come from the ROM/log without spoilers under closed-book settings.
- Verify EventData commands use Gen 1 numbering; the old hardcoded Gen 3 offsets were replaced with `MiscData.getTMNumber/getHMNumber` where found.
- Verify HM01–HM05 and all 50 TMs, including duplicate quantities and sorting.

### P1 — UI and options cleanup

Remove or adapt remaining user-visible Gen 2+/GBA concepts:

- nature-colored stats option and nature theme logic;
- friendship/evolution readiness rows;
- gender where irrelevant to RBY mechanics;
- eggs, held items, abilities, doubles, weather and later-generation Balls/items;
- GBA control labels and L/R behavior;
- Sevii/Hoenn route wording;
- GBA ROM/quickload/update prompts;
- later-generation type icons (Steel/Dark/Fairy) from selectable/filter lists;
- screens/options that are dead under the native runtime.

Do not merely hide a field while leaving a callable GBA reader behind.

### P1 — language/data trimming

- `Languages/*.lua` still bundle Gen 2/3 Pokémon, moves, ability descriptions, natures and GBA strings.
- Keep only languages intentionally supported by the final product. At minimum English UI plus French game-name/log mappings are required by the stated ROM support; decide whether French UI itself is a deliverable before deleting it.
- Trim move-name arrays to 165 and Pokémon-name arrays to 151 without breaking French Yellow log mapping.
- Preserve accented/special-character normalization for French names and Nidoran symbols.
- Remove ability/nature tables and later-generation descriptions after verifying resource initialization does not index them.

### P1 — static data/model cleanup

- Reduce `PokemonData.lua`, `MoveData.lua`, `MiscData.lua`, `TrainerData.lua`, `RouteData.lua`, `Constants.lua` and `Program.lua` to native Gen 1 contracts rather than relying indefinitely on overrides.
- Remove NatDex/ROM-hack extension assumptions that cannot apply to the supported profiles.
- Remove legacy internal↔National Gen 3 maps in `PokemonData.lua`.
- Remove GBA stat calculators and nature multipliers.
- Ensure Blank Pokémon, Ghost and question-mark sprite IDs remain valid after reducing sprite data.
- Remove unused binary assets only after confirming no theme/icon path references them.

### P1 — log and route completeness

- Compare multiple UPR ZX logs from Red, Blue, Yellow English and Yellow French, not only one French Yellow log.
- Test unrandomized logs, randomized evolutions, unchanged moves, static encounters, all rods, Safari and duplicate floor names.
- Validate trainer counts/ordering against each profile and UPR version(s) intended to be supported.
- Determine whether future/current UPR ZX versions change section names or French formatting.

### P2 — documentation, packaging and attribution

- Rewrite `README.md`, `README.txt`, quickload instructions and install/update instructions for a Gen 1-only BizHawk tracker.
- State exact supported ROM regions/revisions and emulator/core versions.
- Remove GBA screenshots and setup guidance.
- Document `.gb/.gbc` and UPR ZX log requirements.
- Audit upstream licenses and preserve attribution to Besteon and Brian0255/NDS tracker where code or architecture was retained.
- Decide final repository/project name and version.
- Ensure updater URLs do not point at the original Besteon release channel unless intentionally retained.

## High-risk technical notes

1. **Initialization order matters.** Gen 1 modules replace inherited functions during module loading and again during initialization. Before deleting a generic function, inspect `FileManager` load order and `FileManager.executeEachFile("initialize", ...)`.
2. **Game Boy structure values are mixed-endian.** Party/battle multi-byte Pokémon values are read big-endian; ROM pointer tables are little-endian bank pointers. Do not replace the custom readers with generic `Memory.readword` without checking the field.
3. **Yellow FR is not a uniform address delta.** Several WRAM addresses move by five, some battle selection addresses do not, and ROM tables often move by three or fifteen bytes.
4. **Trainer IDs are synthetic.** They are encoded as `classId * 0x100 + trainerNumber`, while UPR logs use a single global index. Preserve the mapping layer.
5. **RBY capture is not the Gen 3 shake formula.** The native implementation uses two random checks with different random domains by Ball.
6. **RBY has one Special stat.** Never recreate `spa/spd` aliases in active display/calculation paths merely to satisfy inherited code.
7. **Passing smoke tests do not prove UI safety.** Most inherited screens require BizHawk globals and are not loaded end-to-end by the smoke suite.
8. **Continue on the current branch.** Do not introduce `/tmp` worktrees unless explicitly requested.

## Suggested next sequence

1. Preserve/move the `/tmp` worktree and run the complete automated suite.
2. Launch the real Yellow FR ROM in BizHawk and fix the first startup/runtime exception until a full wild and trainer battle works.
3. Add a regression smoke test for each exception.
4. Implement defeated-trainer state and encounter-area classification.
5. Validate TM/HM, Game Over, quickload and log overlays in Yellow FR.
6. Repeat with Yellow US, Red and Blue ROMs.
7. Remove the now-proven-dead GBA call paths and UI/options in coherent commits.
8. Trim language/resources and assets.
9. Rewrite documentation and packaging.
10. Perform a requirement-by-requirement completion audit; do not mark complete until all four game profiles have runtime evidence.

## Recent key commits

- `3ae6b0ec` Read native RBY TM and HM data
- `7d406cbb` Read dynamic battle types from native RBY memory
- `28b12211` Use exact Generation 1 capture odds
- `9ba30380` Read native RBY catch and experience data
- `599a33f9` Trim bundled species and moves to Generation 1
- `3ef1e668` Remove inherited Gen 3 address registry
- `52b9b038` Restore native RBY game over flow
- `1988b498` Replace inherited GBA battle core with native RBY state
- `7e8ba41c` Replace battle details with native RBY state
- `2e73e3a6` Target native Gen 1 runtime on BizHawk
- `4f1bd919` Parse native RBY encounter log routes
- `1f916653` Support native Game Boy ROM quickload files

Use `git log --oneline --decorate` for the full history; the branch contains many earlier atomic Gen 1 commits not repeated here.
