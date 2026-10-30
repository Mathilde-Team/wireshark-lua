# Open Drone ID (identification à distance des drones)

Dissecteur Wireshark en Lua des messages Open Drone ID (ASTM F3411, ASD-STAN
prEN 4709-002) diffusés par les drones : Basic ID, Location/Vector,
Authentication, Self ID, System, Operator ID et Message Pack, transportés
en Wi-Fi Beacon, Wi-Fi NAN et Bluetooth (4 legacy et 5 LE Coded PHY),
issue #48.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/opendroneid/wireshark-dissector (projet officiel Open Drone ID) |
| Commit importé | `d12670fede3aa4e336cfa326528782abfc864a10` du 12/06/2026 |
| Licence amont | Apache-2.0 (`LICENSE` amont, en-tête « License: apache-2.0 », © 2021 Gabriel Cox) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | non (aucun dissecteur Open Drone ID natif) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: Apache-2.0` avec la provenance est ajoutée
(convention du dépôt, issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/opendroneid-dissector.lua` | Protocole `OpenDroneID` et un sous-protocole par type de message ; enregistré en post-dissecteur (repère les éléments Open Drone ID dans les trames Wi-Fi et Bluetooth déjà disséquées) et sur l'encapsulation `IEEE_802_11` |

Non importés : les captures d'exemple (`odid_wifi_sample.pcap`,
`odid_wifi_bcn_sample.pcap`, `odid_bt5_lr_sample.pcapng`) et les captures
d'écran `img/`, disponibles dans le dépôt amont.

## Utilisation

Copier `src/opendroneid-dissector.lua` dans le dossier des plugins Lua
personnels de Wireshark (« Aide → À propos de Wireshark → Dossiers →
Plugins Lua personnels », ex. `~/.local/lib/wireshark/plugins/`), puis
Ctrl+Maj+L. Filtre d'affichage : `opendroneid`. La capture Wi-Fi demande une
interface en mode moniteur ; la capture Bluetooth a été validée par l'amont
avec le renifleur nRF Sniffer (nRF52840). Voir le README amont pour le
détail matériel.

## Vérification à l'import

Avec tshark 4.6.4, sur les trois captures d'exemple amont (non importées) :

| Capture | Trames | Trames `opendroneid` |
|---|---|---|
| `odid_wifi_bcn_sample.pcap` | 21 | 21 |
| `odid_wifi_sample.pcap` | 63 | 42 |
| `odid_bt5_lr_sample.pcapng` | 274 | 273 |

Message Pack, Basic ID, Location/Vector (latitude, longitude, altitudes,
vitesse) décodés. Aucune erreur sur les captures Wi-Fi. Sur la capture
Bluetooth, 30 trames ont une erreur, toutes à CRC Bluetooth invalide (déjà
signalées sans le plugin) ; pour 2 d'entre elles, le plugin ajoute une
erreur Lua « Range is out of bounds » (trame tronquée).

## Limites constatées à l'import

- d'après le code, l'enregistrement sur l'encapsulation `IEEE_802_11` (802.11 sans en-tête
  radio, linktype 105) remplace le dissecteur 802.11 natif pour ces
  captures : désactiver le protocole `OpenDroneID` (« Analyse → Protocoles
  activés ») pour une analyse 802.11 classique de ce type de fichier ;
- post-dissecteur : il est appelé pour chaque trame, ce qui peut ralentir
  l'ouverture de grosses captures ;
- trames tronquées (CRC invalide) : erreur Lua au lieu d'un constat
  « malformé » ;
- les messages Authentication multi-pages sont affichés page par page, sans
  réassemblage.
