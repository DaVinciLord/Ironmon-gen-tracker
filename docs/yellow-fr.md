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

En particulier, le tracker upstream définit `gPlayerPartyCount` depuis `0x189C` (puis `-1` pour Yellow), mais le test avec Pikachu présent dans l'équipe retourne `0` à cette adresse. Cette constante semble provenir d'une confusion avec le code Gen 2 et ne doit pas être utilisée pour le port FR sans validation.

`tools/yellow_fr_probe.lua` v2 découvre donc la structure d'équipe directement dans la WRAM au lieu de faire confiance à ces constantes.

Avec Pikachu comme unique Pokémon, la signature recherchée est :

- `01` : un Pokémon dans l'équipe ;
- `54` : index interne Gen 1 de Pikachu ;
- `FF` : terminateur de la liste d'espèces ;
- `54` à `+8` : premier octet de la structure du premier Pokémon.

### Procédure

1. Charger un dump propre de Pokémon Jaune FR dans BizHawk.
2. Garder Pikachu comme unique Pokémon de l'équipe.
3. Ouvrir `Tools -> Lua Console`.
4. Charger `tools/yellow_fr_probe.lua` depuis la branche `agent/yellow-fr-support` la plus récente.
5. Vérifier :
   - `ROM title @0134: POKEMON YELAPSF`
   - `Tracker detector @013C: YELA`
   - `HEADER: OK`
6. Copier la section `Party layout scan` et le résultat `PARTY SIGNATURE`.

Le script est strictement en lecture seule et s'arrête volontairement après la découverte de la structure d'équipe. Les adresses de combat seront recherchées dans une seconde étape une fois cette base confirmée.

## Kaizo IronMON

Pour Jaune, la méthode officielle Gen 1 utilise deux passes successives dans UPR ZX. La ROM obtenue à la première passe devient l'entrée de la seconde passe.

Ce dépôt ne distribue aucune ROM ni aucun contenu propriétaire Pokémon.

## Roadmap

### Phase 1 — stabilisation Jaune FR

- [x] Valider la détection du header français dans BizHawk.
- [ ] Localiser et valider la structure d'équipe en WRAM.
- [ ] Valider toutes les adresses WRAM utilisées pendant exploration, combat et menus.
- [ ] Corriger les constantes Gen 1 upstream manifestement erronées avant d'ajouter les overrides FR.
- [ ] Vérifier une seed randomisée complète avec le tracker.
- [ ] Vérifier la procédure officielle Kaizo en deux passes sur ROM FR.
- [ ] Corriger les écarts de données/noms liés à la localisation française si nécessaire.
- [ ] Ajouter des tests ou diagnostics reproductibles pour les offsets critiques.

### Phase 2 — parité GBA/DS

Une fois Jaune FR fiable, comparer systématiquement le tracker Gen 1 avec les trackers GBA/DS modernes et porter les fonctionnalités utiles : ergonomie, tracking de combats, statistiques de runs, affichages avancés, raccourcis et qualité de vie.

La règle de travail est : **ne pas mélanger parité fonctionnelle et stabilisation mémoire**.
