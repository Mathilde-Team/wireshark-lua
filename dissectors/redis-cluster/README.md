# Redis Cluster

Dissecteur Wireshark Lua pour les échanges internes d'un cluster Redis : messages du bus de cluster (PING, MEET, PUBLISH…) et réacheminement des commandes entre nœuds.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/jundi77/redis-cluster-wireshark |
| Commit importé | `eb64c6b63a15ea1db7522c96e5c2e0181988796c` du 21/12/2024 (branche `main`) |
| Licence amont | GPL-3.0 |
| Natif Wireshark 4.6.4 | Non — aucun dissector Redis natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/redis_cluster.lua` | Dissecteur : messages du bus de cluster Redis |

## Utilisation

Copier `src/redis_cluster.lua` dans le dossier `plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua.
