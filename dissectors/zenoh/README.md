# Zenoh (pub-sub IoT/robotique)

Dissecteur Wireshark Lua pour le protocole Zenoh (Eclipse Foundation) : messages de données, déclarations, transport sur TCP/UDP.

> **Version Lua obsolète** : import de la dernière version Lua (tag `0.7.0-rc`), qui couvre Zenoh < 0.10.0. Le projet amont a réécrit son dissecteur en Rust (commit `06c07d5c`, septembre 2023) : pour Zenoh ≥ 0.10.0, utiliser le dissecteur Rust amont.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/eclipse-zenoh/zenoh-dissector |
| Commit importé | `84b5d59eb3d02d0381c109d2c5351fbc80f5316b` du 17/02/2023 (tag `0.7.0-rc`, branche `main` de l'époque) |
| Licence amont | GPLv3 ou toute version ultérieure (énoncée dans l'en-tête du fichier) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Zenoh natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont au même commit).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/zenoh.lua` | Dissecteur (1 878 lignes) : messages Zenoh < 0.10.0, déclarations, sérialisation |

Non importés : le reste du dépôt à ce commit (workflows CI, README) ; la réécriture Rust n'est pas concernée par cette collection Lua.

## Utilisation

Copier `src/zenoh.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`). Valable pour le trafic Zenoh < 0.10.0 uniquement.

## Limites constatées à l'import

- version figée (février 2023) : les messages des versions ultérieures de Zenoh ne seront pas disséqués correctement ;
- le dissecteur amont actuel est en Rust — hors périmètre de cette collection Lua.
