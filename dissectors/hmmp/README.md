# HMMP (High-Performance Microservice Multiplex Protocol)

Dissecteur Wireshark Lua pour HMMP, protocole de communication entre
microservices (multiplexage, rapports de charge, gestion de connexions)
(issue #465).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/RegalPine/hmmp-dissector-lua |
| Commit importé | `e7530781b3aca73c46c16c40107ec90a5f5d054d` du 27/07/2026 |
| Licence amont | Apache-2.0 (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur HMMP natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/hmmp_dissector.lua` | Dissecteur HMMP : trames TCP (port 8847 par défaut, modifiable en préférence), multiplexage, rapports CPU/mémoire/connexions, nœuds de cluster |

Le dépôt amont contient aussi `docs/` et `README_zh.md` (documentation, en
chinois pour le second) : non importés.

## Utilisation

Copier `src/hmmp_dissector.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le port TCP (8847) est modifiable dans les
préférences du protocole.

## Limites constatées à l'import

- protocole jeune (2026) : la documentation amont est surtout en chinois ;
- certains types de messages décodés partiellement (charges brutes affichées).
