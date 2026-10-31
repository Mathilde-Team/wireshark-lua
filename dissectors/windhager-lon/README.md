# Windhager MES-WiFi LON

Dissecteur Wireshark Lua du protocole **LON** (LonWorks) de la passerelle
MES-WiFi des chaudières à granulés Windhager, encapsulé dans UDP par le
projet ESP32 de g3gg0 (issue #77).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/g3gg0/LonDissector |
| Commit importé | `ad3206b59f87debadad0730f3b0cf4b0003a9c34` du 12/01/2022 (dernier commit de `master`) |
| Licence amont | BSD-2-Clause (`LICENSE` amont, © 2022 g3gg0.de) |
| Natif Wireshark 4.6.4 | Non — Wireshark a un dissecteur `cnip` (LonTalk sur IP, ISO/IEC 14908-4), mais pas cette encapsulation MES-WiFi |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/LonDissector.lua` | Protocole `Windhager` (« Windhager MES-WiFi LON Protocol »), UDP 3333 |

Le script est repris tel quel, avec l'en-tête de provenance ajouté. Cas
d'usage décrit par l'auteur :
https://www.g3gg0.de/wordpress/esp32/mes-wifi-bringing-a-windhager-pellet-heater-online/

## Utilisation

Copier `src/LonDissector.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `windhager`.

## Limites constatées à l'import

- port UDP 3333 codé en dur ; protocole et table déclarés en variables
  globales (`mes_proto`, `udp_table`) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur du trafic réel.
