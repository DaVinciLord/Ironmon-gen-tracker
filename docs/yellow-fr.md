# Pokémon Jaune FR — support IronMON expérimental

Ce fork ajoute un premier support de **Pokémon Version Jaune — Édition Spéciale Pikachu (France)** pour le tracker Gen 1.

## État actuel

Le support est volontairement minimal afin de stabiliser la compatibilité avant de rattraper les fonctionnalités des trackers GBA/DS.

- Détection du header français `POKEMON YELAPSF` (`YELA` à l'offset utilisé par le tracker).
- Réutilisation de la logique WRAM déjà appliquée à Pokémon Jaune par le tracker.
- Correction des deux offsets ROM spécifiques à Yellow (F) nécessaires au tracker :
  - movesets : `0x3B1E5 -> 0x3B1E8` (+3)
  - trainers : `0x39DD1 -> 0x39DD4` (+3)
- Les tables de données de base restent aux mêmes emplacements utilisés par la version US :
  - move data : `0x38000`
  - base stats : `0x383DE`
- L'interface du tracker reste en anglais pour l'instant ; le jeu, lui, reste en français.

Les offsets ROM proviennent de la configuration Gen 1 d'Universal Pokémon Randomizer ZX pour `Yellow (F)`.

## Validation WRAM

La cartographie RAM complète de Jaune FR n'étant pas documentée de manière suffisamment fiable, le support WRAM doit être validé en runtime.

Utiliser `tools/yellow_fr_probe.lua` dans BizHawk :

1. Charger un dump propre de Pokémon Jaune FR.
2. Ouvrir `Tools -> Lua Console`.
3. Charger `tools/yellow_fr_probe.lua`.
4. Vérifier :
   - `ROM title @0134: POKEMON YELAPSF`
   - `Tracker detector @013C: YELA`
   - `HEADER: OK`
5. Récupérer le starter et vérifier que `partyCount @189B` devient `1`.
6. Déclencher un combat sauvage et observer les changements sur les valeurs de combat.

Le script est strictement en lecture seule.

## Kaizo IronMON

Pour Jaune, la méthode officielle Gen 1 utilise deux passes successives dans UPR ZX. La ROM obtenue à la première passe devient l'entrée de la seconde passe.

Ce dépôt ne distribue aucune ROM ni aucun contenu propriétaire Pokémon.

## Roadmap

### Phase 1 — stabilisation Jaune FR

- [ ] Valider toutes les adresses WRAM utilisées pendant exploration, combat et menus.
- [ ] Vérifier une seed randomisée complète avec le tracker.
- [ ] Vérifier la procédure officielle Kaizo en deux passes sur ROM FR.
- [ ] Corriger les écarts de données/noms liés à la localisation française si nécessaire.
- [ ] Ajouter des tests ou diagnostics reproductibles pour les offsets critiques.

### Phase 2 — parité GBA/DS

Une fois Jaune FR fiable, comparer systématiquement le tracker Gen 1 avec les trackers GBA/DS modernes et porter les fonctionnalités utiles : ergonomie, tracking de combats, statistiques de runs, affichages avancés, raccourcis et qualité de vie.

La règle de travail est : **ne pas mélanger parité fonctionnelle et stabilisation mémoire**.
