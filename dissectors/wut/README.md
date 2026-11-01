# WuT (W&T Com-Server)

Dissecteur Wireshark Lua pour le protocole de configuration des
**Com-Servers de Wiesemann & Theis** (W&T) : messages de contrôle
(`wut_control.lua`, TCP 9094) et d'information (`wut_info.lua`, UDP 8513).

Projet indépendant, sans lien avec Wiesemann & Theis GmbH. L'auteur amont
le présente comme une ébauche initiale : tout le protocole n'est pas couvert.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/FlorianKutzer/wut-dissector (miroir de https://codeberg.org/FlorianKutzer/wut-dissector) |
| Commit importé | `875664a22f7a6263b4bb4939fa1d09e1bef5be33` du 27/02/2023 (branche `wip`, « Removed shebang that prevents the script from running. »), identique sur Codeberg |
| Licence amont | ISC (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur W&T Com-Server natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `wut_control.lua` | Protocole de contrôle `WuT-Control` sur TCP 9094 (commandes de configuration, état des lignes série) |
| `wut_info.lua` | Protocole d'information `WuT-Info` sur UDP 8513 (arbre vide, colonne protocole seulement) |

Fichiers importés tels quels. Seule une en-tête SPDX + provenance de quatre
lignes a été ajoutée, en première ligne pour `wut_control.lua` et juste après
le shebang amont (`#!/usr/bin/env lua`) pour `wut_info.lua`.

## Utilisation

Copier `wut_control.lua` et `wut_info.lua` dans le dossier `plugins` de
Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins
Lua.

## Remarques

- Ébauche amont : décodage partiel du protocole de contrôle, `wut_info.lua`
  n'expose aucun champ.
- Limite amont connue, non corrigée (import tel quel) : les deux fichiers
  déclarent la même variable globale `wut_protocol`, et les fonctions
  `dissector` la relisent à chaque paquet (`wut_protocol.name`,
  `tree:add(wut_protocol, …)`). Si les deux fichiers sont chargés, le
  dernier chargé l'emporte : le trafic de l'autre protocole peut alors être
  libellé sous le mauvais nom dans la colonne Protocole et l'arbre (non
  vérifié dans Wireshark). Pour un libellé exact, ne charger que le fichier
  utile, en général `wut_control.lua`.
- Dépôt amont inactif depuis février 2023.
