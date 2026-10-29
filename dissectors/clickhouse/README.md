# ClickHouse Native Protocol

Dissecteur Wireshark Lua pour le protocole natif ClickHouse (base de données analytique) : décodage des paquets client/serveur (requêtes, blocs de données, progress).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/xifeng/clickhouse-wireshark-dissector |
| Commit importé | `c5114a8e6a73f361b58e5672e2fcca34dc07c22a` du 14/03/2026 (branche `main`) |
| Licence amont | Apache-2.0 |
| Natif Wireshark 4.6.4 | Non — aucun dissector ClickHouse natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/clickhouse.lua` | Dissecteur : protocole natif ClickHouse (client/serveur) |

## Utilisation

Copier `src/clickhouse.lua` dans le dossier `plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua.
