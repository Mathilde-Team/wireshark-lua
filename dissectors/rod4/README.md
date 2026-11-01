# ROD4 (scanners LIDAR Leuze)

Dissecteur Wireshark Lua du protocole binaire **ROD4** des scanners laser
(LIDAR) de la série ROD4 de Leuze, également utilisés par Christie AirScan,
sur TCP 9008 : trames de mesure, distances par point et somme de contrôle.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/dev-joss/rod4-dissector |
| Commit importé | `2eb7b4e679e76dc71b9288cfcf23ebd2846d75f0` du 01/12/2016 (branche `master`, dernier commit) |
| Licence amont | MIT (`LICENSE` amont et en-tête de `rod4.lua`, © 2016 Joss Gray) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur ROD4 natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `rod4.lua` | Dissecteur ROD4 (TCP 9008) |
| `captures/rod4 sample.pcapng` | Capture d'exemple amont (1 338 trames, toutes en TCP 9008) |

Fichiers importés tels quels. Seule une en-tête SPDX + provenance de quatre
lignes a été ajoutée en tête de `rod4.lua` (la notice MIT amont suit).

## Utilisation

Copier `rod4.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), recharger les plugins Lua, puis
ouvrir la capture d'exemple.

## Remarques

- Le décodage des distances et de la somme de contrôle se règle par les
  variables globales `parseDistances` et `parseChecksum` en tête du fichier
  (activées par défaut) ; désactiver les distances allège l'affichage des
  trames longues.
- Variables globales (`rod4Proto`, `tcpTable`, `subtree`) : collision
  possible avec d'autres plugins qui utiliseraient les mêmes noms.
- Pas d'essai dans Wireshark ; dépôt amont inactif depuis décembre 2016.
