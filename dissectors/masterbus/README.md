# MasterBus (Mastervolt, bus CAN)

Dissecteur Wireshark Lua du **protocole MasterBus de Mastervolt**, bus CAN à
250 kbit/s reliant les équipements Mastervolt (shunt DC, chargeur-onduleur
Mass Combi, afficheur MasterView…). Il identifie l'équipement à partir de
l'identifiant CAN, distingue requêtes et réponses et décode une partie des
messages (valeurs, date et heure, menus de configuration).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/pmarches/masterbus-esp32 |
| Commit importé | `edb79344bb8efb4e7d904355cf10b0c5d9ccb727` du 25/01/2022 (branche `master`, dernier commit ; dernière modification du dissecteur : `9a94dc6` du 24/01/2022) |
| Licence amont | GPL-3.0-only (`LICENSE` amont : texte de la GPL v3, sans mention « or any later version » ; pas d'en-tête de licence dans le fichier Lua) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur MasterBus natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `masterbusDissector.lua` | Dissecteur `masterbus` (sous-dissecteur CAN, via « Décoder comme ») |
| `captures/*.pcap` | 11 captures d'exemple amont (démarrage, configuration MasterView, date/heure, menus, capture `canhat`) |

Fichier Lua importé tel quel ; seule une en-tête SPDX + provenance de
quatre lignes a été ajoutée en tête. Les captures sont des copies binaires
conformes.

## Utilisation

Copier `masterbusDissector.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`) ou lancer
`wireshark -X lua_script:masterbusDissector.lua`, ouvrir une capture de
`captures/`, puis Analyser → Décoder comme… → sous-dissecteur CAN →
`masterbus`. Capture sur Raspberry Pi avec une carte CAN :
`tshark -i can0 -w capture.pcap`.

## Remarques

- Le dissecteur s'enregistre uniquement en « Décoder comme »
  (`add_for_decode_as`) : il faut le sélectionner à la main.
- L'auteur amont précise que les captures d'exemple ne sont pas au format
  CAN natif (format aligné sur l'octet de son outil) ; décodage sur trafic
  SocketCAN réel non vérifié.
- Non repris : la plus grosse capture amont (`volts_amps_only.pcap`,
  1,3 Mo) et le code ESP32 du projet — disponibles dans le dépôt amont.
- Non vérifié dans Wireshark.
