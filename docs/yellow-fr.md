# Pokémon Jaune FR — support IronMON expérimental

Ce fork ajoute un premier support de **Pokémon Version Jaune — Édition Spéciale Pikachu (France)** pour le tracker Gen 1.

## État actuel

Le support est volontairement minimal afin de stabiliser la compatibilité avant de rattraper les fonctionnalités des trackers GBA/DS.

- Détection du header français `POKEMON YELAPSF` (`YELA` à l'offset utilisé par le tracker) : **validée en runtime sur BizHawk/Linux**.
- Correction des deux offsets ROM spécifiques à Yellow (F) nécessaires au tracker :
  - movesets : `0x3B1E5 -> 0x3B1E8` (+3)
  - trainers : `0x39DD1 -> 0x39DD4` (+3)
- Les tables de données de base restent aux mêmes emplacements utilisés par la version US :
  - move data : `0x38000`
  - base stats : `0x383DE`
- L'interface du tracker reste en anglais pour l'instant ; le jeu, lui, reste en français.

Les offsets ROM proviennent de la configuration Gen 1 d'Universal Pokémon Randomizer ZX pour `Yellow (F)`.

## Validation WRAM

Le premier test runtime a invalidé l'hypothèse consistant à réutiliser directement les constantes WRAM historiques du fork.

En particulier, le tracker upstream définit `gPlayerPartyCount` depuis `0x189C` (puis `-1` pour Yellow), mais le test avec Pikachu présent dans l'équipe retourne `0` à cette adresse. Cette constante ne correspond donc pas à la structure d'équipe Gen 1 utilisée ici.

### Structure d'équipe — validée

`tools/yellow_fr_probe.lua` v2 a localisé sans ambiguïté la structure d'équipe sur un dump français propre, avec Pikachu comme unique Pokémon :

- `partyCount = WRAM:1167`
- `partySpecies = WRAM:1168`
- `partyMon1 = WRAM:116F`

Signature observée :

```text
WRAM:1167  01 54 FF 00 00 00 00 00 54 ...
```

La version US documentée par `pret/pokeyellow` place `wPartyCount` à `$D162`, soit `WRAM:1162` dans BizHawk. Le bloc d'équipe français observé est donc décalé de **+5 octets**, mais ce delta ne doit pas être appliqué aveuglément aux autres blocs WRAM.

### Structure de combat — probe v3

`tools/yellow_fr_probe.lua` v3 part de la structure d'équipe confirmée et cherche dynamiquement la copie de Pikachu dans `BattleMon` lors de l'entrée en combat.

Le probe compare les champs stables communs à `PartyMon` et `BattleMon` : espèce, HP, statut, types, catch rate, attaques, niveau et HP max. Une fois `BattleMon` identifié, les autres adresses de combat sont dérivées par leurs distances relatives dans le layout officiel Pokémon Jaune US de `pret/pokeyellow` : `EnemyMon`, `wIsInBattle`, `wBattleType`, `wPlayerMoveNum`, `wEnemyMoveNum`, `wPlayerSelectedMove`, `wEnemySelectedMove` et `wPlayerMonNumber`.

### Procédure v3

1. Charger un dump propre de Pokémon Jaune FR dans BizHawk.
2. Garder Pikachu comme unique Pokémon de l'équipe.
3. Être **hors combat**.
4. Ouvrir `Tools -> Lua Console`.
5. Charger la dernière version de `tools/yellow_fr_probe.lua`.
6. Attendre `PARTY CHECK: OK`.
7. Déclencher un combat sauvage normal.
8. Attendre `BATTLE MON: UNIQUE MATCH`.
9. Utiliser quelques attaques puis terminer ou fuir le combat.
10. Copier la sortie complète jusqu'à `BATTLE END DETECTED`.

Le script est strictement en lecture seule.

## Kaizo IronMON

Pour Jaune, la méthode officielle Gen 1 utilise deux passes successives dans UPR ZX. La ROM obtenue à la première passe devient l'entrée de la seconde passe.

Ce dépôt ne distribue aucune ROM ni aucun contenu propriétaire Pokémon.

## Roadmap

### Phase 1 — stabilisation Jaune FR

- [x] Valider la détection du header français dans BizHawk.
- [x] Localiser et valider la structure d'équipe en WRAM.
- [ ] Localiser et valider le bloc de combat en WRAM.
- [ ] Valider toutes les adresses WRAM utilisées pendant exploration, combat et menus.
- [ ] Corriger les constantes Gen 1 upstream manifestement erronées avant d'ajouter les overrides FR.
- [ ] Vérifier une seed randomisée complète avec le tracker.
- [ ] Vérifier la procédure officielle Kaizo en deux passes sur ROM FR.
- [ ] Corriger les écarts de données/noms liés à la localisation française si nécessaire.
- [ ] Ajouter des tests ou diagnostics reproductibles pour les offsets critiques.

### Phase 2 — parité GBA/DS

Une fois Jaune FR fiable, comparer systématiquement le tracker Gen 1 avec les trackers GBA/DS modernes et porter les fonctionnalités utiles : ergonomie, tracking de combats, statistiques de runs, affichages avancés, raccourcis et qualité de vie.

La règle de travail est : **ne pas mélanger parité fonctionnelle et stabilisation mémoire**.
