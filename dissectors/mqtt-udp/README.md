# MQTT/UDP (dzavalishin)

Dissecteur Wireshark en Lua de MQTT/UDP, variante sans courtier de MQTT où
chaque nœud diffuse ses paquets (format MQTT) en UDP sur le réseau local
(port 1883) : type de paquet et, pour les Publish, sujet et valeur,
issue #161.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/dzavalishin/mqtt_udp |
| Commit importé | `6156ddf4886e7eddd375417e99fe037f0601fb32` du 01/12/2024 (dernière modification de `lang/lua/wireshark/wireshark_mqtt_dissector.lua` : commit `bd14c5e97a8ab92713fed542bf1f4533cb7289a7` du 04/01/2019) |
| Licence amont | MIT (fichier `LICENSE` amont, © 2023 Dmitry Zavalishin) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | non : le dissecteur MQTT natif ne traite que TCP (le port UDP 1883 reste en `UDP`) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: MIT` avec la provenance est ajoutée (convention du
dépôt, issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wireshark_mqtt_dissector.lua` | Protocole `MQTT.UDP` sur le port UDP 1883 : type de paquet (Publish, Subscribe, PingReq, PingResp ; les autres types, marqués « ? », sont nommés mais non décodés) ; pour Publish : sujet et valeur |

Non importés : le reste du dépôt (bibliothèques MQTT/UDP en C, Java, Python,
Lua, outils), hors périmètre d'un dissecteur.

## Utilisation

Copier `src/wireshark_mqtt_dissector.lua` dans le dossier des plugins Lua
personnels de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis
Ctrl+Maj+L (le README amont propose aussi un `dofile` dans `init.lua`).
Filtre d'affichage : `mqtt.udp` ou `udp.port == 1883`.

## Vérification à l'import

Avec tshark 4.6.4, le fichier se charge sans erreur. Sur des captures
synthétiques (text2pcap, UDP 1883) :

| Trame | Résultat |
|---|---|
| `30 0f 00 0b` + `sensor/temp` + `21.5` (Publish) | `MQTT/UDP` : « Packet type: 48 Publish », Topic `sensor/temp`, Value `21.5` |
| `c0 00` (PingReq) | `MQTT/UDP`, « Packet type: 192 PingReq » |
| MQTT sur TCP 1883 | inchangé : dissecteur MQTT natif |

## Limites constatées

- Les éléments de l'arbre sont du texte, sans champs filtrables (pas de
  `mqtt.udp.topic`).
- Longueur restante et longueur du sujet lues sur un seul octet (TODO amont) :
  paquets de plus de 127 octets ou sujets de plus de 255 octets mal décodés.
- Type de paquet inconnu (ex. `0xF0`) ou avec drapeaux dans les 4 bits bas
  (ex. Publish QoS 1 = `0x32`) : erreur Lua « attempt to concatenate a nil
  value (local 'type_str') ».
- Non testé sur des captures réelles.
