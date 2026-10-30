# MQTT sur WebSocket (frogkind) — réassemblage des messages MQTT

Post-dissecteur Wireshark en Lua qui rassemble les charges WebSocket portant du
MQTT, y compris quand un message MQTT est découpé sur plusieurs trames
WebSocket, puis les passe au dissecteur `mqtt` natif (issue #395).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/frogkind/wireshark-mqtt-websocket-plugin |
| Commit importé | `053bd842bea22bec41f931c0282cb6fed8b6c406` du 24/06/2021 (dernier commit de `main`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2021 Chuang Zheng ») |
| Natif Wireshark 4.6.4 | Partiel — MQTT natif (`packet-mqtt.c`) sur TCP, TLS et QUIC ; `packet-mqtt.c` ne s'enregistre pas sur le sous-protocole WebSocket `mqtt` (« Décoder comme » reste possible) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/mqttws.lua` | Post-dissecteur `mqttws` : accumule `data.data` des paquets WebSocket, découpe selon la longueur MQTT et appelle `Dissector.get("mqtt")` sur un tampon « Reassembled mqtt data » |

Fichier repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/mqttws.lua` dans le dossier des plugins Lua de Wireshark (l'amont
propose aussi une ligne `dofile(...)` dans `init.lua`). Les charges WebSocket
doivent apparaître comme `data` (dissecteur de données brutes) pour être
reprises par le script.

## Limites constatées à l'import

- la longueur MQTT est lue sur un seul octet (`get_index(1) + 2`) : les
  messages de plus de 127 octets, dont la longueur restante est codée sur
  plusieurs octets, sont mal découpés ;
- un seul tampon d'accumulation pour toute la capture, sans distinction de
  flux TCP ni de sens : plusieurs connexions entrelacées se mélangent ;
  suppose une dissection dans l'ordre des paquets ;
- `vs_protos` (table de valeurs de `mqttws.protocol`) n'est défini nulle
  part ; les champs déclarés `mqttws.*` ne sont jamais ajoutés à l'arbre ;
- variables globales (`wsField`, `wsDataField`, `pParsed`, `mqttMsgTable`…) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
