# SMO Multi

Dissecteur Wireshark Lua pour le protocole en ligne de **Super Mario Odyssey
Multiplayer** (SMO Multi) : messages du mod multijoueur communautaire
(speyejack/smo-multi-rs, serveur en Rust), sur UDP.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/speyejack/smo-multi-rs |
| Commit importé | `70b0af699db1a5a7a1b32911e749d12f443f562b` du 20/04/2025 (branche `main`, « Handle invalid packet size more gracefully ») |
| Licence amont | MIT (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissector SMO natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `smo-wireshark.lua` | Dissecteur du protocole SMO Multi (32 lignes, type de paquet et taille) |

## Utilisation

Copier `smo-wireshark.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua.

## Remarques

Dissecteur volontairement minimaliste (en-tête de paquet seulement) ;
le dépôt amont est actif (dernière poussée septembre 2026).
