# dqlite (base de données distribuée)

Dissecteur Wireshark Lua pour dqlite — la base de données SQLite distribuée (réplication Raft) utilisée par LXD/Canonical : décodage du protocole client et des messages Raft.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/hersteller/wireshark-dissector-dqlite |
| Commit importé | `8eee58ee46f33adae8ef738ea69426af29133916` du 27/07/2025 (branche `main`) |
| Licence amont | MIT |
| Natif Wireshark 4.6.4 | Non — aucun dissector dqlite natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/dqlite.lua` | Dissecteur : protocole client dqlite, messages Raft (roles, entrées de journal) |

## Utilisation

Copier `src/dqlite.lua` dans le dossier `plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua.
