# MQTT (script d'atelier WSN-at-Work)

Dissecteur Wireshark Lua pour MQTT issu des supports d'atelier WSN-at-Work (réseaux de capteurs sans fil) : décodage des paquets MQTT (CONNECT, PUBLISH, SUBSCRIBE…).

> **Note** : Wireshark embarque depuis longtemps un dissecteur MQTT natif (`packet-mqtt.c`) — ce script, tiré de supports pédagogiques, est redondant avec le natif et n'est importé que pour référence.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/WSNhub/WSN-at-Work |
| Commit importé | `f14d66c4a87eeed9114fd458c189b14280b161c3` du 18/02/2016 (branche `master`) |
| Licence amont | LGPL-3.0-or-later — déclarée dans l'en-tête de `mqtt.lua` ; texte LGPL-3.0 fourni dans `LICENSE` (l'amont ne distribute pas le texte) |
| Natif Wireshark 4.6.4 | Oui — `packet-mqtt.c` |

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/mqtt.lua` | Dissecteur MQTT (paquets CONNECT, PUBLISH, SUBSCRIBE…) |

Le dépôt amont est un ensemble de supports d'atelier (PPTX, croquis Arduino) : seul le script Lua est importé.

## Utilisation

Copier `src/mqtt.lua` dans le dossier `plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua. Pour tout usage réel, préférer le dissecteur MQTT natif.
