# TAFNet / Total Annihilation (GPGNet)

Dissecteur Wireshark Lua pour **TAFNet**, le protocole de GPGNet / TAForever
(Total Annihilation) : action (UDP_DATA, TCP_OPEN/CLOSE/DATA/ACK, HELLO…),
séquence et données, trafic de jeu tunnelé via UDP sur le port 6112.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/ta-forever/gpgnet4ta |
| Commit importé | `72d9d419731b73eef94e50c1e1a53eb54753f48e` du 26/07/2026 (branche `develop`, « If they're available, use player team selections to resolve suspicious alliance matrices ») |
| Licence amont | MIT (`LICENSE` amont, « Copyright (c) 2021 Alex Lowe ») |
| Natif Wireshark 4.6.4 | Non — aucun dissector TAFNet natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `tadissector.lua` | Dissecteur TAFNet (action, séquence, données ; UDP 6112) |

## Écart par rapport à l'amont

Le fichier amont ne compile pas : virgule manquante après `[9] = "ENUM"` dans
`get_action_name` (erreur de syntaxe Lua — Wireshark refuserait de charger le
script). Une correction locale minimale est appliquée (virgule ajoutée,
documentée dans l'en-tête du fichier) ; le reste du fichier est importé tel
quel.

## Utilisation

Copier `tadissector.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua.

## Remarques

Le dépôt amont contient aussi `libs/tapacket/tasmartpak.lua` (dissecteur TA
Smartpak, non importé ici — hors périmètre de l'issue #340). Dépôt actif
(dernière poussée août 2026). La bibliothèque `libs/rwe/` amont est sous
licence GPL (fichier `libs/rwe/LICENSE`) mais n'est pas importée.
