# EFCP / CDAP (RINA, pile IRATI) — SIDN Labs

Dissecteur Wireshark en Lua des PDU EFCP (Error and Flow Control Protocol)
échangées par la pile [IRATI](https://github.com/IRATI/stack/), implémentation
de l'architecture réseau RINA (Recursive InterNetwork Architecture), avec
passage des PDU de gestion au dissecteur Protobuf pour CDAP, issue #44.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/SIDN/irati-wireshark-dissector |
| Commit importé | `99ced479a773e5fb2ea2a7cc250675a5bb64986c` du 15/05/2020 |
| Licence amont | MIT (`LICENSE` amont, © 2020 SIDN Labs) — compatible avec la licence du dépôt |
| Natif Wireshark 4.6.4 | non (aucun dissecteur EFCP/RINA natif) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: MIT` avec la provenance est ajoutée (convention du
dépôt, issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/efcp.lua` | Dissecteur `efcp` sur l'EtherType `0xD1F0` : version, adresses, QoS, CEP-id, type et drapeaux de PDU, longueur (contrôlée), puis champs propres aux PDU DT, CACK, ACK/NACK/SACK/SNACK, FC, ACK+FC, Rendezvous et Management (CDAP via Protobuf) ; longueurs de champs réglables dans les préférences |

## Utilisation

Le fichier amont appelle `bit32.bor`, bibliothèque de Lua 5.2 absente du
Lua 5.4 de Wireshark 4.x : sans précaution, le chargement échoue
(« attempt to index a nil value (global 'bit32') »).

Contournement sans modifier le fichier importé : créer dans le dossier des
plugins Lua personnels un fichier chargé avant lui (ordre alphabétique), par
exemple `00-bit32.lua`, contenant :

```lua
bit32 = bit32 or { bor = function(a, b) return a | b end }
```

puis copier `src/efcp.lua` dans le même dossier (ex.
`~/.local/lib/wireshark/plugins/`). Les longueurs des champs dépendent du
DIF : les ajuster dans Préférences → Protocols → EFCP.

Pour décoder CDAP (facultatif), suivre le README amont : récupérer
`CDAP.proto` de la pile IRATI (`rina-tools/src/rlite/CDAP.proto`), en retirer
`[default = 0]` (refusé par Wireshark) et ajouter son dossier aux chemins de
recherche Protobuf de Wireshark.

## Vérification à l'import

Avec tshark 4.6.4, contournement `bit32` en place, sur une capture
synthétique (`text2pcap`, EtherType 0xD1F0, longueurs par défaut) : une PDU
Data Transfer (en-tête complet, numéro de séquence, charge utile) et une PDU
ACK (numéro de séquence de contrôle, numéro acquitté) décodées, longueur
cohérente sans constat expert.

## Limites constatées à l'import

- seul le DIF le plus externe est analysé (limite annoncée par l'amont) ;
- une PDU plus courte que ce qu'annonce son type provoque une erreur Lua
  « Range is out of bounds » au lieu d'un constat « malformé » ;
- CDAP non vérifié ici (nécessite `CDAP.proto` de la pile IRATI) ;
- dépôt amont sans activité depuis 2020.
