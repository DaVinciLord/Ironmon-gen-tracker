# Pokémon Jaune FR — support IronMON expérimental

Ce fork ajoute un support expérimental de **Pokémon Version Jaune — Édition Spéciale Pikachu (France)** pour le tracker Gen 1.

L'objectif de la phase actuelle est de rendre la compatibilité mémoire fiable avant de rattraper les fonctionnalités des trackers GBA/DS.

## État actuel

- Header français `POKEMON YELAPSF` (`YELA` à l'offset utilisé par le tracker) : **validé en runtime sur BizHawk/Linux**.
- Offsets ROM Yellow (F) nécessaires au tracker :
  - movesets : `0x3B1E5 -> 0x3B1E8` (+3)
  - trainers : `0x39DD1 -> 0x39DD4` (+3)
- Tables ROM inchangées par rapport à la version US :
  - move data : `0x38000`
  - base stats : `0x383DE`
- Première memory map WRAM française intégrée dans `YellowFRSupport.lua`.
- Combat dresseur et combat sauvage validés en runtime.
- Affichage de l'adversaire, révélation progressive de ses attaques et stat stages ennemis validés en runtime.
- Interface du tracker encore en anglais ; le jeu reste en français.

Les offsets ROM proviennent de la configuration Gen 1 d'Universal Pokémon Randomizer ZX pour `Yellow (F)`.

## Pourquoi les anciennes constantes ne peuvent pas être réutilisées telles quelles

Le premier test runtime a invalidé plusieurs constantes WRAM historiques du fork. Exemple : le tracker upstream définit `gPlayerPartyCount` depuis `0x189C` (puis `-1` pour Yellow), alors qu'un dump Jaune FR avec Pikachu dans l'équipe retourne `0` à cette adresse.

Le code Gen 1 actuel contient aussi plusieurs noms hérités de l'architecture GBA qui ne décrivent pas réellement la donnée lue. Par exemple, `gBattleTypeFlags` pointe en réalité sur `wIsInBattle` en Gen 1.

## Méthode de reconstruction de la WRAM Jaune FR

Il n'existe pas, à notre connaissance, de désassemblage complet de Jaune FR comparable à `pret/pokeyellow`. En revanche :

1. `pret/pokeyellow` fournit la symbol map exacte de Jaune US/Europe.
2. `pret/pokered` fournit celle de Rouge US/Europe.
3. `einstein95/pokered-fr` fournit une reconstruction de Rouge FR avec sa symbol map.
4. Pour un symbole commun, on calcule le delta **Yellow US - Red US**, puis on l'applique au symbole **Red FR**.

Formule :

```text
YellowFR(symbol) = RedFR(symbol) + (YellowUS(symbol) - RedUS(symbol))
```

Cette méthode reproduit exactement toutes les adresses Jaune FR trouvées indépendamment par les probes runtime (`wPartyCount`, `wPartyMon1`, `wEnemyMon`, `wEnemyMoveNum`, `wIsInBattle`). Elle est donc utilisée pour compléter la première memory map, tout en conservant une distinction entre **runtime confirmé** et **dérivé**.

## Structure d'équipe — validée

Le probe v2 a trouvé une signature unique avec Pikachu comme seul Pokémon :

- `wPartyCount = WRAM:1167` — confirmé
- `wPartySpecies = WRAM:1168` — confirmé
- `wPartyMon1 = WRAM:116F` — confirmé

```text
WRAM:1167  01 54 FF 00 00 00 00 00 54 ...
```

Pour comparaison, `pret/pokeyellow` place `wPartyCount` à `$D162` et `wPartyMon1` à `$D16A`. Dans ce bloc, Jaune FR est donc à **+5** par rapport à Jaune US.

## Structure de combat — validée

### Rival 1 (combat dresseur)

Le probe v3 a été exécuté lors du premier combat contre le rival au laboratoire (Pikachu niveau 5 contre Évoli niveau 5).

| Symbole | WRAM Jaune FR | Observation |
|---|---:|---|
| `wBattleMon` | `1018` | Pikachu, niveau/HP/moves cohérents |
| `wEnemyMon` | `0FE9` | Évoli, niveau/HP/moves cohérents |
| `wIsInBattle` | `105B` | `2` pendant le combat dresseur, puis `0` à la fin |
| `wBattleType` | `105E` | `0`, combat normal |
| `wEnemyMoveNum` | `0FD0` | attaque d'Évoli observée |
| `wPlayerMoveNum` | `0FD6` | moves de Pikachu observés |
| `wBattleMonHP` | `1019..101A` | `19 -> 13 -> 5 -> 0` pendant la défaite |
| `wEnemyMonHP` | `0FEA..0FEB` | `21 -> 16 -> 11 -> 6` |

### Combats sauvages (probe v4)

Deux combats sauvages ont ensuite validé la sémantique et les adresses corrigées :

- `wIsInBattle = 1` pendant un sauvage puis `0` à la fin : **confirmé**.
- `wPlayerSelectedMove = CCDC` : **confirmé**.
- `wEnemySelectedMove = CCDD` : **confirmé**.
- `wPlayerMoveNum = CFD6` : **confirmé**.
- `wEnemyMoveNum = CFD0` : **confirmé** sur le second combat.
- `wEnemyMonType1 = CFEE` : valeurs cohérentes (Pidgey Normal/Vol, Rattata Normal).
- `wCurMap = D362`, `wNumBagItems = D321`, `wBagItems = D322`, `wObtainedBadges = D35A` : snapshots cohérents en runtime.

Les adversaires observés correspondaient correctement aux IDs internes Gen 1 : `0x24 = Pidgey` et `0xA5 = Rattata`.

## Correction d'une hypothèse du probe v3

Le probe v3 supposait temporairement que tout le bloc inférieur suivait le même décalage `+5`. Le runtime a montré que `CCE2` variait comme un **index de move** plutôt que comme un identifiant d'attaque.

La zone correcte est :

- `wPlayerSelectedMove = CCDC`
- `wEnemySelectedMove = CCDD`
- `wEnemyMoveListIndex = CCE2`
- `wPlayerMonNumber = CC2F`

Le probe v4 a validé cette correction.

## Première memory map utilisée par le tracker

```text
wPlayerMonNumber      = CC2F  -> WRAM:0C2F
wPlayerSelectedMove   = CCDC  -> WRAM:0CDC
wEnemySelectedMove    = CCDD  -> WRAM:0CDD
wPlayerMonStatMods    = CD1A  -> WRAM:0D1A
wEnemyMoveNum         = CFD0  -> WRAM:0FD0
wPlayerMoveNum        = CFD6  -> WRAM:0FD6
wEnemyMon             = CFE9  -> WRAM:0FE9
wEnemyMonType1        = CFEE  -> WRAM:0FEE
wBattleMon            = D018  -> WRAM:1018
wIsInBattle           = D05B  -> WRAM:105B
wBattleType           = D05E  -> WRAM:105E
wPartyCount           = D167  -> WRAM:1167
wPartyMon1            = D16F  -> WRAM:116F
wNumBagItems          = D321  -> WRAM:1321
wBagItems             = D322  -> WRAM:1322
wObtainedBadges       = D35A  -> WRAM:135A
wCurMap               = D362  -> WRAM:1362
```

## Affichage de l'adversaire dans le tracker — validé

Le tracker ne bascule **pas automatiquement** sur l'adversaire avec les réglages par défaut : `Auto swap to enemy = false`.

Avec `Auto swap to enemy` activé puis le script redémarré, un Pidgey sauvage a été affiché correctement dans le vrai tracker : sprite, espèce, niveau et types `NORMAL / FLYING` cohérents.

Le tracker respecte aussi la révélation progressive des informations IronMON :

- les attaques adverses ne sont pas affichées avant d'avoir été observées ;
- après utilisation de `Gust`, l'attaque apparaît correctement dans la liste des moves connus ;
- après `Growl` / Rugissement lancé par le joueur, la baisse d'ATK adverse est correctement reflétée dans le tracker.

Cela valide en runtime le chemin `wEnemyMoveNum -> Tracker.TrackMove()` ainsi que la lecture des stat stages ennemis utilisée par `Battle.updateStatStages()`.

## Détection sauvage / dresseur

La fonction Gen 1 upstream `Program.updateBattleEncounterType()` utilise actuellement des compteurs stubés à `0`, ce qui empêchait `Battle.isWildEncounter` de devenir vrai.

Pour Jaune FR, `YellowFRSupport.lua` remplace maintenant cette logique par la valeur native de `wIsInBattle` :

```text
0 = hors combat
1 = combat sauvage
2 = combat dresseur
```

Cette sémantique est validée par les probes v3/v4.

## Dette connue : `gTurn`

Le tracker historique utilise `WRAM:0CD5` sous le nom `gTurn`. La symbol map montre qu'en Gen 1 cette adresse correspond à `wAILayer2Encouragement`, **pas à un compteur de tours**.

On conserve temporairement cette valeur pour ne pas mélanger un refactor de la logique de tracking avec le portage FR. Elle devra être remplacée par une détection de tour/action adaptée au moteur Gen 1.

## Kaizo IronMON

Pour Jaune, la méthode officielle Gen 1 utilise deux passes successives dans UPR ZX. La ROM obtenue à la première passe devient l'entrée de la seconde passe.

Ce dépôt ne distribue aucune ROM ni aucun contenu propriétaire Pokémon.

## Roadmap

### Phase 1 — stabilisation Jaune FR

- [x] Valider la détection du header français dans BizHawk.
- [x] Localiser et valider la structure d'équipe en WRAM.
- [x] Localiser et valider le bloc de combat principal en WRAM (Rival 1).
- [x] Valider un combat sauvage et les selected moves avec le probe v4.
- [x] Intégrer une première memory map Jaune FR dans le vrai tracker.
- [x] Corriger la détection sauvage/dresseur pour Jaune FR.
- [x] Confirmer l'affichage auto de l'adversaire dans le vrai tracker.
- [x] Confirmer la révélation des attaques adverses après utilisation.
- [x] Valider au moins un stat stage ennemi en runtime (ATK abaissée par Rugissement/Growl).
- [ ] Remplacer la fausse notion `gTurn` par une logique Gen 1 fiable.
- [ ] Valider changements de Pokémon, combats dresseur multi-Pokémon, statuts et menus sur une session plus longue.
- [ ] Vérifier une seed randomisée complète avec le tracker.
- [ ] Vérifier la procédure officielle Kaizo en deux passes sur ROM FR.
- [ ] Corriger les écarts de données/noms liés à la localisation française si nécessaire.
- [ ] Ajouter des diagnostics/tests reproductibles pour les offsets critiques.

### Phase 2 — parité GBA/DS

Une fois Jaune FR fiable, comparer systématiquement le tracker Gen 1 avec les trackers GBA/DS modernes et porter les fonctionnalités utiles : ergonomie, tracking de combats, statistiques de runs, affichages avancés, raccourcis et qualité de vie.

La règle de travail est : **ne pas mélanger parité fonctionnelle et stabilisation mémoire**.
