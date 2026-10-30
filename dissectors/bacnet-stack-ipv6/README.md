# BACnet/IPv6 (BVLC Annex X/U, bacnet-stack)

Dissecteur Wireshark en Lua de la couche BVLC de BACnet/IPv6 (ASHRAE
135-2016, Annex U, nommée Annex X dans les brouillons) fourni par le projet
bacnet-stack : fonctions BVLC (Original-Unicast/Broadcast-NPDU, résolution
d'adresses virtuelles, Forwarded-NPDU, enregistrement de périphériques
étrangers…), puis passage du NPDU au dissecteur BACnet natif, issue #157.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/bacnet-stack/bacnet-stack |
| Commit importé | `62e4340bf044a4fdeb3d860dcda2c6e079e2f5ba` du 29/10/2026 (dernière modification de `ports/linux/bacnet_ipv6.lua` : commit `369da70f2a42b32d583398c3410a9479a2c9f2c6` du 25/08/2024) |
| Licence amont | GPL-2.0-or-later (en-tête `SPDX-License-Identifier` du fichier ; « Copyright 2011, Siemens Building Technolgies », mis à jour par Steve Karg) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | oui : le dissecteur natif `bvlc` décode BACnet/IPv6 (type `0x82`, « BACnet/IPV6 (Annex U) ») ; ce fichier est redondant |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: GPL-2.0-or-later` avec la provenance est ajoutée
avant l'en-tête d'origine (convention du dépôt, issue #563).

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie conforme
de `license/GPL-2.0` du dépôt amont, avec son préambule SPDX).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/bacnet_ipv6.lua` | Protocoles `lua_BACnetBIPV6` (BVLC BACnet/IPv6) et `BACnet-Port` sur le port UDP 47808 : les trames de type `0x81` (BACnet/IPv4) sont passées au dissecteur natif `bvlc`, celles de type `0x82` au dissecteur Lua, puis le NPDU au dissecteur natif `bacnet` |

## Utilisation

Copier `src/bacnet_ipv6.lua` dans le dossier des plugins Lua personnels de
Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis Ctrl+Maj+L (le
commentaire amont propose aussi un `dofile` dans `init.lua`). Filtres
d'affichage : `lua_bacnetbipv6`, champs `BIPV6.*` (abréviations en majuscules,
ex. `BIPV6.function`).

Le dissecteur natif suffit dans la plupart des cas ; ce fichier sert surtout
de référence ou de comparaison.

## Vérification à l'import

Avec tshark 4.6.4, le fichier se charge sans erreur. Sur des captures
synthétiques (text2pcap, UDP 47808) :

| Trame | Natif | Avec le plugin |
|---|---|---|
| IPv6, `82 01 00 10` Original-Unicast-NPDU (adresses virtuelles 1 → 2) + NPDU + APDU readProperty | BVLC Annex U décodé, `Confirmed-REQ readProperty` | « B/IPv6 BACnet Virtual Link Control » : Function Original-Unicast-NPDU, Source-Virtual-Address 1, Destination-Virtual-Address 2, puis le même NPDU/APDU |
| IPv4, `81 0a` Original-Unicast-NPDU | BVLC décodé | passé au `bvlc` natif, résultat identique |

## Limites constatées

- Redondant avec le dissecteur natif `bvlc` de Wireshark 4.6.4.
- Remplace le dissecteur du port UDP 47808 : seules les trames BVLC de type
  `0x81` et `0x82` sont transmises à un dissecteur, les autres types sont
  ignorés (aucun arbre BVLC).
- Pas de contrôle du champ longueur BVLC (le natif signale une longueur
  incohérente, pas le plugin).
- Non testé sur des captures réelles.
