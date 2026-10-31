# Meshtastic (meshtastic-talk) — paquets LoRa Meshtastic

Dissecteur Wireshark en Lua des paquets radio Meshtastic (réseau maillé LoRa)
reçus par la chaîne SDR GNU Radio du projet meshtastic-talk : en-tête de
couche 1 (destination, émetteur, identifiant, drapeaux hop limit / want ack /
via MQTT / hop start, hachage de canal, prochain saut, relais), puis couche 2
protobuf `meshtastic.Data` décodée selon le numéro de port applicatif (texte,
position, infos de nœud, routage, administration, télémétrie…) (issue #387).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/allanrbo/meshtastic-talk (fichier `wireshark/meshtastic_wireshark.lua`) |
| Commit importé | `62cb1d8365067f30f3b33c355f537f368ea9bd00` du 26/08/2025 (dernier commit de `master`) ; dernier changement du fichier : `14aca1477ad4ea537264754e41c518e3dd2f2d91` du 09/08/2025 |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2025 Allan Riordan Boll ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Meshtastic natif (rien dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/meshtastic_wireshark.lua` | Protocole `meshtastic` sur `wtap_encap` `WIRESHARK_UPPER_PDU` (entrée `udpdump`) : paquets préfixés par la chaîne magique `_meshtastic_____` ; protocoles auxiliaires `meshtastic.Data.portnum`, `meshtastic.User.short_name`, `meshtastic.User.long_name` et `meshtastic.Data.payload` enregistrés dans `protobuf_field` |

Fichier repris tel quel, en-tête de provenance ajouté. Non importés : la chaîne
de réception SDR (`rx_via_sdr/`, GNU Radio, qui démodule, déchiffre et envoie
les paquets à Wireshark), le relais Arduino (`tx_via_arduino/`) et le script
de lancement `wireshark/run_wireshark.sh` (résumé ci-dessous).

## Utilisation

1. Copier `src/meshtastic_wireshark.lua` dans le dossier des plugins Lua de
   Wireshark.
2. Déclarer les fichiers `.proto` de Meshtastic
   (https://github.com/meshtastic/protobufs) dans Préférences › Protocols ›
   Protobuf › Protobuf search paths.
3. Lancer la capture sur l'interface extcap `udpdump`
   (`wireshark -i udpdump -k`) alimentée par la chaîne SDR de l'amont, qui
   envoie chaque paquet préfixé par `_meshtastic_____`.
4. Filtres : `meshtastic`, `meshtastic.sender`, `meshtastic.dest`…

## Limites constatées à l'import

- format d'entrée propre à meshtastic-talk (paquets déjà démodulés et
  déchiffrés par la chaîne GNU Radio, transmis par `udpdump` avec la chaîne
  magique) : le script ne lit pas de capture LoRa brute et ne déchiffre rien
  lui-même ;
- le décodage de la charge dépend du dernier `portnum` observé (état global
  partagé entre paquets), ce qui suppose un ordre de dissection linéaire ;
- remplace le dissecteur par défaut de `WIRESHARK_UPPER_PDU` (il rappelle
  `exported_pdu` avant son propre traitement) ;
- `bit32` défini en global si absent (compatibilité avec `bit`) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
