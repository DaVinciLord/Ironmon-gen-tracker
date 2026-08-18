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

Cette méthode reproduit exactement toutes les adresses Jaune FR déjà trouvées indépendamment par les probes runtime (`wPartyCount`, `wPartyMon1`, `wEnemyMon`, `wEnemyMoveNum`, `wIsInBattle`). Elle est donc utilisée pour compléter la première memory map, tout en conservant une distinction entre **runtime confirmé** et **dérivé**.

## Structure d'équipe — validée

Le probe v2 a trouvé une signature unique avec Pikachu comme seul Pokémon :

- `wPartyCount = WRAM:1167` — confirmé
- `wPartySpecies = WRAM:1168` — confirmé
- `wPartyMon1 = WRAM:116F` — confirmé

```text
WRAM:1167  01 54 FF 00 00 00 00 00 54 ...
```

Pour comparaison, `pret/pokeyellow` place `wPartyCount` à `$D162` et `wPartyMon1` à `$D16A`. Dans ce bloc, Jaune FR est donc à **+5** par rapport à Jaune US.

## Structure de combat — validée sur Rival 1

Le probe v3 a été exécuté lors du premier combat contre le rival au laboratoire (Pikachu niveau 5 contre Évoli niveau 5).

Adresses et comportements observés :

| Symbole | WRAM Jaune FR | Observation |
|---|---:|---|
| `wBattleMon` | `1018` | Pikachu, niveau/HP/moves cohérents |
| `wEnemyMon` | `0FE9` | Évoli, niveau/HP/moves cohérents |
| `wIsInBattle` | `105B` | `2` pendant le combat dresseur, puis `0` à la fin |
| `wBattleType` | `105E` | `0`, combat normal |
| `wEnemyMoveNum` | `0FD0` | `0x21` observé lors d'une attaque d'Évoli |
| `wPlayerMoveNum` | `0FD6` | `0x54` puis `0x2D`, correspondant aux moves de Pikachu |
| `wBattleMonHP` | `1019..101A` | `19 -> 13 -> 5 -> 0` pendant la défaite |
| `wEnemyMonHP` | `0FEA..0FEB` | `21 -> 16 -> 11 -> 6` |

Le moteur officiel Jaune utilise `wIsInBattle = 1` pour un combat sauvage et `2` pour un combat dresseur. Le résultat `2 -> 0` du test Rival 1 valide donc fortement `WRAM:105B`.

### Correction d'une hypothèse du probe v3

Le probe v3 supposait temporairement que tout le bloc inférieur suivait le même décalage `+5`. Cela donnait :

- `playerSelectedMove = CCE1`
- `enemySelectedMove = CCE2`
- `playerMonNumber = CC34`

Le runtime a montré que `CCE2` variait comme un **index de move** (`1 -> 0`) plutôt que comme un identifiant d'attaque. La symbol map de Rouge FR confirme que cette zone basse n'est pas décalée :

- `wPlayerSelectedMove = CCDC`
- `wEnemySelectedMove = CCDD`
- `wEnemyMoveListIndex = CCE2`
- `wPlayerMonNumber = CC2F`

Le probe v4 utilise maintenant ces adresses corrigées.

## Première memory map utilisée par le tracker

### Runtime confirmé

```text
wPartyCount      = D167  -> WRAM:1167
wPartyMon1       = D16F  -> WRAM:116F
wEnemyMon        = CFE9  -> WRAM:0FE9
wEnemyMoveNum    = CFD0  -> WRAM:0FD0
wBattleMon       = D018  -> WRAM:1018
wIsInBattle      = D05B  -> WRAM:105B
```

### Dérivé par symbol maps, à valider progressivement

```text
wPlayerSelectedMove = CCDC  -> WRAM:0CDC
wEnemySelectedMove  = CCDD  -> WRAM:0CDD
wPlayerMonNumber    = CC2F  -> WRAM:0C2F
wPlayerMonStatMods  = CD1A  -> WRAM:0D1A
wEnemyMonType1      = CFEE  -> WRAM:0FEE
wBattleType         = D05E  -> WRAM:105E
wNumBagItems        = D321  -> WRAM:1321
wBagItems           = D322  -> WRAM:1322
wObtainedBadges     = D35A  -> WRAM:135A
wCurMap             = D362  -> WRAM:1362
```

## Dette connue : `gTurn`

Le tracker historique utilise `WRAM:0CD5` sous le nom `gTurn`. La symbol map montre qu'en Gen 1 cette adresse correspond à `wAILayer2Encouragement`, **pas à un compteur de tours**.

On conserve temporairement cette valeur pour ne pas mélanger un refactor de la logique de tracking avec le portage FR. Elle devra être remplacée par une détection de tour/action adaptée au moteur Gen 1.

## Probe v4 — prochain test

`tools/yellow_fr_probe.lua` v4 ne cherche plus les structures dynamiquement. Il valide directement la memory map utilisée par le tracker.

Procédure recommandée :

1. Charger la ROM Jaune FR propre dans BizHawk.
2. Être hors combat.
3. Charger `tools/yellow_fr_probe.lua` v4.
4. Sortir du laboratoire et rejoindre la Route 1 ; les changements de `wCurMap` sont journalisés.
5. Déclencher un **combat sauvage**.
6. Utiliser au moins une attaque et laisser le Pokémon sauvage en utiliser au moins une.
7. Terminer ou fuir le combat.
8. Copier la sortie de `BATTLE START DETECTED` jusqu'au résumé final.

Le test doit notamment confirmer :

- `wIsInBattle = 1` en sauvage ;
- `wPlayerSelectedMove = CCDC` ;
- `wEnemySelectedMove = CCDD` ;
- les moves exécutés à `CFD6` / `CFD0` ;
- les adresses de map/bag utilisées hors combat.

Le script est strictement en lecture seule.

## Kaizo IronMON

Pour Jaune, la méthode officielle Gen 1 utilise deux passes successives dans UPR ZX. La ROM obtenue à la première passe devient l'entrée de la seconde passe.

Ce dépôt ne distribue aucune ROM ni aucun contenu propriétaire Pokémon.

## Roadmap

### Phase 1 — stabilisation Jaune FR

- [x] Valider la détection du header français dans BizHawk.
- [x] Localiser et valider la structure d'équipe en WRAM.
- [x] Localiser et valider le bloc de combat principal en WRAM (Rival 1).
- [x] Intégrer une première memory map Jaune FR dans le vrai tracker.
- [ ] Valider combat sauvage + selected moves avec le probe v4.
- [ ] Tester le vrai tracker de bout en bout sur ROM propre.
- [ ] Remplacer la fausse notion `gTurn` par une logique Gen 1 fiable.
- [ ] Valider map, sac, badges et changements de Pokémon/ennemi sur une session plus longue.
- [ ] Vérifier une seed randomisée complète avec le tracker.
- [ ] Vérifier la procédure officielle Kaizo en deux passes sur ROM FR.
- [ ] Corriger les écarts de données/noms liés à la localisation française si nécessaire.
- [ ] Ajouter des diagnostics/tests reproductibles pour les offsets critiques.

### Phase 2 — parité GBA/DS

Une fois Jaune FR fiable, comparer systématiquement le tracker Gen 1 avec les trackers GBA/DS modernes et porter les fonctionnalités utiles : ergonomie, tracking de combats, statistiques de runs, affichages avancés, raccourcis et qualité de vie.

La règle de travail est : **ne pas mélanger parité fonctionnelle et stabilisation mémoire**.
