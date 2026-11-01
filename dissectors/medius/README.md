# Medius

Dissecteur Wireshark Lua pour le protocole réseau Medius : messagerie en ligne
de jeux PlayStation (Medius/Lobby de PS2 et PS3 — SOCOM et apparentés),
messages applicatifs sur TCP/UDP. Version 1.5.0 amont : structures RT
(identification), expert info, et décodage des opcodes et messages Medius.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/hashsploit/medius-wireshark |
| Commit importé | `62c8e5969a88ac4f2e8a8711c448b358d989261e` du 10/01/2022 (branche `master`, « Updated to version 1.5.0, added expert info, rt structure identification ») |
| Licence amont | MIT (`LICENSE` amont, « Copyright (c) 2021 hashsploit ») |
| Natif Wireshark 4.6.4 | Non — aucun dissector Medius natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `medius_wireshark_dissector.lua` | Dissecteur Medius (opcodes, messages, structures RT) |

## Utilisation

Copier `medius_wireshark_dissector.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua.

## Remarques

Dépôt amont figé depuis janvier 2022 (v1.5.0) : pas de mise à jour amont
attendue. Références amont :
https://wiki.hashsploit.net/PlayStation_2#Medius et
https://wiki.hashsploit.net/PlayStation_3#Medius.
