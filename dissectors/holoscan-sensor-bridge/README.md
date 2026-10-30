# Holoscan Sensor Bridge (NVIDIA)

Dissecteur Wireshark en Lua des paquets de contrôle du Holoscan Sensor Bridge
(HSB) de NVIDIA, carte FPGA qui transporte des données de capteurs (caméras)
vers des pipelines GPU Holoscan : commandes ECB de lecture et d'écriture de
registres, et annonces d'énumération des cartes, issue #59.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/nvidia-holoscan/holoscan-sensor-bridge (projet officiel NVIDIA) |
| Commit importé | `e4e3042d014c89ed14f92669f6b8f28045d96a25` du 29/10/2026 (dernière modification de `scripts/hsb.lua` : commit `97d15c07edf0b39566a3a48ee5dea4854ffc0f67` du 03/10/2025) |
| Licence amont | Apache-2.0 (fichier `LICENSE` amont ; pas d'en-tête dans `hsb.lua`) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | non (aucun dissecteur HSB natif) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: Apache-2.0` avec la provenance est ajoutée
(convention du dépôt, issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/hsb.lua` | Protocole `hsb` (port UDP 8192) : opcode (WR_DWORD, WR_BLOCK, RD_DWORD, RD_BLOCK et réponses), drapeaux, séquence, adresse (FPGA_VERSION, FPGA_DATE nommées), valeur, code de réponse ; protocole `hsb-enum` (port UDP 10001) : identifiant et version de carte, numéro de série, versions et CRC CPNX/CLNX |

Seul `scripts/hsb.lua` est importé ; le reste du dépôt (bibliothèque C++,
pilotes, scripts) est hors sujet.

## Utilisation

Copier `src/hsb.lua` dans le dossier des plugins Lua personnels de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), puis Ctrl+Maj+L. Filtres
d'affichage : `hsb`, `hsb-enum`.

## Vérification à l'import

Avec tshark 4.6.4, le fichier se charge sans erreur. Sur des captures
synthétiques (text2pcap, UDP) :

| Trame | Résultat |
|---|---|
| UDP 8192, `04 00 00 01 00 00 00 00 00 80 12 34 56 78` | `HSB` : WR_DWORD, Seq 1, Address FPGA_VERSION (`0x80`), Value `0x12345678` |
| UDP 8192, `94 00 00 01 00 00 00 00 00 84 20 26 10 29` | `HSB` : RD_DWORD reply, Response `0x00`, Address FPGA_DATE (`0x84`), Value `0x20261029` |
| UDP 10001, annonce de 36 octets | `HSB-Enumeration` : ID, version (20 octets), série (7 octets), CPNX/CLNX version et CRC (petit-boutiste) |

## Limites constatées

- RD_BLOCK (`0x19`) et RD_BLOCK reply (`0x99`) sont nommés mais leur contenu
  n'est pas décodé (seuls opcode, drapeaux et séquence sont affichés).
- Le champ `Reserved` est déclaré sur 8 bits mais appliqué à 2 octets pour
  les requêtes.
- Pas de contrôle de longueur : une trame tronquée provoque une erreur Lua.
- Ports fixes (8192 et 10001), sans préférence ; les flux de données capteur
  (RoCE / UDP) ne sont pas décodés.
- Non testé sur des captures réelles.
