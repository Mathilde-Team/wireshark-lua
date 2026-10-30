# MQTT sur WebSocket (a3135134) — post-dissecteur

Post-dissecteur Wireshark en Lua qui repère, dans un paquet WebSocket, le champ
`data` (charge brute), le reconvertit en octets et le passe au dissecteur
`mqtt` natif (issue #407).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/a3135134/Wireshark-Plugin-MQTToverWebSocket |
| Commit importé | `df05016e27bcf1a847ea50ee9b42aa9cde271662` du 23/05/2018 (dernier commit de `master`) |
| Licence amont | GPL-3.0 (fichier `LICENSE`, texte GPLv3 ; aucune mention « or later » dans le dépôt, d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Partiel — MQTT natif (`packet-mqtt.c`) sur TCP, TLS et QUIC ; pas d'enregistrement sur le sous-protocole WebSocket `mqtt` (« Décoder comme » reste possible) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/mqttoverwebsocket.lua` | Post-dissecteur `MQTToverWebsocket` : parcourt `all_field_infos()`, prend le premier champ `data` après `websocket` et appelle `Dissector.get("mqtt")` dessus |

Fichier repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/mqttoverwebsocket.lua` dans le dossier des plugins Lua de
Wireshark (l'amont propose aussi une ligne `dofile(...)` dans `init.lua`). Les
charges WebSocket doivent apparaître comme `data` pour être reprises.

## Limites constatées à l'import

- même rôle que `dissectors/mqtt-websocket` (issue #395, protocole `mqttws`) :
  les deux post-dissecteurs chargés ensemble décoderaient deux fois le MQTT ;
  n'en charger qu'un ;
- pas de réassemblage : un message MQTT réparti sur plusieurs trames WebSocket
  n'est pas reconstitué ;
- conversion de la charge via `tostring()` du champ puis suppression des `:`,
  dépendante du format d'affichage de Wireshark ;
- variables globales (`MQTToverWebsocket`, `mqtt_dissector`) ;
- le post-dissecteur parcourt tous les champs de chaque paquet ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
