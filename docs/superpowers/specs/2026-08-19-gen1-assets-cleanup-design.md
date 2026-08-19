# Nettoyage visuel Gen 1 — design

Date : 2026-08-19
Statut : implémenté (assets + smoke)

## Objectif

Le tracker Gen 1 ne doit plus embarquer d’assets visuels **inutiles hors Kanto / hors FRLG déjà câblés**. Le sélecteur d’icônes, les chemins Lua et les préfixes de fichiers restent inchangés. On allège le dépôt et on remplace le **contenu** des sprites dresseurs FRLG par des sprites combat RBY quand un équivalent existe.

Succès : un joueur Kanto ne voit plus de sprites 152+ dans les packs, plus de badges RSE, plus de têtes RS/E ; les dresseurs du log / des routes ont un look RBY ; `Settings.ini` `Pokemon_icon_set=4` (Explorers) reste valide ; les smokes Gen 1 existants passent.

## Contraintes projet

- Tracker Gen 1 uniquement (Besteon, Red/Blue/Yellow US/EU + Yellow FR).
- Pas de worktree `/tmp`. Branche courante.
- Pas de commit sauf demande explicite.
- Ne pas lancer BizHawk sauf demande.
- Les sprites dresseurs n’utilisent **pas** le préfixe `frlg-` : le fichier est `TrainerData.Classes.filename` (ex. `youngster.png`).
- `GameSettings.badgePrefix = "FRLG"` et `Constants.Badges[*].Prefix = "FRLG"` restent.

## Hors scope

- Retirer des packs du sélecteur (`Options.IconSetMap` inchangé : Original, Stadium, Gen 7+, Explorers, VPet, Walking Pals).
- Pipeline pret `gfx/trainers/*.pic` → PNG.
- Remplacer les badges FRLG par des badges arène RBY.
- Supprimer `images/types/{dark,steel,fairy}.png` : `PokemonData.Types` et `Constants.MoveTypeColors` les référencent encore.
- Élaguer `SpriteData.lua` (tables d’animation 152+).
- Nettoyer `images/icons/` (baies GBA), `maps/`, `boxart/`, `buttons/`.
- Recadrer finement les portraits dresseurs si le sprite RBY plein corps déborde : best effort, suivi séparé si ça gêne en jeu.

## Règle d’IDs Pokémon (exception 412 / 413)

La règle « Dex ≤ 151 » **seule** casserait l’œuf tracker et le fantôme de la Tour Pokémon.

IDs **conservés** dans chaque pack numéroté :

| ID | Rôle |
| --- | --- |
| `0` | Inconnu / `?` |
| `1`–`151` | Dex Kanto |
| `412` | `PokemonData.Values.EggId` |
| `413` | `PokemonData.Values.GhostId` |

Tout autre fichier dont le nom est `N.ext` avec `N` entier **hors** de cet ensemble est **supprimé**.

Cas connu : Walking Pals `walk/252.png` et `idle/252.png` (reste Hoenn) → supprimer. Ne pas ajouter les frames `faint` manquantes (seulement 21 fichiers aujourd’hui, max 150).

## 1. Icônes Pokémon

Packs (inchangés dans le code) :

- `ironmon_tracker/images/pokemon/` (`.gif`, Original)
- `ironmon_tracker/images/pokemonStadium/` (`.png`)
- `ironmon_tracker/images/pokemonUpdated/` (`.png`)
- `ironmon_tracker/images/pokemonMysteryDungeon/` (`.png`)
- `ironmon_tracker/images/pokemonVPet/` (`.png`)
- `ironmon_tracker/images/spritesWalkingPals/{walk,idle,faint,sleep}/` (`.png`)

Action : supprimer les fichiers numérotés hors `{0} ∪ [1,151] ∪ {412,413}`. Inventaire actuel ≈ 260 fichiers par pack statique (152–411), plus `252` dans walk/idle.

Aucun changement à `Options.IconSetMap` ni à `Drawing.getImagePath("PokemonIcon", ...)`.

## 2. Badges

- **Garder** les 16 `ironmon_tracker/images/badges/FRLG_badge{1–8}.png` et `FRLG_badge{1–8}_OFF.png`.
- **Supprimer** les 16 `RSE_*`.
- Le code lit déjà uniquement `FRLG` (`GameSettings.badgePrefix`, `TrackerScreen`, `LogTabTMs`, `LogTabTrainerDetails`).

## 3. Têtes joueur

Dossier `ironmon_tracker/images/player/`.

- **Garder** `boy-frlg.png`, `girl-frlg.png` (15×14, `LogTabTrainers.TabIcons`, `LogOverlay`).
- **Supprimer** `boy-e.png`, `girl-e.png`, `boy-rs.png`, `girl-rs.png`.
- Pas de remplacement par des têtes Red/Green : best effort, les têtes FRLG suffisent.

## 4. Dresseurs

Deux dossiers, **45 fichiers chacun**, mêmes noms (`<filename>.png`, sans préfixe) :

- `ironmon_tracker/images/trainers/` — sprite plein (`TrainerData.getFullImage`)
- `ironmon_tracker/images/trainerPortraits/` — icône liste (`TrainerData.getPortraitIcon`)

**Action :** contenu PNG = sprite combat RBY. Si aucun sprite RBY n’existe pour une classe, garder le visuel FRLG sous le nom de classe (`unknown.png`).

Source utilisée : PNG déjà extraits de [pret/pokered `gfx/trainers`](https://github.com/pret/pokered/tree/master/gfx/trainers) (56×56, 2-bit). Pas de conversion `.pic`. `unknown.png` reste le PNG FRLG (pas d’équivalent RBY).

Les deux dossiers reçoivent **le même** PNG (best effort). Un recadrage portrait n’est pas requis dans ce chantier.

### Mapping classe → sprite RBY

| Fichier actuel | Classe `TrainerData` | Sprite RBY |
| --- | --- | --- |
| `gymleader-1` | GymLeader1 | Brock |
| `gymleader-2` | GymLeader2 | Misty |
| `gymleader-3` | GymLeader3 | Lt. Surge |
| `gymleader-4` | GymLeader4 | Erika |
| `gymleader-5` | GymLeader5 | Koga |
| `gymleader-6` | GymLeader6 | Sabrina |
| `gymleader-7` | GymLeader7 | Blaine |
| `gymleader-8` | GymLeader8 | Giovanni |
| `elitefour-1` | EliteFour1 | Lorelei |
| `elitefour-2` | EliteFour2 | Bruno |
| `elitefour-3` | EliteFour3 | Agatha |
| `elitefour-4` | EliteFour4 | Lance |
| `elitefour-champ` | EliteChampion | Rival (Champion / Blue 3) |
| `rival-a` | RivalFRLGA | Rival 1 |
| `rival-b` | RivalFRLGB | Rival 2 |
| `rival-c` | RivalFRLGC | Rival 3 |
| `camper` | Camper | Jr. Trainer ♂ |
| `picnicker` | Picnicker | Jr. Trainer ♀ |
| `fisherman` | Fisherman | Fisherman |
| `gamer` | Gamer | Gambler |
| `cooltrainer` | CoolTrainer | Cooltrainer ♂ (un seul fichier FRLG) |
| `swimmer-m` | SwimmerM | Swimmer |
| `team-rocket-grunt` | TeamRocketGrunt | Team Rocket Grunt |
| `beauty` | Beauty | Beauty |
| `biker` | Biker | Biker |
| `bird-keeper` | BirdKeeper | Bird Keeper |
| `blackbelt` | BlackBelt | Black Belt |
| `bug-catcher` | BugCatcher | Bug Catcher |
| `burglar` | Burglar | Burglar |
| `channeler` | Channeler | Channeler |
| `cue-ball` | CueBall | Cue Ball |
| `engineer` | Engineer | Engineer |
| `gentleman` | Gentleman | Gentleman |
| `hiker` | Hiker | Hiker |
| `juggler` | Juggler | Juggler |
| `lass` | Lass | Lass |
| `pokemaniac` | PokeManiac | PokéManiac |
| `psychic` | Psychic | Psychic |
| `rocker` | Rocker | Rocker |
| `sailor` | Sailor | Sailor |
| `scientist` | Scientist | Scientist |
| `super-nerd` | SuperNerd | Super Nerd |
| `tamer` | Tamer | Tamer |
| `youngster` | Youngster | Youngster |
| `unknown` | Unknown | garder FRLG s’il n’existe pas d’« unknown » RBY |

`getClassFilename` renvoie `trainerClass.filename` sans préfixe. Les clés Lua `RivalFRLGA/B/C` restent (identifiants internes, pas des noms de fichiers).

## 5. Types

`ironmon_tracker/images/types/` : **aucun fichier à supprimer**. Dark / Steel / Fairy restent, car encore référencés dans les tables Lua.

## Gestion d’erreur

- Icône 1–151 / 0 / 412 / 413 absente : ne pas « réparer » en copiant un autre dex ; le smoke échoue.
- Sprite RBY introuvable pour une classe : on n’écrase pas ; le FRLG reste ; le smoke des préfixes passe quand même.
- Téléchargement Bulbagarden en échec : documenter la classe dans le plan et garder FRLG ; ne pas bloquer le reste du nettoyage.

## Tests

Nouveau smoke `tools/gen1_assets_smoke.lua` (Lua CLI, comme les autres `tools/gen1_*_smoke.lua`) :

1. Pour chaque pack listé en §1 : tout fichier `N.ext` a `N ∈ {0} ∪ [1,151] ∪ {412,413}` (on ne supprime jamais un fichier de cet ensemble s’il existe déjà). Packs statiques : **exiger** `0`, `1`–`151`, `412`, `413`. Walking Pals : n’exiger ni `0` ni une couverture faint complète ; **exiger** `idle/412.png` et `idle/413.png` (SpriteData les référence).
2. Zéro fichier `RSE_*` sous `images/badges/`. Les 16 `FRLG_badge*` existent.
3. Sous `images/player/` : `boy-frlg.png` et `girl-frlg.png` existent ; `boy-e`, `girl-e`, `boy-rs`, `girl-rs` n’existent pas.
4. `images/trainers/` et `images/trainerPortraits/` : exactement les 45 `<filename>.png` de `TrainerData.Classes` ; aucun préfixe `frlg-`.
5. Relancer `tools/gen1_removed_subsystems_smoke.lua` (`frlg-` absent de `TrainerData`, têtes `boy-frlg`).

Ordre TDD : écrire le smoke **avant** les suppressions / remplacements, le faire échouer sur l’état actuel (152+, RSE, têtes RS/E), puis appliquer les deletes, puis les remplacements dresseurs.

Pas de test visuel BizHawk dans ce chantier.

## Ordre d’implémentation

1. Smoke assets (échoue).
2. Supprimer dex hors ensemble d’IDs, badges RSE, têtes RS/E.
3. Smoke assets (passe après les deletes).
4. Remplacer le contenu des PNG dresseurs selon le mapping, sous `<filename>.png` (sans `frlg-`).
5. Relancer smokes assets + removed-subsystems.
