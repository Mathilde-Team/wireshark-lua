# Aerospike

Dissecteur Wireshark Lua pour [Aerospike](https://aerospike.com/) (base de
données clé-valeur distribuée) : protocole client Aerospike, heartbeats (maillé
TCP et multicast UDP) et menu « Hot Key Report » (issue #453).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/aerospike-community/aerospike-wireshark-plugin |
| Commit importé | `86dbde735a0c53d6faf6208db484d82420b888ad` du 07/01/2021 |
| Licence amont | AGPL-3.0 (`LICENSE.txt` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Aerospike natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont). La licence AGPL-3.0 est conservée telle quelle : elle ne
peut pas être re-licenciée en GPL (en-tête SPDX `AGPL-3.0-or-later`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/aerospike.lua` | Dissecteur des messages clients (TCP 3000 par défaut), heartbeats mesh (TCP 3002) et multicast (UDP 9918), menu « Aerospike/Hot Key Report » |

Le dépôt amont contient aussi `docs/` et `tests/` (documentation Python
d'atelier, hors périmètre du dissecteur) : non importés.

## Utilisation

Copier `src/aerospike.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Les ports (3000, 3002, 9918) sont modifiables
dans les préférences du protocole.

## Limites constatées à l'import

- le dissecteur amont date de 2021 : les types de messages récents d'Aerospike
  ne sont pas couverts ;
- pas de dissecteur natif équivalent dans Wireshark 4.6.4.
